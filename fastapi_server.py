#!/usr/bin/env python3
"""
FastAPI backend server for weblser + WebAudit Pro.
Provides REST API endpoints for website analysis, comprehensive audits, PDF generation, and history management.

Endpoints:
- /api/analyze/* - Original weblser summary analysis
- /api/audit/* - WebAudit Pro 10-point comprehensive audit
- /api/compliance/* - Compliance audit (Australia, NZ, GDPR, CCPA)
"""

import json
import os
import uuid
import jwt
from datetime import datetime
from pathlib import Path
from typing import Optional, List, Dict
from io import BytesIO

import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration
from sentry_sdk.integrations.httpx import HttpxIntegration
from fastapi import FastAPI, HTTPException, Query, Header
from fastapi.responses import FileResponse, StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from supabase import create_client, Client
from anthropic import Anthropic

from analyzer import WebsiteAnalyzer
from audit_engine import WebsiteAuditor
from report_generator import WebAuditReportGenerator


# ==================== Models ====================

class AnalyzeRequest(BaseModel):
    """Request model for URL analysis."""
    url: str
    timeout: int = 10


class AnalysisResult(BaseModel):
    """Response model for analysis results."""
    id: str
    url: str
    title: Optional[str]
    meta_description: Optional[str]
    summary: str
    success: bool
    created_at: str


class PDFRequest(BaseModel):
    """Request model for PDF generation."""
    analysis_id: str
    logo_url: Optional[str] = None
    company_name: Optional[str] = None
    company_details: Optional[str] = None
    template: str = 'jumoki'  # Template set: 'default' or 'jumoki'
    theme: str = 'light'      # Theme: 'light' or 'dark'


class HistoryResponse(BaseModel):
    """Response model for analysis history."""
    analyses: List[AnalysisResult]
    total: int


# ==================== WebAudit Pro Models ====================

class AuditRequest(BaseModel):
    """Request model for website audit."""
    url: str
    timeout: int = 10
    deep_scan: bool = True


class AuditScoreResponse(BaseModel):
    """Response model for individual criterion score."""
    name: str
    score: float
    observations: List[str]
    recommendations: List[str]


class AuditResponse(BaseModel):
    """Response model for complete audit."""
    id: str
    url: str
    website_name: str
    audit_timestamp: str
    overall_score: float
    scores: Dict[str, float]
    key_strengths: List[str]
    critical_issues: List[str]
    priority_recommendations: List[Dict]


class AuditHistoryResponse(BaseModel):
    """Response model for audit history."""
    audits: List[AuditResponse]
    total: int


# ==================== Compliance Models ====================

class ComplianceRequest(BaseModel):
    """Request model for compliance audit."""
    url: str
    jurisdictions: List[str] = ['AU', 'NZ']  # Default: Australia & New Zealand
    timeout: int = 10
    audit_id: Optional[str] = None  # Link to existing audit (optional)


class ComplianceFinding(BaseModel):
    """Single finding for a compliance category."""
    category: str
    status: str  # Compliant, Partially Compliant, Non-Compliant
    risk_level: str  # Critical, High, Medium, Low
    findings: List[str]
    recommendations: List[str]
    priority: str  # Immediate, Short-term, Long-term


class ComplianceJurisdictionScore(BaseModel):
    """Score and findings for a single jurisdiction."""
    jurisdiction: str  # AU, NZ, GDPR, CCPA
    score: int
    findings: List[ComplianceFinding]
    critical_issues: List[str]


class ComplianceResponse(BaseModel):
    """Response model for compliance audit."""
    id: str
    url: str
    site_title: Optional[str]
    jurisdictions: List[str]
    overall_score: int
    jurisdiction_scores: Dict[str, ComplianceJurisdictionScore]
    critical_issues: List[str]
    remediation_roadmap: Dict[str, List[str]]
    created_at: str


# ==================== Sentry Setup ====================

sentry_sdk.init(
    dsn="https://531e3b4a74cbbe4db48be351d88abf9a@o4510235337687040.ingest.us.sentry.io/4510235974959104",
    integrations=[
        FastApiIntegration(),
        HttpxIntegration(),
    ],
    traces_sample_rate=1.0,
    environment="production",
    send_default_pii=True,
)

# ==================== FastAPI Setup ====================

app = FastAPI(
    title="weblser API",
    description="Website analyzer API - Extract content and generate AI summaries",
    version="1.0.0"
)

# Configure CORS - Allow requests from Flutter apps
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For production, restrict to your domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configure static files for email assets (logos, images)
static_dir = Path(__file__).parent / "static"
if static_dir.exists():
    app.mount("/static", StaticFiles(directory=str(static_dir)), name="static")

# ==================== Supabase Setup ====================

SUPABASE_URL = os.getenv('SUPABASE_URL', 'https://kmlhslmkdnjakkpluwup.supabase.co')  # Staging
SUPABASE_KEY = os.getenv('SUPABASE_KEY')  # Anon key (subject to RLS)
SUPABASE_SERVICE_ROLE_KEY = os.getenv('SUPABASE_SERVICE_ROLE_KEY')  # Service role key (bypasses RLS)

if SUPABASE_KEY:
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
else:
    supabase = None

# Service role client for backend operations that need to bypass RLS
if SUPABASE_SERVICE_ROLE_KEY:
    supabase_service: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
else:
    supabase_service = None


def extract_user_id_from_jwt(authorization_header: Optional[str]) -> str:
    """Extract user ID from JWT token in Authorization header."""
    if not authorization_header:
        raise HTTPException(status_code=401, detail="Missing authorization header")

    try:
        # Authorization header format: "Bearer <token>"
        parts = authorization_header.split()
        if len(parts) != 2 or parts[0].lower() != 'bearer':
            raise HTTPException(status_code=401, detail="Invalid authorization header format")

        token = parts[1]

        # Decode JWT without verification (we trust Supabase issued it)
        decoded = jwt.decode(token, options={"verify_signature": False})
        user_id = decoded.get('sub')

        if not user_id:
            raise HTTPException(status_code=401, detail="No user ID in token")

        return user_id
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Invalid token: {str(e)}")


# ==================== Storage ====================

# Use simple JSON files for history (in production, use PostgreSQL)
HISTORY_FILE = "analysis_history.json"
AUDIT_HISTORY_FILE = "audit_history.json"


def load_history() -> dict:
    """Load analysis history from file."""
    if Path(HISTORY_FILE).exists():
        with open(HISTORY_FILE, 'r') as f:
            return json.load(f)
    return {}


def save_history(history: dict) -> None:
    """Save analysis history to file."""
    with open(HISTORY_FILE, 'w') as f:
        json.dump(history, f, indent=2)


def get_history() -> dict:
    """Thread-safe history getter."""
    return load_history()


def load_audit_history() -> dict:
    """Load audit history from file."""
    if Path(AUDIT_HISTORY_FILE).exists():
        with open(AUDIT_HISTORY_FILE, 'r') as f:
            return json.load(f)
    return {}


def save_audit_history(history: dict) -> None:
    """Save audit history to file."""
    with open(AUDIT_HISTORY_FILE, 'w') as f:
        json.dump(history, f, indent=2)


def get_audit_history() -> dict:
    """Thread-safe audit history getter."""
    return load_audit_history()


# ==================== API Endpoints ====================

@app.get("/")
async def root():
    """Health check endpoint."""
    return {
        "status": "ok",
        "service": "weblser API",
        "version": "1.0.0"
    }


@app.get("/sentry-debug")
async def sentry_debug():
    """
    Test endpoint to verify Sentry integration.
    This intentionally throws a division by zero error to test error reporting.
    """
    division_by_zero = 1 / 0  # This will trigger an error that Sentry captures
    return {"status": "ok"}  # This line will never execute


@app.post("/api/analyze", response_model=AnalysisResult)
async def analyze_url(request: AnalyzeRequest, authorization: str = Header(None)):
    """
    Analyze a website and generate a summary.

    Args:
        request: AnalyzeRequest with URL and optional timeout
        authorization: JWT token from Authorization header

    Returns:
        AnalysisResult with ID, URL, title, description, and summary
    """
    try:
        # Extract user_id from JWT token
        user_id = extract_user_id_from_jwt(authorization)

        api_key = os.getenv('ANTHROPIC_API_KEY')
        if not api_key:
            raise HTTPException(
                status_code=500,
                detail="ANTHROPIC_API_KEY environment variable not set"
            )

        analyzer = WebsiteAnalyzer(timeout=request.timeout, api_key=api_key)
        result = analyzer.analyze(request.url)

        # Generate unique ID for this analysis
        analysis_id = str(uuid.uuid4())
        created_at = datetime.utcnow().isoformat()

        # Store in history with user_id
        history = get_history()
        history[analysis_id] = {
            "user_id": user_id,
            "url": result['url'],
            "title": result['title'],
            "meta_description": result['meta_description'],
            "summary": result['summary'],
            "success": result['success'],
            "created_at": created_at
        }
        save_history(history)

        return AnalysisResult(
            id=analysis_id,
            url=result['url'],
            title=result['title'],
            meta_description=result['meta_description'],
            summary=result['summary'],
            success=result['success'],
            created_at=created_at
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Analysis failed: {str(e)}"
        )


@app.get("/api/analyses/{analysis_id}", response_model=AnalysisResult)
async def get_analysis(analysis_id: str):
    """
    Retrieve a specific analysis by ID.

    Args:
        analysis_id: UUID of the analysis

    Returns:
        AnalysisResult
    """
    history = get_history()
    if analysis_id not in history:
        raise HTTPException(status_code=404, detail="Analysis not found")

    analysis = history[analysis_id]
    return AnalysisResult(
        id=analysis_id,
        **analysis
    )


@app.get("/api/history", response_model=HistoryResponse)
async def get_history_list(authorization: str = Header(None), limit: int = Query(100, ge=1, le=1000)):
    """
    Get analysis history for authenticated user.

    Args:
        authorization: JWT token from Authorization header
        limit: Maximum number of analyses to return

    Returns:
        HistoryResponse with list of analyses
    """
    try:
        # Extract user_id from JWT token
        user_id = extract_user_id_from_jwt(authorization)

        history = get_history()

        # Filter by user_id and sort by created_at (newest first)
        user_analyses = [
            (aid, data) for aid, data in history.items()
            if data.get('user_id') == user_id
        ]

        sorted_analyses = sorted(
            user_analyses,
            key=lambda x: x[1]['created_at'],
            reverse=True
        )[:limit]

        analyses = [
            AnalysisResult(id=aid, **{k: v for k, v in data.items() if k != 'user_id'})
            for aid, data in sorted_analyses
        ]

        return HistoryResponse(
            analyses=analyses,
            total=len(user_analyses)
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to get history: {str(e)}"
        )


@app.post("/api/pdf")
async def generate_pdf(request: PDFRequest):
    """
    Generate a PDF report for an analysis.

    Args:
        request: PDFRequest with analysis_id and optional branding

    Returns:
        PDF file as attachment
    """
    try:
        history = get_history()
        if request.analysis_id not in history:
            raise HTTPException(status_code=404, detail="Analysis not found")

        analysis = history[request.analysis_id]

        # Prepare analysis result for PDF generation
        result = {
            'url': analysis['url'],
            'title': analysis['title'],
            'meta_description': analysis['meta_description'],
            'summary': analysis['summary'],
            'success': analysis['success']
        }

        api_key = os.getenv('ANTHROPIC_API_KEY')
        analyzer = WebsiteAnalyzer(api_key=api_key)

        # Generate PDF to BytesIO
        pdf_path = f"/tmp/{request.analysis_id}.pdf"
        analyzer.generate_pdf_playwright(
            result,
            is_audit=False,
            output_path=pdf_path,
            logo_path=request.logo_url,
            company_name=request.company_name,
            company_details=request.company_details,
            use_dark_theme=(request.theme == 'dark'),
            template=request.template
        )

        # Return PDF file
        return FileResponse(
            path=pdf_path,
            media_type="application/pdf",
            filename=f"{request.analysis_id}.pdf"
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"PDF generation failed: {str(e)}"
        )


@app.delete("/api/analyses/{analysis_id}")
async def delete_analysis(analysis_id: str):
    """
    Delete an analysis from history.

    Args:
        analysis_id: UUID of the analysis

    Returns:
        Confirmation message
    """
    history = get_history()
    if analysis_id not in history:
        raise HTTPException(status_code=404, detail="Analysis not found")

    del history[analysis_id]
    save_history(history)

    return {"status": "deleted", "id": analysis_id}


@app.delete("/api/history")
async def clear_history():
    """
    Clear all analysis history.

    Returns:
        Confirmation message
    """
    save_history({})
    return {"status": "cleared", "message": "All history cleared"}


# ==================== WebAudit Pro - Audit Endpoints ====================

@app.post("/api/audit/analyze", response_model=AuditResponse)
async def audit_website(request: AuditRequest, authorization: str = Header(None)):
    """
    Perform comprehensive 10-point audit of a website.

    Args:
        request: AuditRequest with URL and optional settings
        authorization: JWT token from Authorization header

    Returns:
        AuditResponse with overall score, 10 criterion scores, and recommendations
    """
    try:
        # Extract user_id from JWT token
        user_id = extract_user_id_from_jwt(authorization)

        api_key = os.getenv('ANTHROPIC_API_KEY')
        if not api_key:
            raise HTTPException(
                status_code=500,
                detail="ANTHROPIC_API_KEY environment variable not set"
            )

        auditor = WebsiteAuditor(timeout=request.timeout, api_key=api_key)
        audit_result = auditor.audit(request.url, deep_scan=request.deep_scan)

        # Generate unique ID for this audit
        audit_id = str(uuid.uuid4())

        # Convert audit result to dictionary
        audit_dict = auditor.to_dict(audit_result)
        audit_dict['user_id'] = user_id

        # Store in history with user_id
        audit_history = get_audit_history()
        audit_history[audit_id] = audit_dict
        save_audit_history(audit_history)

        # Return with ID
        return AuditResponse(
            id=audit_id,
            url=audit_result.url,
            website_name=audit_result.website_name,
            audit_timestamp=audit_result.audit_timestamp,
            overall_score=audit_result.overall_score,
            scores=audit_result.scores,
            key_strengths=audit_result.key_strengths,
            critical_issues=audit_result.critical_issues,
            priority_recommendations=audit_result.priority_recommendations
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Audit failed: {str(e)}"
        )


@app.get("/api/audit/{audit_id}", response_model=AuditResponse)
async def get_audit(audit_id: str, authorization: str = Header(None)):
    """
    Retrieve a specific audit by ID (authenticated user only).

    Args:
        audit_id: UUID of the audit
        authorization: JWT token from Authorization header

    Returns:
        AuditResponse
    """
    try:
        # Extract user_id from JWT token
        user_id = extract_user_id_from_jwt(authorization)

        audit_history = get_audit_history()
        if audit_id not in audit_history:
            raise HTTPException(status_code=404, detail="Audit not found")

        audit_data = audit_history[audit_id]

        # Verify user_id matches
        if audit_data.get('user_id') != user_id:
            raise HTTPException(status_code=403, detail="Not authorized to access this audit")

        # Remove user_id from response
        audit_data_clean = {k: v for k, v in audit_data.items() if k != 'user_id'}

        return AuditResponse(
            id=audit_id,
            **audit_data_clean
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to retrieve audit: {str(e)}"
        )


@app.get("/api/audit/history/list", response_model=AuditHistoryResponse)
async def get_audit_history_list(authorization: str = Header(None), limit: int = Query(100, ge=1, le=1000)):
    """
    Get audit history for authenticated user.

    Args:
        authorization: JWT token from Authorization header
        limit: Maximum number of audits to return

    Returns:
        AuditHistoryResponse with list of audits
    """
    try:
        # Extract user_id from JWT token
        user_id = extract_user_id_from_jwt(authorization)

        audit_history = get_audit_history()

        # Filter by user_id and sort by audit_timestamp (newest first)
        user_audits = [
            (aid, data) for aid, data in audit_history.items()
            if data.get('user_id') == user_id
        ]

        sorted_audits = sorted(
            user_audits,
            key=lambda x: x[1]['audit_timestamp'],
            reverse=True
        )[:limit]

        audits = [
            AuditResponse(id=aid, **{k: v for k, v in data.items() if k != 'user_id'})
            for aid, data in sorted_audits
        ]

        return AuditHistoryResponse(
            audits=audits,
            total=len(user_audits)
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to get audit history: {str(e)}"
        )


@app.delete("/api/audit/{audit_id}")
async def delete_audit(audit_id: str):
    """
    Delete an audit from history.

    Args:
        audit_id: UUID of the audit

    Returns:
        Confirmation message
    """
    audit_history = get_audit_history()
    if audit_id not in audit_history:
        raise HTTPException(status_code=404, detail="Audit not found")

    del audit_history[audit_id]
    save_audit_history(audit_history)

    return {"status": "deleted", "id": audit_id}


@app.delete("/api/audit/history/clear")
async def clear_audit_history():
    """
    Clear all audit history.

    Returns:
        Confirmation message
    """
    save_audit_history({})
    return {"status": "cleared", "message": "All audit history cleared"}


# ==================== PDF Generation Endpoints ====================

class PDFRequest(BaseModel):
    """Request model for PDF generation."""
    audit_id: str
    document_type: str  # "audit-report", "improvement-plan", or "partnership-proposal"
    client_name: Optional[str] = None
    company_name: str = "WebAudit Pro"
    company_details: Optional[str] = None


@app.post("/api/audit/generate-pdf/{audit_id}/{document_type}")
async def generate_audit_pdf(audit_id: str, document_type: str, request: Optional[PDFRequest] = None):
    """
    Generate PDF report from an audit.

    Args:
        audit_id: UUID of the audit
        document_type: Type of document ("audit-report", "improvement-plan", "partnership-proposal")
        request: Optional parameters for PDF generation

    Returns:
        PDF file as attachment
    """
    try:
        # Validate document type
        valid_types = ["audit-report", "improvement-plan", "partnership-proposal"]
        if document_type not in valid_types:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid document type. Must be one of: {', '.join(valid_types)}"
            )

        # Get audit data
        audit_history = get_audit_history()
        if audit_id not in audit_history:
            raise HTTPException(status_code=404, detail="Audit not found")

        audit_data = audit_history[audit_id]

        # Extract request parameters
        client_name = request.client_name if request else audit_data.get('website_name', 'Client')
        company_name = (request.company_name if request else "WebAudit Pro")
        company_details = (request.company_details if request else "")

        # Generate PDF
        generator = WebAuditReportGenerator()
        pdf_path = f"/tmp/{audit_id}_{document_type}.pdf"

        if document_type == "audit-report":
            generator.generate_audit_report(
                audit_data,
                pdf_path,
                company_name=company_name,
                company_details=company_details
            )
            filename = f"audit-report_{audit_id[:8]}.pdf"

        elif document_type == "improvement-plan":
            generator.generate_improvement_plan(
                audit_data,
                pdf_path,
                client_name=client_name,
                company_name=company_name,
                company_details=company_details
            )
            filename = f"improvement-plan_{audit_id[:8]}.pdf"

        elif document_type == "partnership-proposal":
            generator.generate_partnership_proposal(
                audit_data,
                pdf_path,
                client_name=client_name,
                company_name=company_name,
                company_details=company_details
            )
            filename = f"partnership-proposal_{audit_id[:8]}.pdf"

        # Return PDF file
        return FileResponse(
            path=pdf_path,
            media_type="application/pdf",
            filename=filename
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"PDF generation failed: {str(e)}"
        )


# ==================== Compliance Audit Endpoints ====================

def build_compliance_prompt(site_content: str, site_metadata: dict, jurisdictions: List[str]) -> str:
    """Build comprehensive multi-jurisdiction compliance evaluation prompt."""

    jurisdiction_sections = []

    if 'AU' in jurisdictions:
        jurisdiction_sections.append("""
AUSTRALIA COMPLIANCE EVALUATION
================================
Evaluate against:
- Competition and Consumer Act 2010 (Australian Consumer Law / ACL)
- Privacy Act 1988 (Australian Privacy Principles - APPs)
- Spam Act 2003
- Do Not Call Register Act 2006
- AANA Code of Ethics & Advertising Standards
- Fair Trading Act
- Website Accessibility (WCAG 2.1 Level AA)

Check for:
- ACL Compliance (s18: misleading/deceptive conduct, pricing clarity, claims substantiation)
- Privacy Policy (clear, accessible, APP1-13 compliance)
- Cookie consent and tracking disclosures
- Unsubscribe links and marketing opt-out mechanisms
- Business registration info (ABN/ACN)
- Contact information and support mechanisms
- Terms of Service fairness and enforceability
- Refund/return policy compliance
- HTTPS/SSL certificate presence
- Security headers implementation
- Accessibility compliance (alt text, captions, keyboard navigation)
""")

    if 'NZ' in jurisdictions:
        jurisdiction_sections.append("""
NEW ZEALAND COMPLIANCE EVALUATION
==================================
Evaluate against:
- Consumer Guarantees Act 1993
- Privacy Act 2020
- Spam Act 2003
- Fair Trading Act 1986
- Disable Discrimination Act 1993
- Health and Safety at Work Act 2015 (if applicable)

Check for:
- Privacy Policy (NZ Privacy Act compliant)
- Clear terms and conditions
- Consumer guarantee disclosures
- Fair pricing and no misleading claims
- Contact information and dispute resolution
- Data security measures
- Accessibility compliance
- Marketing consent mechanisms
""")

    if 'GDPR' in jurisdictions:
        jurisdiction_sections.append("""
GDPR COMPLIANCE EVALUATION (European Union)
============================================
Evaluate against:
- General Data Protection Regulation (GDPR) Articles 5-49
- ePrivacy Directive and EDPB Guidelines
- GDPR Recitals and guidance

Check for:
- Valid lawful basis for processing (consent, contract, legitimate interest)
- GDPR-compliant privacy notice (transparent, concise, easily accessible)
- Data controller information clearly identified
- Data Processing Agreement if using processors
- Cookie consent mechanism (EDPB: explicit opt-in before non-essential cookies)
- Cookie categories: essential, analytics, marketing, functional
- Cookie policy explaining all cookies and their purposes
- User rights implementation: access, rectification, erasure, portability, objection
- Cross-border transfer mechanisms (SCCs, adequacy decisions, BCRs)
- Data retention and deletion policies
- Breach notification process and GDPR compliance
- Data Protection Impact Assessment (DPIA) documentation
- Right to lodge complaints with DPA
- Sub-processor transparency
- Appropriate security measures (encryption, access controls)
""")

    if 'CCPA' in jurisdictions:
        jurisdiction_sections.append("""
CCPA/CPRA COMPLIANCE EVALUATION (California)
=============================================
Evaluate against:
- California Consumer Privacy Act (CCPA)
- California Privacy Rights Act (CPRA) amendments
- California's Consumer Legal Remedies Act

Check for:
- Lawful basis for data collection and sale
- Consumer disclosures: what data is collected, purposes, retention
- "Do Not Sell My Personal Information" link (clear, conspicuous)
- "Limit the Use and Disclosure of My Sensitive Personal Information" option
- Consumer rights implementation: access, deletion, opt-out of sale
- Opt-in requirement before selling personal information
- Privacy policy addressing all required disclosures
- Service provider contracts for data processors
- No discrimination for exercising CCPA rights
- Reasonable security practices
- Age-appropriate privacy practices
- Sale of data to third parties disclosure
- Business operations disclosure
- Contact information for privacy inquiries
""")

    full_prompt = f"""You are an expert legal compliance analyst specializing in international privacy law, consumer protection regulations, and digital compliance standards.

Analyze the following website content and metadata for legal and regulatory compliance across the specified jurisdictions.

WEBSITE CONTENT:
{site_content[:5000]}  # Limit to prevent token explosion

WEBSITE METADATA:
- Title: {site_metadata.get('title', 'N/A')}
- Meta Description: {site_metadata.get('meta_description', 'N/A')}
- URL: {site_metadata.get('url', 'N/A')}

{chr(10).join(jurisdiction_sections)}

AUDIT OUTPUT FORMAT:
Return ONLY a valid JSON object with this exact structure. Ensure all string values are properly JSON-escaped (replace double quotes with \", backslashes with \\, newlines with \\n):

{{
  "jurisdictions": {{
    "AU": {{
      "score": <0-100 integer>,
      "categories": {{
        "acl_compliance": {{"status": "Compliant|Partially Compliant|Non-Compliant", "risk_level": "Critical|High|Medium|Low", "findings": ["finding 1", "finding 2"], "recommendations": ["rec 1", "rec 2"], "priority": "Immediate|Short-term|Long-term"}},
        "privacy_data_protection": {{"status": "...", "risk_level": "...", "findings": [...], "recommendations": [...], "priority": "..."}},
        "advertising_marketing": {{"status": "...", "risk_level": "...", "findings": [...], "recommendations": [...], "priority": "..."}},
        "security_trust": {{"status": "...", "risk_level": "...", "findings": [...], "recommendations": [...], "priority": "..."}},
        "accessibility": {{"status": "...", "risk_level": "...", "findings": [...], "recommendations": [...], "priority": "..."}},
        "ecommerce_terms": {{"status": "...", "risk_level": "...", "findings": [...], "recommendations": [...], "priority": "..."}}
      }},
      "critical_issues": ["issue 1", "issue 2"]
    }},
    "NZ": {{ ... (same structure as AU) ... }},
    "GDPR": {{ ... (same structure as AU) ... }},
    "CCPA": {{ ... (same structure as AU) ... }}
  }},
  "overall_score": <0-100 integer>,
  "highest_risk_level": "Critical|High|Medium|Low",
  "critical_issues": ["issue 1", "issue 2"],
  "remediation_roadmap": {{
    "immediate": ["action 1", "action 2"],
    "short_term": ["action 1", "action 2"],
    "long_term": ["action 1", "action 2"]
  }}
}}

IMPORTANT: Return ONLY valid JSON with no additional text before or after. All string values must be properly escaped for JSON.

For each jurisdiction requested:
1. Assess compliance status
2. Identify critical, high, medium, and low risk issues
3. Provide specific findings with evidence from the website (keep findings concise, max 200 chars)
4. Give actionable recommendations for remediation (keep recommendations concise, max 200 chars)
5. Prioritize actions (Immediate = within 0-30 days, Short-term = 1-3 months, Long-term = 3-6 months)

Be thorough, specific, and provide practical guidance for business owners to achieve compliance."""

    return full_prompt


@app.post("/api/compliance-audit", response_model=ComplianceResponse)
async def compliance_audit(
    request: ComplianceRequest,
    authorization: str = Header(None)
):
    """
    Generate comprehensive compliance audit for a website across multiple jurisdictions.

    Args:
        request: ComplianceRequest with URL and jurisdictions
        authorization: Bearer token for user authentication

    Returns:
        ComplianceResponse with findings, scores, and recommendations
    """
    try:
        # Extract user ID from JWT
        user_id = extract_user_id_from_jwt(authorization)

        if not supabase:
            raise HTTPException(
                status_code=500,
                detail="Supabase not configured"
            )

        # Get API key
        api_key = os.getenv('ANTHROPIC_API_KEY')
        if not api_key:
            raise HTTPException(
                status_code=500,
                detail="ANTHROPIC_API_KEY environment variable not set"
            )

        # Analyze website content
        analyzer = WebsiteAnalyzer(timeout=request.timeout, api_key=api_key)
        analysis_result = analyzer.analyze(request.url)

        if not analysis_result.get('success'):
            raise HTTPException(
                status_code=400,
                detail=f"Failed to fetch website: {analysis_result.get('summary', 'Unknown error')}"
            )

        # Helper function to clean quoted strings from analyzer output
        def clean_value(value):
            """Remove extra quotes that analyzer sometimes adds"""
            if isinstance(value, str):
                # Remove surrounding single quotes if present
                if value.startswith("'") and value.endswith("'"):
                    value = value[1:-1]
                # Remove surrounding double quotes if present
                if value.startswith('"') and value.endswith('"'):
                    value = value[1:-1]
            return value

        # Build compliance evaluation prompt with cleaned values
        site_metadata = {
            'url': clean_value(analysis_result.get('url', '')),
            'title': clean_value(analysis_result.get('title', '')),
            'meta_description': clean_value(analysis_result.get('meta_description', ''))
        }

        # Also clean extracted_content before using in prompt
        extracted_content = clean_value(analysis_result.get('extracted_content', ''))

        prompt = build_compliance_prompt(
            extracted_content,
            site_metadata,
            request.jurisdictions
        )

        # Call Claude API for compliance analysis
        client = Anthropic(api_key=api_key)
        response = client.messages.create(
            model="claude-sonnet-4-5",
            max_tokens=8192,
            messages=[
                {
                    "role": "user",
                    "content": prompt
                }
            ]
        )

        # Extract and parse JSON response
        response_text = response.content[0].text

        # CRITICAL FIX: Strip markdown code fence markers if present (```json ... ```)
        response_text = response_text.strip()
        if response_text.startswith('```'):
            # Remove opening code fence (with optional language specifier)
            start_fence = response_text.find('\n')
            if start_fence != -1:
                response_text = response_text[start_fence + 1:]
        if response_text.endswith('```'):
            response_text = response_text[:-3].strip()

        # Strip surrounding quotes (single or double) that wrap the JSON
        response_text = response_text.strip()
        # Keep stripping matching quotes from outside until we hit {
        while response_text and response_text[0] in ("'", '"'):
            quote_char = response_text[0]
            # Check if the matching quote exists at the end
            if response_text.endswith(quote_char) and len(response_text) > 1:
                response_text = response_text[1:-1].strip()
            else:
                # Mismatched or single quote - just strip the leading one
                response_text = response_text[1:].strip()
                break

        # Find JSON in response (Claude may include explanation text)
        json_start = response_text.find('{')
        if json_start == -1:
            print(f"ERROR: No JSON found in Claude response. Response: {response_text[:500]}")
            raise ValueError("No JSON found in Claude response")

        # Count braces to find the matching closing brace
        brace_count = 0
        in_string = False
        escape_next = False
        json_end = -1

        for i in range(json_start, len(response_text)):
            char = response_text[i]

            # Handle escape sequences in strings
            if escape_next:
                escape_next = False
                continue

            if char == '\\':
                escape_next = True
                continue

            # Track if we're inside a string
            if char == '"':
                in_string = not in_string
                continue

            # Only count braces when not in a string
            if not in_string:
                if char == '{':
                    brace_count += 1
                elif char == '}':
                    brace_count -= 1
                    if brace_count == 0:
                        json_end = i + 1
                        break

        # If brace counting failed, try to recover by closing open braces and strings
        if json_end == -1:
            print(f"WARNING: Unclosed braces/strings detected (final brace count: {brace_count}, in_string: {in_string}). Attempting recovery...")
            # The JSON is incomplete - close any unterminated string first
            if in_string:
                response_text = response_text + '"'
            # Then close remaining braces
            if brace_count > 0:
                response_text = response_text + ('}' * brace_count)
            json_end = len(response_text)

        json_str = response_text[json_start:json_end]

        # Log the extracted JSON for debugging if there are issues
        print(f"Extracted JSON length: {len(json_str)}")
        print(f"JSON preview (first 500 chars): {json_str[:500]}")

        try:
            # Try to parse JSON
            compliance_data = json.loads(json_str)
        except json.JSONDecodeError as e:
            # Log detailed error information
            error_pos = e.pos if hasattr(e, 'pos') else 'unknown'
            error_line = e.lineno if hasattr(e, 'lineno') else 'unknown'
            error_col = e.colno if hasattr(e, 'colno') else 'unknown'

            print(f"JSON Parsing Error at position {error_pos}, line {error_line}, col {error_col}")
            print(f"Error message: {str(e)}")

            # Show context around the error position
            if error_pos != 'unknown' and isinstance(error_pos, int):
                start = max(0, error_pos - 150)
                end = min(len(json_str), error_pos + 150)
                error_context = json_str[start:end]
                print(f"Context around error (chars {start}-{end}):")
                print(error_context)
                print(f"Error position marker: {' ' * (error_pos - start)}^")

            # Show character at error position
            if error_pos != 'unknown' and isinstance(error_pos, int) and error_pos < len(json_str):
                char_at_error = json_str[error_pos]
                print(f"Character at error position: '{char_at_error}' (ord={ord(char_at_error)})")

            print(f"\nFull JSON length: {len(json_str)} characters")
            print(f"JSON start (first 300 chars):\n{json_str[:300]}")
            print(f"\nJSON end (last 300 chars):\n{json_str[-300:]}")

            raise ValueError(f"Failed to parse compliance response JSON at position {error_pos}: {str(e)}")

        # Generate unique ID
        compliance_id = str(uuid.uuid4())
        created_at = datetime.utcnow().isoformat()

        # Prepare data for Supabase
        supabase_data = {
            'id': compliance_id,
            'user_id': user_id,
            'audit_id': request.audit_id,
            'website_url': request.url,
            'site_title': analysis_result.get('title'),
            'jurisdictions': request.jurisdictions,
            'au_score': compliance_data['jurisdictions'].get('AU', {}).get('score'),
            'nz_score': compliance_data['jurisdictions'].get('NZ', {}).get('score'),
            'gdpr_score': compliance_data['jurisdictions'].get('GDPR', {}).get('score'),
            'ccpa_score': compliance_data['jurisdictions'].get('CCPA', {}).get('score'),
            'overall_score': compliance_data['overall_score'],
            'highest_risk_level': compliance_data['highest_risk_level'],
            'findings': compliance_data['jurisdictions'],
            'critical_issues': compliance_data['critical_issues'],
            'remediation_roadmap': compliance_data['remediation_roadmap'],
            'status': 'completed',
            'created_at': created_at
        }

        # Save to Supabase (RLS policies allow user to insert their own data via anon key)
        # Use service role if available, otherwise use regular client
        save_client = supabase_service if supabase_service else supabase
        if not save_client:
            raise HTTPException(status_code=500, detail="Supabase not configured")

        result = save_client.table('compliance_audits').insert(supabase_data).execute()

        # Also save normalized findings for easier querying
        for jurisdiction, data in compliance_data['jurisdictions'].items():
            for category, findings in data.get('categories', {}).items():
                save_client.table('compliance_findings').insert({
                    'compliance_audit_id': compliance_id,
                    'jurisdiction': jurisdiction,
                    'category': category,
                    'status': findings.get('status'),
                    'risk_level': findings.get('risk_level'),
                    'findings': findings.get('findings', []),
                    'recommendations': findings.get('recommendations', []),
                    'priority': findings.get('priority')
                }).execute()

        # Build response
        jurisdiction_scores = {}
        for jurisdiction in request.jurisdictions:
            j_data = compliance_data['jurisdictions'].get(jurisdiction, {})
            jurisdiction_scores[jurisdiction] = {
                'jurisdiction': jurisdiction,
                'score': j_data.get('score', 0),
                'findings': [],  # Simplified for response
                'critical_issues': j_data.get('critical_issues', [])
            }

        return ComplianceResponse(
            id=compliance_id,
            url=request.url,
            site_title=analysis_result.get('title'),
            jurisdictions=request.jurisdictions,
            overall_score=compliance_data['overall_score'],
            jurisdiction_scores=jurisdiction_scores,
            critical_issues=compliance_data['critical_issues'],
            remediation_roadmap=compliance_data['remediation_roadmap'],
            created_at=created_at
        )

    except HTTPException:
        raise
    except Exception as e:
        sentry_sdk.capture_exception(e)
        raise HTTPException(
            status_code=500,
            detail=f"Compliance audit failed: {str(e)}"
        )


@app.get("/api/compliance-audit/history/list")
async def get_compliance_audit_history(
    authorization: str = Header(None),
    limit: int = Query(100, ge=1, le=1000)
):
    """
    Get compliance audit history for the authenticated user.

    Args:
        authorization: Bearer token for user authentication
        limit: Maximum number of audits to return

    Returns:
        List of compliance audits for the user
    """
    try:
        user_id = extract_user_id_from_jwt(authorization)

        # Use service role client for reading (bypasses RLS auth check, but we verify user_id manually)
        query_client = supabase_service if supabase_service else supabase
        if not query_client:
            raise HTTPException(status_code=500, detail="Supabase not configured")

        # Get compliance audits from Supabase, sorted by newest first (using service role to bypass RLS)
        result = (query_client
                 .table('compliance_audits')
                 .select('*')
                 .eq('user_id', user_id)
                 .order('created_at', desc=True)
                 .limit(limit)
                 .execute())

        audits = []
        for audit in result.data:
            audits.append(ComplianceResponse(
                id=audit['id'],
                url=audit['website_url'],
                site_title=audit['site_title'],
                jurisdictions=audit['jurisdictions'],
                overall_score=audit['overall_score'],
                jurisdiction_scores={j: {'jurisdiction': j, 'score': audit.get(f'{j.lower()}_score', 0), 'findings': [], 'critical_issues': []} for j in audit['jurisdictions']},
                critical_issues=audit['critical_issues'],
                remediation_roadmap=audit['remediation_roadmap'],
                created_at=audit['created_at']
            ))

        return audits

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve history: {str(e)}")


@app.get("/api/compliance-audit/{compliance_id}", response_model=ComplianceResponse)
async def get_compliance_audit(
    compliance_id: str,
    authorization: str = Header(None)
):
    """
    Retrieve a specific compliance audit by ID.

    Args:
        compliance_id: UUID of the compliance audit
        authorization: Bearer token for user authentication

    Returns:
        ComplianceResponse with full audit data
    """
    try:
        user_id = extract_user_id_from_jwt(authorization)

        # Use service role client for reading (bypasses RLS auth check, but we verify user_id manually)
        query_client = supabase_service if supabase_service else supabase
        if not query_client:
            raise HTTPException(status_code=500, detail="Supabase not configured")

        # Get audit from Supabase using service role to bypass RLS
        result = query_client.table('compliance_audits').select('*').eq('id', compliance_id).eq('user_id', user_id).execute()

        if not result.data:
            raise HTTPException(status_code=404, detail="Compliance audit not found")

        audit = result.data[0]

        return ComplianceResponse(
            id=audit['id'],
            url=audit['website_url'],
            site_title=audit['site_title'],
            jurisdictions=audit['jurisdictions'],
            overall_score=audit['overall_score'],
            jurisdiction_scores={j: {'jurisdiction': j, 'score': audit.get(f'{j.lower()}_score', 0), 'findings': [], 'critical_issues': []} for j in audit['jurisdictions']},
            critical_issues=audit['critical_issues'],
            remediation_roadmap=audit['remediation_roadmap'],
            created_at=audit['created_at']
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve audit: {str(e)}")


@app.get("/api/compliance/generate-pdf/{compliance_id}")
async def generate_compliance_pdf(
    compliance_id: str,
    authorization: str = Header(None),
    client_name: Optional[str] = Query(None),
    company_name: Optional[str] = Query(None),
    company_details: Optional[str] = Query(None),
):
    """
    Generate PDF report for compliance audit.

    Args:
        compliance_id: UUID of the compliance audit
        authorization: Bearer token for user authentication
        client_name: Name of the client being audited (optional)
        company_name: Name of auditing company (optional)
        company_details: Contact details for auditing company (optional)

    Returns:
        PDF file as bytes
    """
    try:
        user_id = extract_user_id_from_jwt(authorization)

        # Use service role client for reading (bypasses RLS auth check, but we verify user_id manually)
        query_client = supabase_service if supabase_service else supabase
        if not query_client:
            raise HTTPException(status_code=500, detail="Supabase not configured")

        # Get compliance audit from Supabase using service role to bypass RLS
        result = query_client.table('compliance_audits').select('*').eq('id', compliance_id).eq('user_id', user_id).execute()

        if not result.data:
            raise HTTPException(status_code=404, detail="Compliance audit not found")

        audit_data = result.data[0]

        # Import ReportLab for PDF generation
        from reportlab.lib.pagesizes import letter, A4
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
        from reportlab.lib.units import inch
        from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak
        from reportlab.lib import colors
        from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT

        # Create PDF
        pdf_path = f"/tmp/compliance_{compliance_id[:8]}.pdf"
        doc = SimpleDocTemplate(
            pdf_path,
            pagesize=letter,
            rightMargin=0.75*inch,
            leftMargin=0.75*inch,
            topMargin=0.5*inch,
            bottomMargin=0.5*inch,
        )

        elements = []
        styles = getSampleStyleSheet()

        # Create custom styles
        title_style = ParagraphStyle(
            'CustomTitle',
            parent=styles['Heading1'],
            fontSize=24,
            textColor=colors.HexColor('#1F2937'),
            spaceAfter=12,
            alignment=TA_CENTER,
            fontName='Helvetica-Bold',
        )

        heading_style = ParagraphStyle(
            'CustomHeading',
            parent=styles['Heading2'],
            fontSize=14,
            textColor=colors.HexColor('#2E68DA'),
            spaceAfter=12,
            spaceBefore=12,
            fontName='Helvetica-Bold',
        )

        # Header with company branding
        if company_name:
            elements.append(Paragraph(company_name, heading_style))
            elements.append(Spacer(1, 0.2*inch))

        elements.append(Paragraph('COMPLIANCE AUDIT REPORT', title_style))
        elements.append(Spacer(1, 0.3*inch))

        # Website info
        website_info_data = [
            ['Website URL:', audit_data['website_url']],
            ['Site Title:', audit_data['site_title'] or 'N/A'],
            ['Audit Date:', audit_data['created_at'][:10]],
            ['Jurisdictions:', ', '.join(audit_data['jurisdictions'])],
        ]

        if client_name:
            website_info_data.insert(0, ['Client Name:', client_name])

        info_table = Table(website_info_data, colWidths=[1.5*inch, 4*inch])
        info_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (0, -1), colors.HexColor('#E5E7EB')),
            ('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, -1), 10),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 12),
            ('GRID', (0, 0), (-1, -1), 1, colors.grey),
        ]))

        elements.append(info_table)
        elements.append(Spacer(1, 0.3*inch))

        # Overall score section
        elements.append(Paragraph('Overall Compliance Score', heading_style))

        score = audit_data['overall_score']
        score_color = '#10B981' if score >= 80 else '#F59E0B' if score >= 60 else '#EA580C' if score >= 40 else '#DC2626'

        score_data = [
            ['Score', 'Risk Level', 'Status'],
            [f"{score}/100", audit_data['highest_risk_level'],
             '✓ Compliant' if score >= 80 else '⚠ Review Required' if score >= 60 else '✗ Action Needed'],
        ]

        score_table = Table(score_data, colWidths=[2*inch, 2*inch, 2*inch])
        score_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#2E68DA')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, -1), 11),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 12),
            ('GRID', (0, 0), (-1, -1), 1, colors.grey),
            ('BACKGROUND', (0, 1), (-1, 1), colors.HexColor(f'{score_color}20')),
        ]))

        elements.append(score_table)
        elements.append(Spacer(1, 0.2*inch))

        # Jurisdiction scores
        elements.append(Paragraph('Compliance by Jurisdiction', heading_style))

        juris_data = [['Jurisdiction', 'Score', 'Status']]
        for jurisdiction in audit_data['jurisdictions']:
            score_key = f"{jurisdiction.lower()}_score"
            j_score = audit_data.get(score_key)
            if j_score is not None:
                status = '✓ Compliant' if j_score >= 80 else '⚠ Partial' if j_score >= 60 else '✗ Non-Compliant'
                juris_data.append([jurisdiction, f"{j_score}/100", status])

        juris_table = Table(juris_data, colWidths=[1.5*inch, 1.5*inch, 2.5*inch])
        juris_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#2E68DA')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, -1), 10),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
            ('GRID', (0, 0), (-1, -1), 1, colors.grey),
        ]))

        elements.append(juris_table)
        elements.append(Spacer(1, 0.2*inch))

        # Critical Issues
        if audit_data.get('critical_issues'):
            elements.append(Paragraph('Critical Issues', heading_style))
            for issue in audit_data['critical_issues']:
                elements.append(Paragraph(f"• {issue}", styles['Normal']))
            elements.append(Spacer(1, 0.2*inch))

        # Remediation Roadmap
        if audit_data.get('remediation_roadmap'):
            elements.append(PageBreak())
            elements.append(Paragraph('Remediation Roadmap', heading_style))

            roadmap = audit_data['remediation_roadmap']

            for period, label in [('immediate', 'Immediate (0-30 days)'),
                                 ('short_term', 'Short-term (1-3 months)'),
                                 ('long_term', 'Long-term (3-6 months)')]:
                if period in roadmap and roadmap[period]:
                    elements.append(Paragraph(f"<b>{label}</b>", styles['Heading3']))
                    for action in roadmap[period]:
                        elements.append(Paragraph(f"• {action}", styles['Normal']))
                    elements.append(Spacer(1, 0.1*inch))

        elements.append(Spacer(1, 0.3*inch))

        # Footer
        if company_details:
            footer_style = ParagraphStyle(
                'Footer',
                parent=styles['Normal'],
                fontSize=8,
                textColor=colors.HexColor('#6B7280'),
                alignment=TA_CENTER,
            )
            elements.append(Paragraph(f"<i>{company_details}</i>", footer_style))

        # Build PDF
        doc.build(elements)

        # Read PDF file
        with open(pdf_path, 'rb') as f:
            pdf_bytes = f.read()

        # Return PDF
        return FileResponse(
            path=pdf_path,
            media_type="application/pdf",
            filename=f"compliance-report_{compliance_id[:8]}.pdf"
        )

    except HTTPException:
        raise
    except Exception as e:
        sentry_sdk.capture_exception(e)
        raise HTTPException(
            status_code=500,
            detail=f"PDF generation failed: {str(e)}"
        )


# ==================== Main ====================

if __name__ == "__main__":
    import uvicorn

    # Get port from environment or use default
    port = int(os.getenv('PORT', 8000))

    uvicorn.run(
        app,
        host="0.0.0.0",
        port=port,
        log_level="info"
    )
