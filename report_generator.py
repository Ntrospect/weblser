#!/usr/bin/env python3
"""
WebAudit Pro - PDF Report Generator
Generates 3 professional PDF documents:
1. Website Audit Report (diagnostic)
2. Website Improvement Plan (strategic)
3. Digital Partnership Proposal (engagement)
"""

import os
from datetime import datetime
from typing import Dict, List, Optional
from io import BytesIO

from reportlab.lib import colors
from reportlab.lib.pagesizes import letter, A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
    PageBreak, Image, KeepTogether
)
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT, TA_JUSTIFY


class WebAuditReportGenerator:
    """Generates professional PDF reports for website audits."""

    # Brand colors
    COLOR_PRIMARY = colors.HexColor("#2563eb")  # Blue
    COLOR_ACCENT = colors.HexColor("#7c3aed")  # Purple
    COLOR_SUCCESS = colors.HexColor("#16a34a")  # Green
    COLOR_WARNING = colors.HexColor("#ea580c")  # Orange
    COLOR_DANGER = colors.HexColor("#dc2626")  # Red
    COLOR_TEXT = colors.HexColor("#1f2937")  # Dark Gray
    COLOR_LIGHT = colors.HexColor("#f3f4f6")  # Light Gray

    def __init__(self, logo_path: Optional[str] = None):
        """Initialize report generator."""
        self.logo_path = logo_path or self._get_default_logo()
        self.styles = self._create_styles()

    def _get_default_logo(self) -> Optional[str]:
        """Get default logo path if available."""
        possible_paths = [
            "weblser_logo.png",
            "/app/weblser_logo.png",
            "C:\\Users\\Ntro\\weblser\\weblser_logo.png"
        ]
        for path in possible_paths:
            if os.path.exists(path):
                return path
        return None

    def _create_styles(self) -> Dict:
        """Create custom paragraph styles."""
        styles = getSampleStyleSheet()

        # Override defaults
        styles['Normal'].textColor = self.COLOR_TEXT
        styles['Normal'].fontName = 'Helvetica'

        # Custom styles - only add if they don't already exist
        custom_styles = [
            ('CustomTitle', ParagraphStyle(
                name='CustomTitle',
                parent=styles['Heading1'],
                fontSize=28,
                textColor=self.COLOR_PRIMARY,
                spaceAfter=12,
                alignment=TA_CENTER,
                fontName='Helvetica-Bold'
            )),
            ('SectionHeader', ParagraphStyle(
                name='SectionHeader',
                parent=styles['Heading2'],
                fontSize=14,
                textColor=self.COLOR_ACCENT,
                spaceAfter=8,
                spaceBefore=8,
                fontName='Helvetica-Bold'
            )),
            ('SubHeader', ParagraphStyle(
                name='SubHeader',
                parent=styles['Heading3'],
                fontSize=11,
                textColor=self.COLOR_TEXT,
                spaceAfter=6,
                fontName='Helvetica-Bold'
            )),
            ('BodyText', ParagraphStyle(
                name='BodyText',
                parent=styles['Normal'],
                fontSize=10,
                alignment=TA_JUSTIFY,
                spaceAfter=6
            )),
        ]

        for style_name, style in custom_styles:
            if style_name not in styles:
                styles.add(style)

        return styles

    def generate_audit_report(
        self,
        audit_data: Dict,
        output_path: str,
        company_name: str = "WebAudit Pro",
        company_details: str = ""
    ) -> str:
        """
        Generate Website Audit Report (diagnostic, free teaser).

        Args:
            audit_data: Complete audit result dictionary
            output_path: Path to save PDF
            company_name: Company/organization name for footer
            company_details: Contact details for footer

        Returns:
            Path to generated PDF
        """
        doc = SimpleDocTemplate(
            output_path,
            pagesize=letter,
            rightMargin=0.75*inch,
            leftMargin=0.75*inch,
            topMargin=0.75*inch,
            bottomMargin=0.75*inch
        )

        elements = []

        # Header with logo
        elements.append(self._create_header("Website Audit Report"))
        elements.append(Spacer(1, 0.3*inch))

        # Website summary
        elements.append(self._create_audit_summary(audit_data))
        elements.append(Spacer(1, 0.3*inch))

        # Overall score prominent display
        elements.append(self._create_overall_score_display(audit_data['overall_score']))
        elements.append(Spacer(1, 0.3*inch))

        # All 10 criterion scores
        elements.append(Paragraph("10-Point Evaluation", self.styles['SectionHeader']))
        elements.append(self._create_scores_table(audit_data['scores']))
        elements.append(Spacer(1, 0.2*inch))

        # Key strengths
        elements.append(Paragraph("Key Strengths", self.styles['SectionHeader']))
        for strength in audit_data.get('key_strengths', [])[:5]:
            elements.append(Paragraph(
                f"• {strength}",
                self.styles['BodyText']
            ))
        elements.append(Spacer(1, 0.2*inch))

        # Critical issues
        elements.append(Paragraph("Critical Issues", self.styles['SectionHeader']))
        for issue in audit_data.get('critical_issues', [])[:5]:
            elements.append(Paragraph(
                f"• {issue}",
                self.styles['BodyText']
            ))
        elements.append(Spacer(1, 0.2*inch))

        # Call to action
        elements.append(self._create_cta_box(
            "Next Steps",
            "Ready to improve your website performance? "
            "Get a detailed Website Improvement Plan with actionable recommendations."
        ))

        # Footer
        elements.append(Spacer(1, 0.3*inch))
        elements.append(self._create_footer(company_name, company_details))

        # Build PDF
        doc.build(elements)
        return output_path

    def generate_improvement_plan(
        self,
        audit_data: Dict,
        output_path: str,
        client_name: str = "Client",
        company_name: str = "WebAudit Pro",
        company_details: str = ""
    ) -> str:
        """
        Generate Website Improvement Plan (strategic, paid).

        Args:
            audit_data: Complete audit result dictionary
            output_path: Path to save PDF
            client_name: Name of the client/website
            company_name: Your company name
            company_details: Your contact details

        Returns:
            Path to generated PDF
        """
        doc = SimpleDocTemplate(
            output_path,
            pagesize=letter,
            rightMargin=0.75*inch,
            leftMargin=0.75*inch,
            topMargin=0.75*inch,
            bottomMargin=0.75*inch
        )

        elements = []

        # Header
        elements.append(self._create_header(f"Website Improvement Plan - {client_name}"))
        elements.append(Spacer(1, 0.3*inch))

        # Executive summary
        elements.append(Paragraph("Executive Summary", self.styles['SectionHeader']))
        elements.append(Paragraph(
            f"This improvement plan is based on a comprehensive audit of <b>{audit_data['website_name']}</b>. "
            f"The website scored <b>{audit_data['overall_score']:.1f}/10</b> across 10 key evaluation criteria. "
            f"Below are prioritized recommendations to elevate your digital performance.",
            self.styles['BodyText']
        ))
        elements.append(Spacer(1, 0.2*inch))

        # Audit scores recap
        elements.append(Paragraph("Current Performance Scores", self.styles['SectionHeader']))
        elements.append(self._create_scores_table(audit_data['scores']))
        elements.append(Spacer(1, 0.3*inch))

        # Priority recommendations
        elements.append(Paragraph("Priority Recommendations", self.styles['SectionHeader']))

        for i, rec in enumerate(audit_data.get('priority_recommendations', [])[:10], 1):
            elements.append(self._create_recommendation_box(
                i,
                rec.get('criterion', 'General'),
                rec.get('recommendation', 'Recommendation'),
                rec.get('priority', 'Medium')
            ))
            elements.append(Spacer(1, 0.15*inch))

        # Implementation timeline
        elements.append(PageBreak())
        elements.append(Paragraph("Implementation Timeline", self.styles['SectionHeader']))
        elements.append(self._create_implementation_timeline())
        elements.append(Spacer(1, 0.2*inch))

        # Expected outcomes
        elements.append(Paragraph("Expected Outcomes", self.styles['SectionHeader']))
        elements.append(Paragraph(
            "By implementing these recommendations, you can expect:",
            self.styles['BodyText']
        ))
        for outcome in [
            "Improved user experience and conversion rates",
            "Better search engine visibility",
            "Enhanced security and data protection",
            "Faster page load times",
            "Increased mobile accessibility"
        ]:
            elements.append(Paragraph(f"• {outcome}", self.styles['BodyText']))

        elements.append(Spacer(1, 0.3*inch))

        # CTA
        elements.append(self._create_cta_box(
            "Ready to Implement?",
            "Partner with us to execute this improvement plan. "
            "We'll manage the technical implementation and track measurable results."
        ))

        # Footer
        elements.append(Spacer(1, 0.3*inch))
        elements.append(self._create_footer(company_name, company_details))

        # Build PDF
        doc.build(elements)
        return output_path

    def generate_partnership_proposal(
        self,
        audit_data: Dict,
        output_path: str,
        client_name: str = "Client",
        company_name: str = "WebAudit Pro",
        company_details: str = ""
    ) -> str:
        """
        Generate Digital Partnership Proposal (engagement contract).

        Args:
            audit_data: Complete audit result dictionary
            output_path: Path to save PDF
            client_name: Name of the client
            company_name: Your company name
            company_details: Your contact details

        Returns:
            Path to generated PDF
        """
        doc = SimpleDocTemplate(
            output_path,
            pagesize=letter,
            rightMargin=0.75*inch,
            leftMargin=0.75*inch,
            topMargin=0.75*inch,
            bottomMargin=0.75*inch
        )

        elements = []

        # Header
        elements.append(self._create_header(f"Digital Partnership Proposal - {client_name}"))
        elements.append(Spacer(1, 0.3*inch))

        # Executive summary
        elements.append(Paragraph("The Opportunity", self.styles['SectionHeader']))
        elements.append(Paragraph(
            f"Based on our recent evaluation, <b>{audit_data['website_name']}</b> has significant opportunities "
            f"for digital transformation. With a current score of <b>{audit_data['overall_score']:.1f}/10</b>, "
            f"strategic improvements could increase traffic, engagement, and conversions.",
            self.styles['BodyText']
        ))
        elements.append(Spacer(1, 0.2*inch))

        # Our approach
        elements.append(Paragraph("Our Approach", self.styles['SectionHeader']))
        elements.append(Paragraph(
            "We'll work collaboratively to implement improvements across all aspects of your digital presence:",
            self.styles['BodyText']
        ))
        for point in [
            "<b>Discovery & Planning:</b> Align on goals and create a phased roadmap",
            "<b>Implementation:</b> Execute improvements with professional quality assurance",
            "<b>Monitoring & Optimization:</b> Track metrics and continuously refine performance"
        ]:
            elements.append(Paragraph(f"• {point}", self.styles['BodyText']))
        elements.append(Spacer(1, 0.2*inch))

        # Scope & deliverables
        elements.append(Paragraph("Scope & Deliverables", self.styles['SectionHeader']))
        elements.append(self._create_deliverables_table())
        elements.append(Spacer(1, 0.2*inch))

        # Timeline & phases
        elements.append(PageBreak())
        elements.append(Paragraph("Timeline & Engagement Options", self.styles['SectionHeader']))
        elements.append(self._create_engagement_options())
        elements.append(Spacer(1, 0.3*inch))

        # Pricing
        elements.append(Paragraph("Investment & Pricing", self.styles['SectionHeader']))
        elements.append(Paragraph(
            "We offer flexible partnership models based on your needs and timeline:",
            self.styles['BodyText']
        ))
        elements.append(Spacer(1, 0.1*inch))
        elements.append(self._create_pricing_table())
        elements.append(Spacer(1, 0.3*inch))

        # Next steps
        elements.append(Paragraph("Next Steps", self.styles['SectionHeader']))
        elements.append(Paragraph(
            "1. Review this proposal and our approach<br/>"
            "2. Schedule a 30-minute consultation to discuss your goals<br/>"
            "3. Agree on timeline and deliverables<br/>"
            "4. Begin implementation<br/>",
            self.styles['BodyText']
        ))
        elements.append(Spacer(1, 0.2*inch))

        # CTA
        elements.append(self._create_cta_box(
            "Ready to Partner?",
            f"Contact us today to discuss your digital transformation journey. "
            f"We're excited to help you achieve your goals!"
        ))

        # Footer
        elements.append(Spacer(1, 0.3*inch))
        elements.append(self._create_footer(company_name, company_details))

        # Build PDF
        doc.build(elements)
        return output_path

    # ==================== Helper Methods ====================

    def _create_header(self, title: str) -> Paragraph:
        """Create document header with title."""
        return Paragraph(title, self.styles['CustomTitle'])

    def _create_audit_summary(self, audit_data: Dict) -> Table:
        """Create summary table of audit data."""
        data = [
            ["Website", audit_data.get('website_name', 'N/A')],
            ["URL", audit_data.get('url', 'N/A')],
            ["Audit Date", datetime.fromisoformat(audit_data['audit_timestamp']).strftime("%B %d, %Y")],
            ["Overall Score", f"{audit_data['overall_score']:.1f}/10"]
        ]

        table = Table(data, colWidths=[1.5*inch, 3.5*inch])
        table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (0, -1), self.COLOR_LIGHT),
            ('TEXTCOLOR', (0, 0), (-1, -1), self.COLOR_TEXT),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, -1), 10),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
            ('TOPPADDING', (0, 0), (-1, -1), 8),
            ('GRID', (0, 0), (-1, -1), 1, colors.grey)
        ]))
        return table

    def _create_overall_score_display(self, score: float) -> Table:
        """Create prominent overall score display."""
        data = [[f"{score:.1f}", "/ 100"]]
        table = Table(data, colWidths=[2*inch, 1*inch])
        table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, -1), self.COLOR_PRIMARY),
            ('TEXTCOLOR', (0, 0), (-1, -1), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('FONTNAME', (0, 0), (0, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (0, 0), 48),
            ('FONTSIZE', (1, 0), (1, 0), 20),
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('PADDING', (0, 0), (-1, -1), 20),
        ]))
        return table

    def _create_scores_table(self, scores: Dict[str, float]) -> Table:
        """Create table of 10 criterion scores."""
        data = [["Criterion", "Score", "Status"]]

        for criterion, score in scores.items():
            if score >= 8:
                status = "✓ Excellent"
                color = self.COLOR_SUCCESS
            elif score >= 6:
                status = "◐ Good"
                color = self.COLOR_WARNING
            else:
                status = "✗ Needs Work"
                color = self.COLOR_DANGER

            data.append([criterion, f"{score:.1f}/10", status])

        table = Table(data, colWidths=[2.5*inch, 1*inch, 1.5*inch])
        table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), self.COLOR_PRIMARY),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 11),
            ('FONTSIZE', (0, 1), (-1, -1), 9),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, self.COLOR_LIGHT]),
            ('GRID', (0, 0), (-1, -1), 1, colors.grey),
            ('PADDING', (0, 0), (-1, -1), 8),
        ]))
        return table

    def _create_recommendation_box(
        self,
        number: int,
        criterion: str,
        recommendation: str,
        priority: str
    ) -> Table:
        """Create a styled recommendation box."""
        priority_color = {
            "High": self.COLOR_DANGER,
            "Medium": self.COLOR_WARNING,
            "Low": self.COLOR_SUCCESS
        }.get(priority, self.COLOR_TEXT)

        data = [[
            f"<b>{number}.</b>",
            f"<b>{criterion}</b><br/>{recommendation}<br/><font color='#666666' size='8'>"
            f"Priority: {priority}</font>"
        ]]

        table = Table(data, colWidths=[0.4*inch, 3.85*inch])
        table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, -1), self.COLOR_LIGHT),
            ('TEXTCOLOR', (0, 0), (-1, -1), self.COLOR_TEXT),
            ('ALIGN', (0, 0), (0, 0), 'CENTER'),
            ('ALIGN', (1, 0), (1, 0), 'LEFT'),
            ('VALIGN', (0, 0), (-1, -1), 'TOP'),
            ('FONTSIZE', (0, 0), (-1, -1), 9),
            ('LEFTPADDING', (0, 0), (-1, -1), 10),
            ('RIGHTPADDING', (0, 0), (-1, -1), 10),
            ('TOPPADDING', (0, 0), (-1, -1), 8),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
            ('BORDER', (0, 0), (-1, -1), 1, priority_color),
        ]))
        return table

    def _create_implementation_timeline(self) -> Table:
        """Create implementation timeline table."""
        data = [
            ["Phase", "Timeline", "Focus Areas"],
            ["Phase 1: Quick Wins", "Weeks 1-2", "Performance, Security, Accessibility"],
            ["Phase 2: Design & UX", "Weeks 3-6", "Visual Design, Mobile Responsiveness, UX"],
            ["Phase 3: Content & SEO", "Weeks 7-10", "Content Quality, SEO, Conversion Optimization"]
        ]

        table = Table(data, colWidths=[1.5*inch, 1.5*inch, 1.5*inch])
        table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), self.COLOR_ACCENT),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 10),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, self.COLOR_LIGHT]),
            ('GRID', (0, 0), (-1, -1), 1, colors.grey),
            ('PADDING', (0, 0), (-1, -1), 8),
        ]))
        return table

    def _create_deliverables_table(self) -> Table:
        """Create deliverables/scope table."""
        data = [
            ["Deliverable", "Description"],
            ["Initial Audit", "Comprehensive 10-point website evaluation"],
            ["Improvement Plan", "Prioritized recommendations with timelines"],
            ["Implementation", "Professional execution of planned improvements"],
            ["Monitoring", "Monthly performance reports and optimization"],
            ["Support", "Ongoing technical support and consultation"]
        ]

        table = Table(data, colWidths=[2*inch, 2.5*inch])
        table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), self.COLOR_PRIMARY),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 10),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, self.COLOR_LIGHT]),
            ('GRID', (0, 0), (-1, -1), 1, colors.grey),
            ('VALIGN', (0, 0), (-1, -1), 'TOP'),
            ('PADDING', (0, 0), (-1, -1), 8),
        ]))
        return table

    def _create_engagement_options(self) -> Table:
        """Create engagement options table."""
        data = [
            ["Option", "Duration", "Scope"],
            ["Quick Start", "3 months", "Priority improvements + monthly monitoring"],
            ["Standard", "6 months", "Full plan implementation + optimization"],
            ["Premium", "12 months", "Complete transformation + ongoing strategy"]
        ]

        table = Table(data, colWidths=[1.5*inch, 1.5*inch, 1.5*inch])
        table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), self.COLOR_ACCENT),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, self.COLOR_LIGHT]),
            ('GRID', (0, 0), (-1, -1), 1, colors.grey),
            ('PADDING', (0, 0), (-1, -1), 8),
        ]))
        return table

    def _create_pricing_table(self) -> Table:
        """Create pricing table."""
        data = [
            ["Package", "Duration", "Investment"],
            ["Quick Start", "3 months", "Contact for quote"],
            ["Standard", "6 months", "Contact for quote"],
            ["Premium", "12 months", "Contact for quote"]
        ]

        table = Table(data, colWidths=[1.5*inch, 1.5*inch, 1.5*inch])
        table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), self.COLOR_PRIMARY),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, self.COLOR_LIGHT]),
            ('GRID', (0, 0), (-1, -1), 1, colors.grey),
            ('PADDING', (0, 0), (-1, -1), 8),
        ]))
        return table

    def _create_cta_box(self, title: str, text: str) -> Table:
        """Create call-to-action box."""
        data = [[f"<b>{title}</b><br/><br/>{text}"]]
        table = Table(data, colWidths=[4*inch])
        table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, -1), self.COLOR_ACCENT),
            ('TEXTCOLOR', (0, 0), (-1, -1), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('FONTSIZE', (0, 0), (-1, -1), 10),
            ('PADDING', (0, 0), (-1, -1), 15),
            ('BORDER', (0, 0), (-1, -1), 0),
        ]))
        return table

    def _create_footer(self, company_name: str, company_details: str) -> Table:
        """Create document footer."""
        footer_text = f"<b>{company_name}</b><br/>{company_details}<br/><br/>" \
                     f"© {datetime.now().year} {company_name}. All rights reserved."

        data = [[footer_text]]
        table = Table(data, colWidths=[4.25*inch])
        table.setStyle(TableStyle([
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('FONTSIZE', (0, 0), (-1, -1), 8),
            ('TEXTCOLOR', (0, 0), (-1, -1), colors.grey),
            ('TOPPADDING', (0, 0), (-1, -1), 10),
            ('BORDER', (0, 0), (-1, -1), 0),
        ]))
        return table
