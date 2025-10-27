#!/usr/bin/env python3
"""
FastAPI backend server for weblser + WebAudit Pro.
Provides REST API endpoints for website analysis, comprehensive audits, PDF generation, and history management.

Endpoints:
- /api/analyze/* - Original weblser summary analysis
- /api/audit/* - WebAudit Pro 10-point comprehensive audit
"""

import json
import os
import uuid
from datetime import datetime
from pathlib import Path
from typing import Optional, List, Dict
from io import BytesIO

import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration
from sentry_sdk.integrations.httpx import HttpxIntegration
from fastapi import FastAPI, HTTPException, Query
from fastapi.responses import FileResponse, StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

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
async def analyze_url(request: AnalyzeRequest):
    """
    Analyze a website and generate a summary.

    Args:
        request: AnalyzeRequest with URL and optional timeout

    Returns:
        AnalysisResult with ID, URL, title, description, and summary
    """
    try:
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

        # Store in history
        history = get_history()
        history[analysis_id] = {
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
async def get_history_list(limit: int = Query(100, ge=1, le=1000)):
    """
    Get analysis history.

    Args:
        limit: Maximum number of analyses to return

    Returns:
        HistoryResponse with list of analyses
    """
    history = get_history()

    # Sort by created_at (newest first)
    sorted_analyses = sorted(
        history.items(),
        key=lambda x: x[1]['created_at'],
        reverse=True
    )[:limit]

    analyses = [
        AnalysisResult(id=aid, **data)
        for aid, data in sorted_analyses
    ]

    return HistoryResponse(
        analyses=analyses,
        total=len(history)
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
async def audit_website(request: AuditRequest):
    """
    Perform comprehensive 10-point audit of a website.

    Args:
        request: AuditRequest with URL and optional settings

    Returns:
        AuditResponse with overall score, 10 criterion scores, and recommendations
    """
    try:
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

        # Store in history
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

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Audit failed: {str(e)}"
        )


@app.get("/api/audit/{audit_id}", response_model=AuditResponse)
async def get_audit(audit_id: str):
    """
    Retrieve a specific audit by ID.

    Args:
        audit_id: UUID of the audit

    Returns:
        AuditResponse
    """
    audit_history = get_audit_history()
    if audit_id not in audit_history:
        raise HTTPException(status_code=404, detail="Audit not found")

    audit_data = audit_history[audit_id]
    return AuditResponse(
        id=audit_id,
        **audit_data
    )


@app.get("/api/audit/history/list", response_model=AuditHistoryResponse)
async def get_audit_history_list(limit: int = Query(100, ge=1, le=1000)):
    """
    Get audit history.

    Args:
        limit: Maximum number of audits to return

    Returns:
        AuditHistoryResponse with list of audits
    """
    audit_history = get_audit_history()

    # Sort by audit_timestamp (newest first)
    sorted_audits = sorted(
        audit_history.items(),
        key=lambda x: x[1]['audit_timestamp'],
        reverse=True
    )[:limit]

    audits = [
        AuditResponse(id=aid, **data)
        for aid, data in sorted_audits
    ]

    return AuditHistoryResponse(
        audits=audits,
        total=len(audit_history)
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
