# PDF Development Guide - Live Preview Workflow
## Iterative PDF Design with Live Preview

**Date:** October 27, 2025
**Purpose:** Enable real-time PDF template development and iteration
**Status:** ✅ Ready to Use

---

## Quick Start

### 1. Start the Development Server
```bash
# Windows
start-pdf-dev.bat

# macOS/Linux
python pdf_dev_server.py
```

The server will start at: **http://localhost:8888**

### 2. Open in Browser
Navigate to: `http://localhost:8888`

You'll see:
- **Left side:** PDF preview (live, updates instantly)
- **Right side:** Template editor (edit HTML/CSS)
- **Top:** Controls to select template type, theme, and test data

### 3. Iterate
1. Select template type (Summary or Audit)
2. Choose theme (Light or Dark)
3. Pick test data (Example.com or GitHub.com)
4. Click "Load Preview"
5. Edit the template HTML/CSS on the right
6. Click "Save & Reload" to see changes instantly
7. Repeat until perfect!

---

## Workflow Diagram

```
You Edit Template (HTML/CSS)
    ↓
Click "Save & Reload"
    ↓
Server saves template to disk
    ↓
Renders HTML to PDF (Playwright)
    ↓
PDF appears in live preview
    ↓
You see exactly what clients see
    ↓
Iterate until perfect
    ↓
Commit to Git
```

---

## Key Features

### ✨ Live Preview
- See PDF changes instantly
- No need to manually generate PDFs
- Side-by-side editing and preview

### 🎨 Multiple Templates
- **Summary Reports** - Quick analysis summaries
- **Audit Reports** - Detailed 10-point evaluations
- **Themes:** Light and Dark modes

### 📊 Test Data
- **Example.com** - Simple test case
- **GitHub.com** - Complex real-world example
- **Generate New** - Create custom test data

### ⚡ Hot Reload
- Save changes with one click
- PDF re-renders immediately
- No server restart needed

### 🎯 Exact Client View
- Uses Playwright to render exactly as clients will see
- Same fonts, styling, layout
- All Jumoki branding included

---

## File Structure

```
templates/
├── jumoki_summary_report_light.html    ← Edit this
├── jumoki_summary_report_dark.html
├── jumoki_audit_report_light.html      ← Or this
└── jumoki_audit_report_dark.html

pdf_dev_server.py                        ← Development server
start-pdf-dev.bat                        ← Easy startup script
```

---

## Development Tips

### Editing Template HTML
The template files use **Jinja2 templating**. Key variables available:

**For Summary Reports:**
```html
{{ url }}                    <!-- Website URL -->
{{ title }}                  <!-- Page title -->
{{ meta_description }}       <!-- Meta description -->
{{ summary }}                <!-- AI-generated summary -->
{{ timestamp }}              <!-- Report timestamp -->
{{ company_name }}           <!-- Your company name -->
{{ company_details }}        <!-- Contact info -->
{{ websler_logo }}           <!-- Base64 logo (if provided) -->
{{ jumoki_logo }}            <!-- Base64 logo (if provided) -->
```

**For Audit Reports:**
```html
{{ url }}                    <!-- Website URL -->
{{ report_date }}            <!-- Audit date -->
{{ overall_score }}          <!-- Overall score (0-10) -->
{{ categories }}             <!-- Dict of scores by criterion -->
{{ strengths }}              <!-- List of key strengths -->
{{ timestamp }}              <!-- Report timestamp -->
{{ company_name }}           <!-- Your company name -->
{{ company_details }}        <!-- Contact info -->
```

### CSS Best Practices
- Use `max-width: 100%` for responsive PDFs
- Avoid fixed heights that may break across pages
- Use `page-break-after` for multi-page PDFs
- Test with different content lengths

### Testing Different Scenarios
1. **Short summary** - Make sure layout doesn't look empty
2. **Long summary** - Check page breaks work correctly
3. **High scores** - See how green statuses look
4. **Low scores** - See how red statuses look
5. **No company info** - Verify it works without optional fields

---

## Example: Improving the Summary Template

### Current Issues to Fix
1. CTA section could be more compelling
2. Add more visual hierarchy
3. Better spacing between sections
4. Add icon or visual separator

### How to Improve

1. **Open the browser preview** at `http://localhost:8888`
2. **Select:** Summary Report → Light Theme → Example.com
3. **Click:** Load Preview
4. **In the editor (right side)**, find the CTA box section:
   ```html
   <div class="cta-box">
       <h3>Ready for Deeper Insights?</h3>
       ...
   </div>
   ```
5. **Enhance it:** Add icons, better copy, visual elements
6. **Click:** Save & Reload
7. **See changes:** Instantly in the PDF preview!

---

## Publishing Changes

Once you're happy with your template improvements:

### 1. Commit to Git
```bash
git add templates/jumoki_*.html
git commit -m "feat: Improve PDF templates with better visual hierarchy

- Enhanced summary report CTA section
- Added visual separators and better spacing
- Improved color contrast for accessibility
- Better typography hierarchy"
```

### 2. Push to GitHub
```bash
git push origin main
```

### 3. Next Codemagic Build
The improved templates will be used automatically in the next TestFlight build!

---

## Troubleshooting

### "PDF Preview is blank"
- Make sure Playwright is installed: `pip install playwright`
- Restart the development server
- Try a different test data source

### "Save fails with error"
- Check that templates directory exists
- Make sure you have write permissions
- Check browser console for detailed error

### "Fonts look wrong in PDF"
- Google Fonts are loaded dynamically
- Check internet connection
- Verify font names in CSS match template

### "PDF rendering is slow"
- Playwright PDF generation takes a few seconds
- This is normal for the dev server
- Production PDFs will be cached

---

## Advanced: Adding New Test Data

To add a new test website, edit `pdf_dev_server.py`:

```python
def get_test_data(self, source, template_type):
    # ... existing code ...
    elif source == 'your-site':
        return {
            'url': 'https://yoursite.com',
            'title': 'Your Site Title',
            'meta_description': 'Description',
            'summary': 'Your summary text...',
            'overall_score': 8.5,  # For audits
            'categories': { ... },  # For audits
            'strengths': [ ... ],    # For audits
            # ... other fields
        }
```

Then restart the server and select your test data from the dropdown.

---

## Best Practices

### ✅ DO:
- Test with different data lengths
- Check mobile view (if needed)
- Verify color contrast
- Use semantic HTML
- Test in different browsers
- Keep CSS clean and organized
- Add comments for complex sections
- Version control your changes

### ❌ DON'T:
- Use inline styles (use CSS classes)
- Hardcode data in template
- Use non-standard fonts
- Create PDFs that won't print well
- Forget to test with real data
- Break existing functionality
- Commit without testing

---

## Workflow Example

### Scenario: Improve Audit Report

**1. Start server:**
```bash
start-pdf-dev.bat
```

**2. Open browser:**
```
http://localhost:8888
```

**3. Select:**
- Template: Audit Report
- Theme: Light
- Data: GitHub.com
- Click "Load Preview"

**4. See current audit PDF** on the left side

**5. Identify improvements needed:**
- "Needs Work" items in red could be more prominent
- Recommendation section is missing
- Color gradient on header could be better

**6. Edit template on right side**
- Find the scores table section
- Enhance "Needs Work" styling
- Add recommendation section
- Improve header gradient

**7. Save & Reload**
- Click "Save & Reload" button
- See changes in preview instantly

**8. Iterate**
- Keep editing until perfect
- Test with different test data
- Make sure layout works for all score ranges

**9. Commit when done**
```bash
git add templates/jumoki_audit_report_light.html
git commit -m "feat: Enhance audit report with better recommendations display"
git push origin main
```

---

## Performance Notes

### PDF Generation Time
- **Dev server:** 2-5 seconds (includes Playwright overhead)
- **Production:** Cached after first render
- **Client:** Seamless download experience

### Browser Memory
- Keep dev server running while iterating
- No need to restart between edits
- Stop with Ctrl+C when done

### Template File Size
- Current templates: 7-10 KB
- Well-optimized CSS and HTML
- No bloated frameworks

---

## Next Steps

1. ✅ **Start the dev server** - Run `start-pdf-dev.bat`
2. ✅ **Open in browser** - Visit `http://localhost:8888`
3. ✅ **Load a preview** - Select template, theme, data
4. ✅ **Make an improvement** - Edit template
5. ✅ **Save & reload** - See changes instantly
6. ✅ **Iterate until perfect** - Repeat steps 4-5
7. ✅ **Commit improvements** - Push to GitHub
8. ✅ **Deploy** - Next TestFlight build uses new templates

---

## Support

For issues:
1. Check this guide first
2. Check browser console (F12) for errors
3. Verify Playwright is installed
4. Restart the development server
5. Check GitHub for similar issues

---

**Happy PDF designing! 🎨**

Generated: October 27, 2025
