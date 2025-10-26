# Professional PDF Generation Guide

## Overview

The Websler Pro PDF generation system has been completely redesigned to support professional, pixel-perfect reports using **Playwright and HTML/CSS** rendering instead of ReportLab. This enables:

✅ **Professional Branding** - Exact color matching with Jumoki/Websler design system
✅ **Light & Dark Themes** - Full support for both theme variants
✅ **Multiple Report Types** - Summary reports and comprehensive audit reports
✅ **Pixel-Perfect Rendering** - HTML/CSS provides exact control over layout and styling
✅ **Responsive Design** - Optimized for printing and PDF export
✅ **Font Support** - Google Fonts (Raleway) for professional typography

---

## Architecture

### Files Created

**1. CSS Stylesheet** (`report_styles.css`)
- Base stylesheet with Raleway typography
- Light theme colors (#F4F3F2, #7c3aed, #2052b6)
- Dark theme colors (#0F1419, #1A1F2E)
- Print-optimized media queries
- Component styles (tables, badges, recommendations, etc.)

**2. HTML Templates** (`templates/`)
- `summary_report_light.html` - Light theme summary reports
- `summary_report_dark.html` - Dark theme summary reports
- `audit_report_light.html` - Light theme audit reports
- `audit_report_dark.html` - Dark theme audit reports

**3. Python Integration** (Enhanced `analyzer.py`)
- New `generate_pdf_playwright()` method
- Jinja2 template rendering engine
- Base64 image embedding for logos
- Playwright browser automation for PDF generation

### Dependencies

New packages added to `requirements.txt`:
- `playwright>=1.40.0` - Browser automation for PDF rendering
- `jinja2>=3.1.0` - Template engine for HTML generation

Install with:
```bash
pip install -r requirements.txt

# First time only: Install Playwright browsers
python -m playwright install chromium
```

---

## Usage

### Command Line Interface

#### Generate Summary Report (Light Theme - Default)
```bash
python analyzer.py https://example.com --pdf --use-playwright
```

#### Generate Summary Report (Dark Theme)
```bash
python analyzer.py https://example.com --pdf --use-playwright --theme dark
```

#### Generate Audit Report (Light Theme)
```bash
python analyzer.py https://example.com --pdf --use-playwright --audit
```

#### Generate Audit Report (Dark Theme)
```bash
python analyzer.py https://example.com --pdf --use-playwright --audit --theme dark
```

#### With Company Branding
```bash
python analyzer.py https://example.com --pdf --use-playwright \
  --company-name "Jumoki Agency LLC" \
  --company-details "1309 Coffeen Avenue STE 1200, Sheridan WY 82801, 1(307)650-2395, info@jumoki.agency"
```

#### With Custom Output Path
```bash
python analyzer.py https://example.com --pdf --use-playwright \
  --output "my-custom-report.pdf"
```

#### With Logo
```bash
python analyzer.py https://example.com --pdf --use-playwright \
  --logo "path/to/logo.png" \
  --company-name "Your Company"
```

---

## Report Types

### Summary Report

**Purpose**: Quick AI-generated analysis of a website
**Best for**: Initial assessment, marketing research, competitive analysis

**Sections**:
1. Header with Websler/Jumoki logos
2. Report title and subtitle
3. Analyzed URL metadata
4. Page title extracted from site
5. Meta description
6. AI-generated summary (2-3 sentences)
7. Analysis details table
8. "Upgrade to Pro" call-to-action
9. Footer with company info

**Output**: `domain-summary-report.pdf`

### Audit Report

**Purpose**: Comprehensive 10-point website evaluation
**Best for**: Client deliverables, detailed assessments, improvement tracking

**Sections**:
1. Header with logos
2. Report title and subtitle
3. Audited website URL
4. Overall score (large, prominent display)
5. Page title and meta description
6. Detailed scores table (10 categories)
7. Executive summary
8. Recommendations (with priority levels)
9. Notable strengths section
10. Report metadata (date, model used, etc.)
11. Next steps guidance
12. Footer with contact information

**Output**: `domain-webaudit-report.pdf`

---

## Design System Integration

### Colors (From Flutter Theme)

**Light Theme**:
- Background: `#F4F3F2` (primary), `#FFFFFF` (lighter)
- Text: `#0B1220` (primary), `#6B7280` (secondary)
- Primary Accent: `#7c3aed` (Jumoki Purple)
- Secondary Accent: `#2052b6` (Jumoki Blue)
- Success: `#10B981`
- Warning: `#F59E0B`
- Error: `#EF4444`
- Info: `#3B82F6`

**Dark Theme**:
- Background: `#0F1419` (primary), `#1A1F2E` (lighter)
- Text: `#FFFFFF` (primary), `#B0B5C1` (secondary)
- Borders: `#3A4452`
- Same accent colors (purple & blue)
- Same status colors

### Typography

- **Font Family**: Raleway (Google Fonts)
- **Heading 1**: 28pt, weight 800
- **Heading 2**: 16pt, weight 700
- **Section Heading**: 13pt, weight 600
- **Body**: 11pt, weight 400, line-height 1.6
- **Small**: 9-10pt for metadata and footers

### Component Styles

**Tables**:
- Header: Purple background (#7c3aed) with white text
- Rows: Alternating light/dark background
- Borders: 1px solid separator lines
- Font: 10pt, bold headers

**Recommendation Items**:
- Left border: 3px solid blue (#2052b6)
- Background: Light background color
- Priority badges: Color-coded (Red/Amber/Green)
- Icons: ✓ for strengths, numbered for recommendations

**Score Badges**:
- Excellent (8-10): Green (#10B981)
- Good (6-8): Cyan (#06B6D4)
- Fair (4-6): Amber (#F59E0B)
- Poor (0-4): Red (#EF4444)

---

## Python Integration

### Using the New Method

```python
from analyzer import WebsiteAnalyzer

analyzer = WebsiteAnalyzer()

# Analyze a website
result = analyzer.analyze('https://example.com')

# Generate summary report (Playwright)
pdf_path = analyzer.generate_pdf_playwright(
    result,
    is_audit=False,
    use_dark_theme=False,
    company_name="Your Company",
    company_details="123 Main St, City, State 12345"
)
print(f"PDF created: {pdf_path}")

# Generate audit report with custom data
audit_data = {
    'overall_score': 7.5,
    'categories': [
        {'name': 'Performance', 'score': 8},
        {'name': 'SEO', 'score': 7},
        {'name': 'Security', 'score': 6},
        # ... more categories
    ],
    'recommendations': [
        {
            'title': 'Implement HTTPS',
            'description': 'Currently using HTTP, upgrade to HTTPS...',
            'priority': 'high',
            'impact': 'Critical for security and SEO'
        },
        # ... more recommendations
    ],
    'strengths': [
        {
            'title': 'Fast Load Time',
            'description': 'Website loads in under 2 seconds'
        },
        # ... more strengths
    ]
}

pdf_path = analyzer.generate_pdf_playwright(
    result,
    is_audit=True,
    use_dark_theme=True,
    audit_data=audit_data
)
```

---

## Customization

### Changing Colors

Edit `report_styles.css` and update CSS variables:

```css
:root {
  --bg-primary: #F4F3F2;      /* Change light background */
  --text-primary: #0B1220;     /* Change primary text */
  --accent-primary: #7c3aed;   /* Change primary color */
  --accent-secondary: #2052b6; /* Change secondary color */
}

body.dark-theme {
  --bg-primary: #0F1419;       /* Change dark background */
  /* ... */
}
```

### Changing Fonts

Edit the `@import` line in `report_styles.css`:

```css
@import url('https://fonts.googleapis.com/css2?family=YOUR-FONT:wght@400;600;700&display=swap');

html, body {
  font-family: 'YOUR-FONT', sans-serif;
}
```

### Modifying Templates

Edit the HTML templates to:
- Add new sections
- Change heading text
- Add company-specific sections
- Include custom branding elements

Example - Add a custom section:

```html
<!-- CUSTOM SECTION -->
<div class="content-section">
  <div class="section-heading">Custom Analysis</div>
  <div class="summary-content">
    <p>Your custom content here</p>
  </div>
</div>
```

---

## Troubleshooting

### Issue: "Playwright not installed"

**Solution**: Install Playwright and browser binaries:
```bash
pip install playwright
python -m playwright install chromium
```

### Issue: "Template directory not found"

**Solution**: Ensure `templates/` directory exists alongside `analyzer.py`:
```bash
C:\Users\Ntro\weblser\
├── analyzer.py
├── templates/
│   ├── summary_report_light.html
│   ├── summary_report_dark.html
│   ├── audit_report_light.html
│   └── audit_report_dark.html
├── report_styles.css
└── ...
```

### Issue: PDF doesn't include logos

**Solution**: Ensure logo files exist:
```bash
C:\Users\Ntro\weblser\
├── weblser_logo.png
├── jumoki_coloured_transparent_bg.png
└── ...
```

### Issue: Styling not applied in PDF

**Solution**: Ensure `report_styles.css` is in the same directory:
```bash
C:\Users\Ntro\weblser\
├── analyzer.py
├── report_styles.css  ← Must be here
├── templates/
└── ...
```

Also verify CSS file permissions are readable.

### Issue: Slow PDF generation

**Solution**: Playwright takes 2-5 seconds per PDF due to browser startup.
- For batch operations, consider reusing the browser instance
- First run installs browser cache (slower)
- Subsequent runs use cached browser (faster)

---

## Fallback to ReportLab

If Playwright is not available or preferred, use the legacy ReportLab method:

```bash
# Without --use-playwright flag (uses ReportLab)
python analyzer.py https://example.com --pdf
```

The original `generate_pdf()` method remains unchanged for backward compatibility.

---

## Performance Notes

- **First PDF**: ~3-5 seconds (browser startup)
- **Subsequent PDFs**: ~1-2 seconds (browser cached)
- **Memory**: ~150-200MB per browser instance
- **Disk**: ~500KB-1MB per PDF file

---

## Version History

**Current**: 2.0.0 (Playwright HTML/CSS system)
- Pixel-perfect rendering
- Light & dark themes
- Multiple report types
- Professional branding

**Previous**: 1.0.0 (ReportLab system)
- Basic PDF generation
- Limited customization
- No theme support

---

## Next Steps

1. Install dependencies: `pip install -r requirements.txt`
2. Install Playwright browsers: `python -m playwright install chromium`
3. Test with a simple URL: `python analyzer.py https://example.com --pdf --use-playwright`
4. Generate branded reports with company info
5. Customize colors and styling as needed
6. Integrate with Flutter app for user downloads

---

## Support

For issues or questions:
1. Check troubleshooting section above
2. Verify all files are in correct locations
3. Ensure Playwright browsers are installed
4. Check file permissions on CSS and template files
5. Review Python error messages for specific issues
