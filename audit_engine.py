#!/usr/bin/env python3
"""
WebAudit Pro - Core Audit Engine
Comprehensive 10-point website evaluation framework.
"""

import os
import requests
from typing import Optional, Dict, List, Tuple
from dataclasses import dataclass, asdict
from datetime import datetime
from bs4 import BeautifulSoup
from urllib.parse import urlparse
import anthropic


@dataclass
class CriterionScore:
    """Individual criterion evaluation."""
    name: str
    score: float  # 0-10
    observations: List[str]  # Strengths and weaknesses
    recommendations: List[str]  # How to improve


@dataclass
class AuditResult:
    """Complete audit evaluation result."""
    url: str
    website_name: str
    audit_timestamp: str
    overall_score: float  # 0-100
    scores: Dict[str, float]  # Each criterion: 0-10
    criteria_details: Dict[str, CriterionScore]  # Detailed breakdown
    key_strengths: List[str]  # Top 3-5 strengths
    critical_issues: List[str]  # Top 3-5 issues
    priority_recommendations: List[Dict]  # Ranked recommendations


class WebsiteAuditor:
    """
    Professional website auditor evaluating across 10 key criteria:
    1. User Experience (UX)
    2. Performance
    3. Responsiveness
    4. Visual Design
    5. Content Quality
    6. Accessibility
    7. SEO & Discovery
    8. Security
    9. Conversion Goals
    10. Technical Quality
    """

    CRITERIA = [
        "User Experience",
        "Performance",
        "Responsiveness",
        "Visual Design",
        "Content Quality",
        "Accessibility",
        "SEO & Discovery",
        "Security",
        "Conversion Goals",
        "Technical Quality"
    ]

    def __init__(self, timeout: int = 10, api_key: Optional[str] = None):
        """Initialize auditor with timeout and API key."""
        self.timeout = timeout
        self.api_key = api_key or os.getenv('ANTHROPIC_API_KEY')
        if not self.api_key:
            raise ValueError("ANTHROPIC_API_KEY environment variable not set")
        self.client = anthropic.Anthropic(api_key=self.api_key)

    def audit(self, url: str, deep_scan: bool = True) -> AuditResult:
        """
        Perform comprehensive 10-point audit of a website.

        Args:
            url: Website URL to audit
            deep_scan: Whether to perform detailed analysis (vs quick scan)

        Returns:
            AuditResult with scores, observations, and recommendations
        """
        # Normalize URL
        url = self._normalize_url(url)

        # Fetch and parse website
        html_content, page_metadata = self._fetch_website(url)

        # Extract content and structure
        content_analysis = self._analyze_content(html_content, url)

        # Evaluate each criterion using Claude
        scores = {}
        criteria_details = {}

        for criterion in self.CRITERIA:
            score, details = self._evaluate_criterion(
                criterion,
                url,
                html_content,
                page_metadata,
                content_analysis,
                deep_scan
            )
            scores[criterion] = score
            criteria_details[criterion] = details

        # Calculate overall score (average of all 10 criteria)
        overall_score = sum(scores.values()) / len(scores)

        # Extract key strengths and critical issues
        strengths = self._extract_strengths(criteria_details)
        issues = self._extract_critical_issues(criteria_details)

        # Generate priority recommendations
        recommendations = self._generate_recommendations(criteria_details, scores)

        return AuditResult(
            url=url,
            website_name=self._extract_website_name(url, page_metadata),
            audit_timestamp=datetime.utcnow().isoformat(),
            overall_score=overall_score,
            scores=scores,
            criteria_details=criteria_details,
            key_strengths=strengths,
            critical_issues=issues,
            priority_recommendations=recommendations
        )

    def _normalize_url(self, url: str) -> str:
        """Add https:// if no scheme provided."""
        if not url.startswith(('http://', 'https://')):
            url = 'https://' + url
        return url

    def _fetch_website(self, url: str) -> Tuple[str, Dict]:
        """Fetch website HTML and extract metadata."""
        try:
            response = requests.get(
                url,
                timeout=self.timeout,
                headers={
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
                }
            )
            response.raise_for_status()

            soup = BeautifulSoup(response.content, 'html.parser')

            # Extract metadata
            metadata = {
                'title': soup.find('title').text if soup.find('title') else '',
                'meta_description': self._get_meta_content(soup, 'description'),
                'og_title': self._get_meta_content(soup, 'og:title'),
                'og_description': self._get_meta_content(soup, 'og:description'),
                'viewport': self._get_meta_content(soup, 'viewport'),
                'charset': soup.find('meta', {'charset': True}) is not None,
                'https': response.url.startswith('https'),
                'status_code': response.status_code
            }

            return response.text, metadata
        except requests.RequestException as e:
            raise Exception(f"Failed to fetch website: {str(e)}")

    def _get_meta_content(self, soup: BeautifulSoup, name: str) -> str:
        """Extract meta tag content."""
        meta = soup.find('meta', {'name': name}) or soup.find('meta', {'property': name})
        return meta.get('content', '') if meta else ''

    def _extract_website_name(self, url: str, metadata: Dict) -> str:
        """Extract website name from URL or title."""
        if metadata.get('title'):
            return metadata['title'].split('|')[0].strip()
        parsed = urlparse(url)
        return parsed.netloc.replace('www.', '')

    def _analyze_content(self, html: str, url: str) -> Dict:
        """Analyze website structure and content."""
        soup = BeautifulSoup(html, 'html.parser')

        return {
            'has_h1': bool(soup.find('h1')),
            'h1_count': len(soup.find_all('h1')),
            'has_nav': bool(soup.find('nav')),
            'has_footer': bool(soup.find('footer')),
            'has_main': bool(soup.find('main')),
            'img_count': len(soup.find_all('img')),
            'img_with_alt': len([img for img in soup.find_all('img') if img.get('alt')]),
            'form_count': len(soup.find_all('form')),
            'button_count': len(soup.find_all('button')),
            'link_count': len(soup.find_all('a')),
            'broken_links': self._count_broken_links(soup, url),
            'has_sitemap': self._check_sitemap(url),
            'has_robots': self._check_robots(url),
            'word_count': len(soup.get_text().split()),
            'title_length': len(soup.find('title').text) if soup.find('title') else 0,
        }

    def _count_broken_links(self, soup: BeautifulSoup, base_url: str) -> int:
        """Count broken links (404s) - quick sample check."""
        # For performance, only check a few links
        links = soup.find_all('a', href=True)[:10]
        broken = 0
        for link in links:
            href = link.get('href')
            if href and href.startswith(('http://', 'https://')):
                try:
                    response = requests.head(href, timeout=2)
                    if response.status_code >= 400:
                        broken += 1
                except:
                    broken += 1
        return broken

    def _check_sitemap(self, url: str) -> bool:
        """Check if sitemap.xml exists."""
        try:
            parsed = urlparse(url)
            sitemap_url = f"{parsed.scheme}://{parsed.netloc}/sitemap.xml"
            response = requests.head(sitemap_url, timeout=2)
            return response.status_code == 200
        except:
            return False

    def _check_robots(self, url: str) -> bool:
        """Check if robots.txt exists."""
        try:
            parsed = urlparse(url)
            robots_url = f"{parsed.scheme}://{parsed.netloc}/robots.txt"
            response = requests.head(robots_url, timeout=2)
            return response.status_code == 200
        except:
            return False

    def _evaluate_criterion(
        self,
        criterion: str,
        url: str,
        html: str,
        metadata: Dict,
        content_analysis: Dict,
        deep_scan: bool
    ) -> Tuple[float, CriterionScore]:
        """
        Evaluate a single criterion using Claude AI.
        Returns score (0-10) and detailed observations.
        """

        # Prepare evaluation context for Claude
        evaluation_context = self._prepare_evaluation_context(
            criterion, url, metadata, content_analysis, deep_scan
        )

        # Use Claude to evaluate
        prompt = f"""You are a professional website auditor evaluating a website's {criterion}.

Website: {url}
Title: {metadata.get('title', 'N/A')}
Meta Description: {metadata.get('meta_description', 'N/A')}

Analysis Data:
{evaluation_context}

Based on this analysis, provide:
1. A score from 0-10 for {criterion}
2. 2-3 specific observations (strengths and weaknesses)
3. 2-3 concrete recommendations for improvement

Format your response as JSON:
{{
    "score": X,
    "observations": ["obs1", "obs2", "obs3"],
    "recommendations": ["rec1", "rec2", "rec3"]
}}
"""

        try:
            message = self.client.messages.create(
                model="claude-3-5-sonnet-20241022",
                max_tokens=500,
                messages=[
                    {"role": "user", "content": prompt}
                ]
            )

            # Parse Claude's response
            import json
            response_text = message.content[0].text

            # Extract JSON from response
            json_start = response_text.find('{')
            json_end = response_text.rfind('}') + 1
            if json_start >= 0 and json_end > json_start:
                json_str = response_text[json_start:json_end]
                result = json.loads(json_str)
            else:
                # Fallback if JSON parsing fails
                result = {
                    "score": 5,
                    "observations": ["Unable to fully evaluate"],
                    "recommendations": ["Review and improve"]
                }

            # Ensure score is 0-10
            score = max(0, min(10, float(result.get("score", 5))))

            return score, CriterionScore(
                name=criterion,
                score=score,
                observations=result.get("observations", []),
                recommendations=result.get("recommendations", [])
            )

        except Exception as e:
            # Fallback scoring on error
            return 5.0, CriterionScore(
                name=criterion,
                score=5.0,
                observations=[f"Evaluation encountered an issue: {str(e)}"],
                recommendations=["Manual review recommended"]
            )

    def _prepare_evaluation_context(
        self,
        criterion: str,
        url: str,
        metadata: Dict,
        content_analysis: Dict,
        deep_scan: bool
    ) -> str:
        """Prepare context data for Claude evaluation of a criterion."""

        context_map = {
            "User Experience": f"""
                - Has navigation menu: {content_analysis.get('has_nav')}
                - Has clear main content: {content_analysis.get('has_main')}
                - Button count: {content_analysis.get('button_count')}
                - Meta viewport: {metadata.get('viewport') is not None}
                - Broken links (sample): {content_analysis.get('broken_links')}
            """,
            "Performance": f"""
                - Resource optimization indicators
                - Image count: {content_analysis.get('img_count')}
                - Form complexity: {content_analysis.get('form_count')} forms
                - Script/CSS optimization potential
            """,
            "Mobile Responsiveness": f"""
                - Has viewport meta tag: {metadata.get('viewport') is not None}
                - Responsive design indicators needed
                - Touch-friendly button count: {content_analysis.get('button_count')}
            """,
            "Visual Design": f"""
                - Title present: {bool(metadata.get('title'))}
                - Design structure indicators
                - Image usage: {content_analysis.get('img_count')} images
            """,
            "Content Quality": f"""
                - Title length: {metadata.get('title_length')} chars
                - Meta description: {metadata.get('meta_description') is not None}
                - Word count: {content_analysis.get('word_count')} words
                - Heading structure: H1 count = {content_analysis.get('h1_count')}
            """,
            "Accessibility": f"""
                - Images with alt text: {content_analysis.get('img_with_alt')}/{content_analysis.get('img_count')}
                - Has heading hierarchy: {content_analysis.get('has_h1')}
                - Form fields count: {content_analysis.get('form_count')}
                - Charset defined: {metadata.get('charset')}
            """,
            "SEO & Discoverability": f"""
                - Sitemap.xml exists: {content_analysis.get('has_sitemap')}
                - Robots.txt exists: {content_analysis.get('has_robots')}
                - Meta description: {metadata.get('meta_description') is not None}
                - Open Graph tags: {metadata.get('og_title') is not None}
            """,
            "Security": f"""
                - HTTPS enabled: {metadata.get('https')}
                - HTTP status: {metadata.get('status_code')}
                - Charset defined: {metadata.get('charset')}
            """,
            "Conversion/Goal Achievement": f"""
                - Has forms: {content_analysis.get('form_count')} forms
                - CTA buttons: {content_analysis.get('button_count')} buttons
                - Meta description clarity: {len(metadata.get('meta_description', ''))} chars
            """,
            "Technical Quality": f"""
                - Valid HTML structure
                - HTTP status: {metadata.get('status_code')}
                - Link integrity: {content_analysis.get('broken_links')} broken (sample)
                - Navigation structure: {content_analysis.get('has_nav')}
            """
        }

        return context_map.get(criterion, "General analysis data available")

    def _extract_strengths(self, criteria_details: Dict[str, CriterionScore]) -> List[str]:
        """Extract top 3-5 key strengths from all criteria."""
        strengths = []

        # Get high-scoring criteria
        high_scores = sorted(
            [(name, detail.score) for name, detail in criteria_details.items()],
            key=lambda x: x[1],
            reverse=True
        )

        # Take top observations from highest-scoring criteria
        for criterion_name, score in high_scores[:3]:
            detail = criteria_details[criterion_name]
            if detail.observations:
                strengths.extend(detail.observations[:1])

        return strengths[:5]

    def _extract_critical_issues(self, criteria_details: Dict[str, CriterionScore]) -> List[str]:
        """Extract top 3-5 critical issues from all criteria."""
        issues = []

        # Get low-scoring criteria
        low_scores = sorted(
            [(name, detail.score) for name, detail in criteria_details.items()],
            key=lambda x: x[1]
        )

        # Take bottom observations from lowest-scoring criteria
        for criterion_name, score in low_scores[:3]:
            detail = criteria_details[criterion_name]
            if detail.observations:
                # Get the negative observation (usually 2nd or 3rd)
                issues.extend(detail.observations[1:])

        return issues[:5]

    def _generate_recommendations(
        self,
        criteria_details: Dict[str, CriterionScore],
        scores: Dict[str, float]
    ) -> List[Dict]:
        """Generate prioritized recommendations based on scores."""
        recommendations = []

        # Score all recommendations with priority
        all_recs = []
        for criterion, score in scores.items():
            detail = criteria_details[criterion]
            priority = "High" if score < 5 else "Medium" if score < 7 else "Low"

            for i, rec in enumerate(detail.recommendations):
                all_recs.append({
                    "criterion": criterion,
                    "recommendation": rec,
                    "priority": priority,
                    "impact_score": max(0, 10 - score),  # Higher impact = lower score
                    "order": i
                })

        # Sort by priority and impact
        priority_order = {"High": 0, "Medium": 1, "Low": 2}
        all_recs.sort(
            key=lambda x: (priority_order[x["priority"]], -x["impact_score"], x["order"])
        )

        # Return top 10 recommendations
        return all_recs[:10]

    def to_dict(self, result: AuditResult) -> Dict:
        """Convert AuditResult to dictionary for JSON serialization."""
        return {
            "url": result.url,
            "website_name": result.website_name,
            "audit_timestamp": result.audit_timestamp,
            "overall_score": round(result.overall_score, 1),
            "scores": {k: round(v, 1) for k, v in result.scores.items()},
            "criteria_details": {
                k: {
                    "score": round(v.score, 1),
                    "observations": v.observations,
                    "recommendations": v.recommendations
                }
                for k, v in result.criteria_details.items()
            },
            "key_strengths": result.key_strengths,
            "critical_issues": result.critical_issues,
            "priority_recommendations": result.priority_recommendations
        }
