# Flutter WebAudit Pro - PDF Integration Guide

## Overview

This guide explains how to integrate the new professional Playwright-based PDF generation system with the Flutter WebAudit Pro app.

---

## Current System

The Flutter app currently:
1. Sends audit/summary data to the FastAPI backend
2. Backend uses ReportLab to generate PDFs
3. PDFs are "blown-out" with broken styling

**Issues**:
- HTML tags visible in text
- No professional branding
- Text overflow and truncation
- Poor typography and spacing

---

## New System (Implemented)

### Backend Changes (Already Complete)

**What was added to `analyzer.py`**:

1. **CSS Stylesheet** (`report_styles.css`)
   - Raleway typography
   - Light & dark theme support
   - Professional component styling
   - Print-optimized media queries

2. **HTML Templates** (`templates/`)
   - 4 templates total:
     - `summary_report_light.html`
     - `summary_report_dark.html`
     - `audit_report_light.html`
     - `audit_report_dark.html`

3. **Playwright Integration** (in `analyzer.py`)
   - New `generate_pdf_playwright()` method
   - Base64 image embedding for logos
   - Jinja2 template rendering
   - Browser automation for pixel-perfect PDFs

4. **Dependencies** (in `requirements.txt`)
   - `playwright>=1.40.0`
   - `jinja2>=3.1.0`

### Command Examples

```bash
# Summary report (light theme)
python analyzer.py https://example.com --pdf --use-playwright

# Audit report (dark theme)
python analyzer.py https://example.com --pdf --use-playwright --audit --theme dark

# With company branding
python analyzer.py https://example.com --pdf --use-playwright \
  --company-name "Jumoki Agency LLC" \
  --company-details "1309 Coffeen Avenue STE 1200, Sheridan WY 82801"
```

---

## Integration Steps for Flutter App

### Step 1: Update Backend FastAPI Server

**File**: `main.py` (or your FastAPI app file)

Add a new endpoint for Playwright PDFs:

```python
from fastapi import FastAPI, HTTPException
from analyzer import WebsiteAnalyzer

app = FastAPI()
analyzer = WebsiteAnalyzer()

@app.post("/api/pdf/generate")
async def generate_pdf(
    url: str,
    report_type: str = "summary",  # "summary" or "audit"
    theme: str = "light",  # "light" or "dark"
    company_name: Optional[str] = None,
    company_details: Optional[str] = None,
    audit_data: Optional[dict] = None  # For audit reports
):
    """Generate professional PDF using Playwright"""
    try:
        # Analyze website
        result = analyzer.analyze(url)

        if not result['success']:
            raise HTTPException(status_code=400, detail=result['summary'])

        # Generate PDF
        pdf_path = analyzer.generate_pdf_playwright(
            result,
            is_audit=(report_type == "audit"),
            company_name=company_name,
            company_details=company_details,
            use_dark_theme=(theme == "dark"),
            audit_data=audit_data
        )

        # Return PDF file or path
        return {
            "success": True,
            "pdf_path": pdf_path,
            "message": f"PDF generated: {pdf_path}"
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

### Step 2: Update Flutter ApiService

**File**: `lib/services/api_service.dart`

Add a method to call the new PDF endpoint:

```dart
Future<String> generatePdfPlaywright({
  required String url,
  String reportType = 'summary',
  String theme = 'light',
  String? companyName,
  String? companyDetails,
  Map<String, dynamic>? auditData,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/pdf/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'url': url,
        'report_type': reportType,
        'theme': theme,
        'company_name': companyName,
        'company_details': companyDetails,
        'audit_data': auditData,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['pdf_path'];  // Path to generated PDF
    } else {
      throw Exception('Failed to generate PDF: ${response.body}');
    }
  } catch (e) {
    throw Exception('PDF generation error: $e');
  }
}
```

### Step 3: Update HomeScreen / HistoryScreen

**File**: `lib/screens/home_screen.dart` or `lib/screens/history_screen.dart`

Add PDF generation with theme selection:

```dart
Future<void> _generatePdf(String url, String reportType) async {
  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Generating PDF...'),
        content: const SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    // Determine theme based on app setting
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final theme = themeProvider.isDarkMode ? 'dark' : 'light';

    // Generate PDF
    final pdfPath = await apiService.generatePdfPlaywright(
      url: url,
      reportType: reportType,
      theme: theme,
      companyName: 'Websler Pro',
      companyDetails: 'Professional Website Analysis',
    );

    Navigator.pop(context);  // Close loading dialog

    // Show success and download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF ready: $pdfPath'),
        action: SnackBarAction(
          label: 'Open',
          onPressed: () => _openPdf(pdfPath),
        ),
      ),
    );
  } catch (e) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF generation failed: $e')),
    );
  }
}

Future<void> _openPdf(String pdfPath) async {
  // Use url_launcher or file_picker to open PDF
  // Implementation depends on platform
}
```

### Step 4: Update UI to Show Theme Option

**Option A: Use App Theme**
```dart
// Already theme-aware - use current app theme
final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
// Pass to PDF generation: theme = isDarkMode ? 'dark' : 'light'
```

**Option B: Add PDF-Specific Theme Picker**
```dart
// Add toggle in settings or report dialog
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('PDF Theme'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RadioListTile(
          title: const Text('Light Theme'),
          value: 'light',
          groupValue: selectedTheme,
          onChanged: (value) => setState(() => selectedTheme = value),
        ),
        RadioListTile(
          title: const Text('Dark Theme'),
          value: 'dark',
          groupValue: selectedTheme,
          onChanged: (value) => setState(() => selectedTheme = value),
        ),
      ],
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          _generatePdf(url, selectedTheme);
        },
        child: const Text('Generate'),
      ),
    ],
  ),
);
```

---

## File Structure

After implementation, your backend should have:

```
C:\Users\Ntro\weblser\
├── analyzer.py                          # Enhanced with Playwright
├── report_styles.css                    # NEW: CSS stylesheet
├── requirements.txt                     # Updated with playwright, jinja2
├── main.py                              # Your FastAPI app
├── weblser_logo.png                     # Logo files
├── jumoki_coloured_transparent_bg.png   #
├── templates/                           # NEW: HTML templates
│   ├── summary_report_light.html
│   ├── summary_report_dark.html
│   ├── audit_report_light.html
│   └── audit_report_dark.html
└── ...
```

---

## Testing the Integration

### Step 1: Install Dependencies
```bash
cd C:\Users\Ntro\weblser
pip install -r requirements.txt
python -m playwright install chromium
```

### Step 2: Test Backend Endpoint
```bash
# Test with curl
curl -X POST http://localhost:8000/api/pdf/generate \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com",
    "report_type": "summary",
    "theme": "light",
    "company_name": "Jumoki Agency"
  }'

# Check response
# You should get: { "success": true, "pdf_path": "example-com-summary-report.pdf" }
```

### Step 3: Test Flutter Integration
1. Update API service with new method
2. Call `generatePdfPlaywright()` in your screen
3. Verify PDF generates and can be opened
4. Check PDF styling matches design system

### Step 4: Verify Visual Quality
- Open generated PDF in viewer
- Check that:
  - Logos display correctly
  - Colors match design system
  - Text is readable and properly formatted
  - Tables are properly styled
  - Page breaks occur correctly
  - Both light and dark themes work

---

## Expected PDF Output

### Summary Report
- Clean, professional appearance
- Websler/Jumoki logos in header
- AI-generated summary clearly visible
- Call-to-action button for "Upgrade to Pro"
- Footer with company info
- ~1-2 pages

### Audit Report
- Large overall score display
- Detailed evaluation table
- Recommendations with priority levels
- Strengths section
- Next steps guidance
- Professional branding throughout
- ~2-4 pages

---

## Configuration Options

### Company Branding
```dart
// In ApiService or main.dart
static const String COMPANY_NAME = 'Websler Pro';
static const String COMPANY_DETAILS = '...contact info...';

// Then use in PDF generation
await apiService.generatePdfPlaywright(
  url: url,
  reportType: reportType,
  theme: theme,
  companyName: COMPANY_NAME,
  companyDetails: COMPANY_DETAILS,
);
```

### Theme Preference
```dart
// Automatic - use app's current theme
final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
final theme = isDarkMode ? 'dark' : 'light';

// Manual override
const theme = 'dark';  // Always use dark theme for PDFs
```

---

## Troubleshooting Integration

### Issue: "ModuleNotFoundError: No module named 'playwright'"
**Solution**:
```bash
pip install playwright
python -m playwright install chromium
```

### Issue: "Template directory not found"
**Solution**: Ensure `templates/` directory exists in same location as `analyzer.py`

### Issue: PDF generated but styling missing
**Solution**:
1. Check `report_styles.css` exists and is readable
2. Verify CSS file path in HTML templates
3. Check Playwright browser output for errors

### Issue: Logos not showing in PDF
**Solution**:
1. Verify logo files exist (weblser_logo.png, jumoki_coloured_transparent_bg.png)
2. Check file paths in analyzer.py
3. Try with base64 encoding (already implemented)

### Issue: Slow PDF generation
**Solution**: This is normal (2-5 seconds per PDF)
- First PDF takes longer (browser startup)
- Subsequent PDFs cached
- For batch operations, consider async queue

---

## Performance Optimization

For high-volume PDF generation:

```python
# Consider using a queue system
from celery import Celery

app = Celery('websler_pro')

@app.task
def generate_pdf_async(url, report_type, theme):
    """Async PDF generation"""
    analyzer = WebsiteAnalyzer()
    result = analyzer.analyze(url)
    pdf_path = analyzer.generate_pdf_playwright(
        result,
        is_audit=(report_type == "audit"),
        use_dark_theme=(theme == "dark")
    )
    return pdf_path
```

Or use a background job queue:

```python
from rq import Queue
from redis import Redis

redis_conn = Redis()
q = Queue(connection=redis_conn)

# Enqueue PDF generation
job = q.enqueue(generate_pdf_task, url, report_type, theme)
# Check status: job.get_status()
# Get result: job.result
```

---

## Next Steps

1. ✅ Backend CSS and templates created
2. ✅ Playwright integration in analyzer.py
3. ⏳ Update FastAPI endpoint (if using FastAPI)
4. ⏳ Update Flutter ApiService
5. ⏳ Update Flutter UI with PDF generation
6. ⏳ Test end-to-end flow
7. ⏳ Deploy and monitor performance

---

## Questions?

Refer to:
- `PDF_GENERATION_GUIDE.md` - Full technical documentation
- `report_styles.css` - Styling customization
- HTML templates in `templates/` - Content customization
- `analyzer.py` - Python implementation details

