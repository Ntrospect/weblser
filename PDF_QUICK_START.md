# PDF System - Quick Start

## Install (First Time Only)

```bash
cd C:\Users\Ntro\weblser
pip install -r requirements.txt
python -m playwright install chromium
```

## Generate PDFs

### Summary Report (Light)
```bash
python analyzer.py https://example.com --pdf --use-playwright
```

### Summary Report (Dark)
```bash
python analyzer.py https://example.com --pdf --use-playwright --theme dark
```

### Audit Report (Light)
```bash
python analyzer.py https://example.com --pdf --use-playwright --audit
```

### Audit Report (Dark)
```bash
python analyzer.py https://example.com --pdf --use-playwright --audit --theme dark
```

### With Branding
```bash
python analyzer.py https://example.com --pdf --use-playwright \
  --company-name "Your Company" \
  --company-details "Address, Phone, Email"
```

## Python API

```python
from analyzer import WebsiteAnalyzer

analyzer = WebsiteAnalyzer()
result = analyzer.analyze('https://example.com')

# Summary
pdf = analyzer.generate_pdf_playwright(result, use_dark_theme=False)

# Audit
pdf = analyzer.generate_pdf_playwright(
    result,
    is_audit=True,
    audit_data={
        'overall_score': 7.5,
        'categories': [...],
        'recommendations': [...],
        'strengths': [...]
    }
)
```

## Files Created

| File | Purpose |
|------|---------|
| `report_styles.css` | Master stylesheet |
| `templates/summary_report_light.html` | Summary (light) |
| `templates/summary_report_dark.html` | Summary (dark) |
| `templates/audit_report_light.html` | Audit (light) |
| `templates/audit_report_dark.html` | Audit (dark) |
| `analyzer.py` | Enhanced with Playwright |
| `requirements.txt` | Updated dependencies |

## Design System

**Colors**:
- Light BG: `#F4F3F2`, Dark BG: `#0F1419`
- Primary Accent: `#7c3aed` (Jumoki Purple)
- Secondary Accent: `#2052b6` (Jumoki Blue)

**Typography**:
- Font: Raleway (Google Fonts)
- Title: 28pt, weight 800

## Documentation

1. **PDF_GENERATION_GUIDE.md** - Full technical guide
2. **FLUTTER_PDF_INTEGRATION.md** - Flutter integration examples
3. **PDF_SYSTEM_IMPLEMENTATION_SUMMARY.md** - What was built

## Troubleshooting

**"Playwright not found"**
```bash
pip install playwright
python -m playwright install chromium
```

**"Template directory not found"**
- Ensure `templates/` exists in same directory as `analyzer.py`

**"Logo not showing"**
- Check files exist: `weblser_logo.png`, `jumoki_coloured_transparent_bg.png`

## Performance

- First PDF: 3-5 seconds (browser startup)
- Subsequent: 1-2 seconds (cached)
- Memory: ~150-200MB per instance

## Output Files

- Summary: `domain-summary-report.pdf`
- Audit: `domain-webaudit-report.pdf`
- Custom: Use `--output filename.pdf`

## Next: Flutter Integration

```python
# FastAPI endpoint
@app.post("/api/pdf/generate")
async def generate_pdf(url: str, theme: str, report_type: str):
    result = analyzer.analyze(url)
    pdf = analyzer.generate_pdf_playwright(
        result,
        is_audit=(report_type == "audit"),
        use_dark_theme=(theme == "dark")
    )
    return {"pdf_path": pdf}
```

```dart
// Flutter
final pdf = await apiService.generatePdfPlaywright(
  url: url,
  theme: isDarkMode ? 'dark' : 'light',
  reportType: 'summary',
);
```

---

**Status**: ✅ Ready to use
**Installation time**: 2-3 minutes
**First PDF generation**: 3-5 seconds
**Quality**: Professional, pixel-perfect, branded
