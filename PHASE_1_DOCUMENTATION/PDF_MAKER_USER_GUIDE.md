# PDF Maker User Guide
## Jumoki Agency Internal Tool - Complete How-To Guide

**Document Version:** 1.0
**Created:** October 28, 2025
**For:** Non-technical Jumoki team members
**Time to Read:** 10-15 minutes

---

## Welcome to PDF Maker! 🚀

PDF Maker is an easy-to-use tool for generating professional, branded PDF reports for your clients. No coding required—just a few clicks and you'll have a polished, client-ready PDF.

### What PDF Maker Does
- ✅ Generates professional branded reports in seconds
- ✅ Includes Jumoki and WebslerPro branding
- ✅ Supports multiple report templates
- ✅ Creates consistent, professional PDFs
- ✅ Perfect for client deliverables

### What You'll Learn
- How to access PDF Maker
- How to generate a PDF report
- How to select templates and themes
- How to customize for clients
- How to download and share PDFs
- Troubleshooting common issues

---

## Getting Started

### Step 1: Access PDF Maker

1. Open your web browser (Chrome, Firefox, Safari, Edge)
2. Go to: `https://pdf-maker.jumoki.agency`
3. You'll see a login prompt

### Step 2: Login

You'll be asked for:
- **Username:** `admin`
- **Password:** [Your secure password - ask DevOps if you don't have it]

After login, you'll see the **PDF Maker Dashboard** with the header "PDF Template Studio"

---

## Dashboard Overview

Once logged in, you'll see:

```
┌─────────────────────────────────────────┐
│  PDF Template Studio                    │
│  Generate Professional Reports Instantly│
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  Template Selection                      │
│  ┌──────────────────┐ ┌────────────────┐│
│  │ Summary Light    │ │ Summary Dark   ││
│  │ (Light theme)    │ │ (Dark theme)   ││
│  └──────────────────┘ └────────────────┘│
│  ┌──────────────────┐ ┌────────────────┐│
│  │ Audit Light      │ │ Audit Dark     ││
│  │ (Light theme)    │ │ (Dark theme)   ││
│  └──────────────────┘ └────────────────┘│
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  Preview Section                         │
│  [Live preview of selected template]     │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  Download Button                         │
│  [ Generate & Download PDF ]             │
└─────────────────────────────────────────┘
```

---

## Generating Your First PDF

### Option 1: Summary Report (Quick Summary)

**Use this for:** Quick website overviews, fast client updates

**Steps:**

1. **Select Template:**
   - Click "Summary Light" (clean, professional look)
   - OR "Summary Dark" (modern, darker design)

2. **Preview:**
   - Look at the preview pane on the right
   - You'll see a sample with placeholder data
   - Shows what the final PDF will look like

3. **Generate PDF:**
   - Scroll down to "Generate & Download PDF"
   - Click the button
   - Wait 3-5 seconds while the PDF is created
   - Your browser will download the file

4. **File Location:**
   - File saves to your Downloads folder
   - Named: `websler-analysis-[timestamp].pdf`
   - Example: `websler-analysis-2025-10-28-145230.pdf`

---

### Option 2: Audit Report (Comprehensive Evaluation)

**Use this for:** Full 10-point website audits, detailed client reports

**Steps:**

1. **Select Template:**
   - Click "Audit Light" (clean presentation)
   - OR "Audit Dark" (dramatic, modern design)

2. **Preview:**
   - Preview shows sample audit with:
     - Overall score (0-10 scale)
     - 10 evaluation categories with scores
     - Key strengths list
     - Professional branding

3. **Generate PDF:**
   - Click "Generate & Download PDF"
   - Wait 3-5 seconds
   - PDF downloads to your Downloads folder

4. **File Naming:**
   - Named: `webaudit-report-[timestamp].pdf`
   - Example: `webaudit-report-2025-10-28-145230.pdf`

---

## Template Selection Guide

### When to Use Each Template

#### Summary Reports
- **Good for:** Website overviews, quick analyses, first impression
- **Contains:** URL, title, description, AI summary, Jumoki branding
- **Length:** 1 page typically
- **Use case:** "Here's what we found about your site"

**Light Theme**
- Clean, professional white background
- Best for printing
- Works well with all monitors

**Dark Theme**
- Modern, eye-catching dark design
- Great for digital presentation
- More visually striking

#### Audit Reports
- **Good for:** Detailed evaluations, improvement roadmaps, sales materials
- **Contains:** Overall score, 10-point evaluation table, category scores, strengths
- **Length:** 1-2 pages
- **Use case:** "Here's a comprehensive evaluation of your website"

**Light Theme**
- Professional, corporate look
- Easiest to read when printed
- Traditional consulting feel

**Dark Theme**
- Modern, premium feel
- Great for digital sharing
- Makes scores stand out more

### How to Choose

**Ask yourself:**
- Do I need a quick overview or detailed evaluation?
  - Quick → Summary Report
  - Detailed → Audit Report

- Do I want to print or digital?
  - Print → Light theme (easier to read)
  - Digital → Either (Dark is more eye-catching)

- What's the client's brand style?
  - Professional/Corporate → Light theme
  - Modern/Tech-savvy → Dark theme

---

## Customizing Your Report

### Using Test Data

The dashboard comes with sample data to preview templates. You'll see:

**Summary Report Sample Data:**
```
URL: https://example.com
Title: Example Website
Description: We provide great products
Summary: This is a sample analysis...
```

**Audit Report Sample Data:**
```
Overall Score: 7.5/10
Categories: Performance (8.2), Security (7.1), etc.
Strengths: Mobile responsive, fast loading, etc.
```

### Changing Company Information

Your PDF includes:
- **Header:** WebslerPro logo
- **Footer:** Jumoki Agency LLC logo and company details

**Footer includes:**
- Company name: Jumoki Agency LLC
- Contact info: Address, phone, email
- Copyright year

These are automatically set. If you need to customize them for a client, contact DevOps or the Technical Lead.

### Using Real Client Data

Currently, test data is used for preview. To use real client data:
1. Contact your Backend Developer
2. They'll integrate actual analysis data from your client
3. PDFs will then generate with real client information

---

## Downloading & Sharing PDFs

### Download Location

PDFs automatically save to your computer's Downloads folder:
- **Windows:** `C:\Users\[YourName]\Downloads\`
- **Mac:** `/Users/[YourName]/Downloads/`
- **Linux:** `/home/[YourName]/Downloads/`

### Recommended: Open & Save With Custom Name

**After downloading:**

1. Open the PDF (double-click the file)
2. Use File → Save As
3. Choose a client-specific name:
   ```
   ✅ Good names:
   - ClientName-Audit-2025-10.pdf
   - example.com-WebAudit-Report.pdf
   - ABC-Corp-Summary-Analysis.pdf

   ❌ Avoid:
   - websler-analysis-2025-10-28-145230.pdf (too generic)
   - report.pdf (not descriptive)
   ```

### Sharing with Clients

**Best practices:**

1. **Email:** Attach PDF to professional email
   ```
   Subject: Your Website Analysis Report - Example.com

   Hi [Client Name],

   Attached is your website analysis report.
   The report includes [summary/audit] insights.

   Please review and let me know if you have questions.

   Best regards,
   Dean Taggart
   Jumoki Agency
   ```

2. **Cloud Storage:** Upload to shared drive (Google Drive, Dropbox)
   - More reliable for large files
   - Easy for client to access anytime

3. **Client Portal:** If Jumoki has a client portal
   - Upload there for secure access
   - Professional appearance

---

## Template Features

### What's In a Summary Report

**Header Section:**
- WebslerPro logo
- "Website Summary Report" title
- "Professional Analysis • Powered by Agentic AI"

**Metadata:**
- Website URL
- Page title (if available)
- Meta description (if available)
- Report generation date/time

**Summary Section:**
- "Executive Summary" heading
- 2-3 sentence AI analysis of the website
- Highlighted in blue box

**Call-to-Action:**
- "Ready for Deeper Insights?" section
- Promotion for WebAudit Pro upgrade
- "Get actionable recommendations" messaging

**Footer:**
- Jumoki Agency logo (60px, professional sizing)
- "Jumoki Agency LLC"
- Company contact information
- Copyright notice
- Timestamp of generation

---

### What's In an Audit Report

**Header Section:**
- WebslerPro logo
- "WebAudit Pro Report" title
- "Comprehensive 10-Point Website Evaluation"

**Metadata:**
- Website URL
- Audit date
- Overall score preview (X.X/10)

**Overall Score Display:**
- Large, prominent number (7.5)
- "Overall Website Score" label
- Purple gradient background (Jumoki branding)

**10-Point Evaluation Table:**
- Category names (Performance, Security, SEO, etc.)
- Individual scores for each (0-10)
- Status badges:
  - 🟢 Excellent (8.0+)
  - 🔵 Good (6.0-7.9)
  - 🔴 Needs Work (below 6.0)

**Key Strengths Section:**
- Bulleted list of website strengths
- 3-5 main positives about the site

**Call-to-Action:**
- "Ready to Improve Your Website?" section
- Upgrade and improvement messaging

**Footer:**
- Same as Summary Report

---

## Light vs. Dark Theme Visual Differences

### Summary Report - Light Theme
- White background
- Purple accents (#9018ad)
- Easy to read when printed
- Traditional, clean look
- **Best for:** Professional/corporate clients

### Summary Report - Dark Theme
- Dark background
- Purple highlights stand out
- More modern appearance
- Better for screen viewing
- **Best for:** Tech-savvy/modern clients

### Audit Report - Light Theme
- Light background with subtle gradients
- Purple table header
- Maximum readability
- Ideal for printing
- **Best for:** Detailed review documents

### Audit Report - Dark Theme
- Dark background
- Colors pop more dramatically
- Modern, premium feel
- Great for digital presentation
- **Best for:** Digital sharing, presentations

---

## Troubleshooting

### Problem: Login Page Shows But Can't Log In

**Symptoms:**
- Correct username/password but login fails
- "Invalid credentials" message appears

**Solutions:**
1. Make sure Caps Lock is OFF
2. Check password carefully (passwords are case-sensitive)
3. Ask DevOps to reset password
4. Verify you have internet connection

---

### Problem: Dashboard Loads But Preview is Blank

**Symptoms:**
- Login successful
- Dashboard visible
- Preview pane on right is empty

**Solutions:**
1. Wait 2-3 seconds (preview may still be loading)
2. Refresh the page (Ctrl+R or Cmd+R)
3. Try selecting a different template
4. Check DevOps logs if problem persists

---

### Problem: PDF Generation Starts But Never Finishes

**Symptoms:**
- Click "Generate & Download PDF"
- Spinner shows for 30+ seconds
- No PDF ever downloads

**Solutions:**
1. Wait up to 60 seconds (Playwright can be slow first run)
2. Refresh page and try again
3. Try a simpler template (Summary instead of Audit)
4. Check internet connection
5. Contact DevOps with timestamp of error

---

### Problem: PDF Downloads But is Blank or Incomplete

**Symptoms:**
- PDF downloads successfully
- But PDF shows no content or partial content
- Some sections missing

**Solutions:**
1. Check PDF viewer (use Adobe Reader instead of browser)
2. Try regenerating the PDF (sometimes temporary glitch)
3. Try a different template
4. Contact DevOps with details

---

### Problem: Logo Not Showing in PDF

**Symptoms:**
- PDF looks correct except logos are missing
- Jumoki or WebslerPro logo appears as blank space

**Solutions:**
1. This usually fixes itself
2. Download the PDF again
3. Try a different template
4. Contact DevOps if persists

---

### Problem: Can't Access PDF Maker at All

**Symptoms:**
- Can't reach `https://pdf-maker.jumoki.agency`
- "Connection refused" or "Page not found"
- Server is down

**Solutions:**
1. Check internet connection
2. Verify you're typing URL correctly (with https://)
3. Try from different browser
4. Contact DevOps immediately (service may be down)

---

## Performance & Loading Times

**Expected Times:**

| Action | Expected Time | Maximum |
|--------|---------------|---------|
| Login | 1-2 seconds | 5 seconds |
| Template preview load | 2-3 seconds | 10 seconds |
| PDF generation (first time) | 5-10 seconds | 30 seconds |
| PDF generation (subsequent) | 3-5 seconds | 15 seconds |
| Download | 1-2 seconds | 5 seconds |

**Note:** First PDF generation takes longer because Playwright needs to start the browser. Subsequent PDFs are faster.

---

## Common Questions (FAQ)

### Q: Can I edit the PDF after downloading?
**A:** Yes! Open in any PDF editor (Adobe Acrobat, Preview on Mac, etc.) and edit as needed. However, the original template-generated PDF is usually high quality enough to use directly.

---

### Q: Can I use these PDFs for client work?
**A:** Absolutely! That's exactly what PDF Maker is designed for. Generate professional reports for your clients to download and keep.

---

### Q: How do I send this to a client?
**A:** Download the PDF, rename it with the client name, and email or upload to your client portal. See "Sharing with Clients" section above.

---

### Q: Can I customize colors or fonts?
**A:** Not from the dashboard. If you need customizations, contact the Designer or Technical Lead. They can modify the templates.

---

### Q: What if I want a different template style?
**A:** Contact your Product Manager. Additional templates can be created based on feedback.

---

### Q: Is this data secure?
**A:** Yes. PDF Maker is password-protected and only accessible to Jumoki team members. All data stays on Jumoki servers.

---

### Q: Can I print these PDFs?
**A:** Yes! Light theme templates are optimized for printing. Print to PDF or physical printer—both work great.

---

### Q: What if the website URL doesn't load?
**A:** Some websites block automated access. Contact DevOps if you're getting errors analyzing specific sites.

---

## Keyboard Shortcuts

For faster workflow:

| Action | Windows | Mac |
|--------|---------|-----|
| Refresh page | Ctrl+R | Cmd+R |
| Clear browser cache | Ctrl+Shift+Delete | Cmd+Shift+Delete |
| Open Downloads folder | N/A | Cmd+Shift+J |
| Save webpage | Ctrl+S | Cmd+S |

---

## Support & Help

### Issues Not Listed Above?

**Contact Information:**
- **DevOps Lead:** [TBD - DevOps Lead] - [TBD - Email] (for server/access issues)
- **Product Manager:** [TBD - Product Manager] - [TBD - Email] (for feature requests, template changes)
- **Technical Lead:** [TBD - Backend Developer] - [TBD - Email] (for integration issues)

### Before You Contact Support, Try:
1. ✅ Refresh the page (Ctrl+R)
2. ✅ Clear browser cache
3. ✅ Try a different browser
4. ✅ Try logging out and back in
5. ✅ Check your internet connection
6. ✅ Check this guide's troubleshooting section

### What Info to Include When Reporting Issues:
- What were you doing when the problem happened?
- What error message (if any) did you see?
- What browser are you using?
- What template were you trying?
- What time did it happen? (We can check logs)
- Screenshots if possible

---

## Best Practices for Using PDF Maker

### DO ✅
- Generate reports regularly and collect feedback
- Keep PDF file names organized with dates/client names
- Test different templates to find what works best
- Save important PDFs in a cloud backup (Google Drive, Dropbox)
- Use the light theme for printing, dark for digital

### DON'T ❌
- Don't share login credentials with clients (use password manager)
- Don't delete PDFs after generating (keep for reference)
- Don't use generic file names (use client-specific names)
- Don't try to modify templates (contact Designer instead)
- Don't generate hundreds of PDFs at once (can slow server)

---

## Tips & Tricks

### Tip 1: Preview Before Committing
Always look at the preview before generating the full PDF. This prevents mistakes.

### Tip 2: Use Light Theme for Print, Dark for Digital
Light theme reads better in print. Dark theme looks better on screens.

### Tip 3: Batch Your PDF Generation
If you have multiple clients, generate PDFs in batches. Wait 5 seconds between batches.

### Tip 4: Name PDFs Immediately
Don't wait—rename the PDF right away while you remember which client it's for.

### Tip 5: Test with Different Clients
Use the tool with 2-3 different client websites to see what works best.

---

## What's Next?

### After You Generate PDFs:
1. Download and rename with client name
2. Review the PDF (looks good?)
3. Share with client via email or portal
4. Collect feedback from client
5. Fill out weekly feedback form for Product Manager

### Feedback Form (Weekly):
Your manager will send a weekly form asking:
- How many PDFs did you generate?
- Any issues or problems?
- Suggestions for improvement?
- Overall satisfaction (1-5 stars)?

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Oct 28, 2025 | Initial user guide release |

---

## Related Documents

- **PDF_MAKER_USER_GUIDE.md** - This document
- **TEMPLATE_VARIABLES_REFERENCE.md** - For developers (technical details)
- **TEMPLATE_EDITING_GUIDE.md** - For developers modifying templates
- **PDF_MAKER_TROUBLESHOOTING.md** - Detailed troubleshooting
- **PHASE_1_QUICK_START.md** - Team deployment checklist

---

**Happy report generating! 🎉**

If you have questions, refer to the FAQ section or contact your Product Manager.

Questions? → See troubleshooting section above
Need help? → Contact DevOps or Product Manager
Found a bug? → Report to Technical Lead with details
Have suggestions? → Fill out weekly feedback form
