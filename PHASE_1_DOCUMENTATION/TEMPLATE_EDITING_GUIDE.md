# Template Editing Guide
## PDF Maker - Technical Guide for Developers

**Document Version:** 1.0
**Created:** October 28, 2025
**For:** Backend developers and technical team members
**Level:** Intermediate HTML/CSS/Jinja2 knowledge required

---

## Overview

This guide explains how to modify, extend, and maintain PDF Maker templates. It covers HTML structure, CSS styling, Jinja2 templating, testing, and deployment procedures.

### What You'll Learn
- Template file structure and locations
- HTML & CSS fundamentals for templates
- Jinja2 templating syntax and variables
- How to add new sections to templates
- How to create template variations
- Testing and previewing changes
- Committing changes to git

### Prerequisites
- Basic HTML/CSS knowledge
- Understanding of Jinja2 templates
- Access to VPS and GitHub
- Familiarity with git commands

---

## Template Location & Structure

### File Locations

**Development (Local):**
```
weblser/
├── templates/
│   ├── jumoki_summary_report_light.html
│   ├── jumoki_summary_report_dark.html
│   ├── jumoki_audit_report_light.html
│   └── jumoki_audit_report_dark.html
├── pdf_dev_server.py
└── requirements.txt
```

**Production (VPS):**
```
/var/www/pdf-maker/
├── templates/
│   └── [same 4 files above]
├── pdf_dev_server.py
└── venv/
```

**Shared with Backend:**
```
/var/www/weblser/
├── templates/
│   └── [same 4 template files]
└── analyzer.py
```

### File Naming Convention

**Template Names:** `jumoki_[report_type]_[theme].html`

- **Report type:** `summary_report` or `audit_report`
- **Theme:** `light` or `dark`

**Examples:**
- ✅ `jumoki_summary_report_light.html`
- ✅ `jumoki_audit_report_dark.html`
- ❌ `summary_light.html` (missing prefix)
- ❌ `jumoki_report_v2.html` (wrong naming)

### Creating New Template Variations

To create a new template:

1. Choose base template to duplicate:
   ```bash
   cp jumoki_summary_report_light.html jumoki_summary_report_extended.html
   ```

2. Modify the new template (see sections below)

3. Test and verify (see Testing section)

4. Commit to git:
   ```bash
   git add templates/jumoki_summary_report_extended.html
   git commit -m "feat: Add extended summary report template"
   git push
   ```

---

## Template File Structure

### Basic HTML Structure

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <!-- Metadata and styles -->
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Website Report - Jumoki</title>
    <style>
        /* All CSS is inline for portability */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Raleway', sans-serif; }
        /* ... more styles ... */
    </style>
</head>
<body>
    <div class="container">
        <!-- Header with logos -->
        <!-- Metadata section -->
        <!-- Content sections -->
        <!-- Footer with company info -->
    </div>
</body>
</html>
```

### Key Components in Order

1. **Header** - Logo and title
2. **Metadata** - URL, date, scores
3. **Main Content** - Summary, audit scores, strengths
4. **Call-to-Action** - Upgrade messaging
5. **Footer** - Company branding and info
6. **Timestamp** - Generation date/time

---

## HTML Structure Details

### Header Section

```html
<div class="header">
    <div class="logo-container">
        {% if websler_logo %}
            <img src="data:image/svg+xml,{{ websler_logo }}" alt="Websler">
        {% endif %}
    </div>
    <h1>Website Summary Report</h1>
    <p class="subtitle">Professional Analysis • Powered by Agentic AI</p>
</div>
```

**Key elements:**
- Logo container with conditional rendering
- Main heading (H1)
- Subtitle explaining the report

**To modify:**
- Change heading text for different report types
- Adjust logo sizing in `.logo-container img { max-height: 60px; }`
- Modify subtitle messaging

---

### Metadata Section

```html
<div class="metadata">
    <div class="metadata-item">
        <span class="metadata-label">Website URL</span>
        <span class="metadata-value">{{ url }}</span>
    </div>
    {% if title %}
    <div class="metadata-item">
        <span class="metadata-label">Page Title</span>
        <span class="metadata-value">{{ title }}</span>
    </div>
    {% endif %}
    <!-- ... more items ... -->
</div>
```

**Key elements:**
- Grid layout for responsive columns
- Labels and values
- Conditional display with `{% if %}`

**To modify:**
- Add new metadata items following same pattern
- Change label text or styling
- Adjust grid columns with `grid-template-columns`

---

### Content Sections

**Summary Report:**
```html
<div class="summary-section">
    <h2 class="section-title">Executive Summary</h2>
    <div class="summary-box">
        {{ summary }}
    </div>
</div>
```

**Audit Report (Score Table):**
```html
<table class="scores-table">
    <thead>
        <tr>
            <th>Criterion</th>
            <th style="width: 100px;">Score</th>
            <th style="width: 120px;">Status</th>
        </tr>
    </thead>
    <tbody>
        {% for criterion, score in categories.items() %}
        <tr>
            <td>{{ criterion }}</td>
            <td class="score-cell">{{ score|round(1) }}/10</td>
            <td class="status-cell">
                {% if score >= 8 %}
                    <span class="status-excellent">Excellent</span>
                {% elif score >= 6 %}
                    <span class="status-good">Good</span>
                {% else %}
                    <span class="status-needswork">Needs Work</span>
                {% endif %}
            </td>
        </tr>
        {% endfor %}
    </tbody>
</table>
```

---

### Footer Section

```html
<div class="footer">
    {% if jumoki_logo %}
    <div style="margin-bottom: 6px;">
        <img src="data:image/svg+xml,{{ jumoki_logo }}" alt="Jumoki"
             style="height: 60px; width: auto;">
    </div>
    {% endif %}
    {% if company_name %}
    <div class="footer-company">{{ company_name }}</div>
    {% endif %}
    {% if company_details %}
    <div>{{ company_details }}</div>
    {% endif %}
    <div style="margin-top: 8px;">© 2025 All rights reserved. Powered by Jumoki Agentic Systems</div>
</div>
```

**Key elements:**
- Logo display (currently 60px height)
- Company name and details (conditional)
- Copyright notice

**To modify:**
- Change logo size: `height: 60px;`
- Update company info for different clients
- Modify copyright year or text

---

## CSS Styling Guide

### Color Scheme

```css
/* Primary Colors */
--primary-purple: #9018ad;      /* Main accent color */
--primary-dark: #7b1293;        /* Purple gradient dark */

/* Text Colors */
--text-dark: #1f2937;           /* Body text */
--text-muted: #6b7280;          /* Secondary text */

/* Background Colors */
--bg-white: #ffffff;            /* Light theme background */
--bg-light: #f8fafc;            /* Light backgrounds */
--bg-light-blue: #eff6ff;       /* Light blue accent */
--bg-light-gray: #f9fafb;       /* Alternate row backgrounds */

/* Border/Divider Colors */
--border-light: #e5e7eb;        /* Light gray borders */
--border-blue: #e0e7ff;         /* Light blue borders */
```

### Responsive Design

Templates use **CSS Grid** for responsive layouts:

```css
.metadata {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 24px;
}
```

This automatically:
- ✅ Stacks on mobile (1 column)
- ✅ Creates 2-3 columns on tablets
- ✅ Creates 4+ columns on desktop
- ✅ Maintains consistent spacing

### Common Styling Patterns

**Box with border and background:**
```css
.box {
    background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
    border-left: 5px solid #9018ad;
    padding: 28px;
    border-radius: 8px;
}
```

**Section divider:**
```css
.section-title {
    border-bottom: 3px solid #9018ad;
    padding-bottom: 14px;
    margin-bottom: 20px;
}
```

**Hover effect (tables):**
```css
table tbody tr:hover {
    background: #f3f4f6;
    transition: background-color 200ms ease;
}
```

**Gradient buttons/boxes:**
```css
.cta-box {
    background: linear-gradient(135deg, #9018ad 0%, #7b1293 100%);
    color: white;
}
```

---

## Jinja2 Template Syntax

### Basic Variable Interpolation

```html
{{ variable }}              <!-- Display variable value -->
{{ variable|upper }}        <!-- Convert to uppercase -->
{{ variable|lower }}        <!-- Convert to lowercase -->
{{ score|round(1) }}        <!-- Round to 1 decimal place -->
```

### Conditional Display

```html
{% if variable %}
    <p>{{ variable }}</p>
{% endif %}

{% if score >= 8 %}
    <span>Excellent</span>
{% elif score >= 6 %}
    <span>Good</span>
{% else %}
    <span>Needs Work</span>
{% endif %}
```

### Loops

**For list items:**
```html
{% for item in items_list %}
    <div>{{ item }}</div>
{% endfor %}
```

**For key-value pairs:**
```html
{% for key, value in dictionary.items() %}
    <tr>
        <td>{{ key }}</td>
        <td>{{ value }}</td>
    </tr>
{% endfor %}
```

### Comments

```html
{# This is a Jinja2 comment - won't appear in HTML #}

<!-- This is an HTML comment - visible in page source -->
```

---

## Common Template Modifications

### Adding a New Section

**Step 1: Choose location in template**
Usually between main content and footer.

**Step 2: Create section HTML**
```html
<div class="new-section-content">
    <h2 class="section-title">New Section Title</h2>
    <p>New section content goes here.</p>
</div>
```

**Step 3: Add CSS for section**
```css
.new-section-content {
    margin-bottom: 40px;
    padding: 24px;
    background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
    border-radius: 12px;
}
```

**Step 4: Test in preview**
Save and refresh PDF Maker dashboard to see changes.

**Step 5: Commit to git**
```bash
git add templates/jumoki_summary_report_light.html
git commit -m "feat: Add new section to summary report"
```

---

### Changing Colors

**To change the primary purple color (#9018ad):**

1. Find all instances in CSS:
   ```bash
   grep -n "9018ad" templates/jumoki_summary_report_light.html
   ```

2. Replace globally:
   ```bash
   sed -i 's/#9018ad/#your-new-color/g' templates/jumoki_summary_report_light.html
   ```

3. Update all 4 templates if consistent branding needed

4. Test preview

5. Commit all 4 files:
   ```bash
   git add templates/jumoki_*.html
   git commit -m "style: Update primary color to #your-new-color"
   ```

---

### Adjusting Spacing

**Common spacing adjustments:**

```css
/* Reduce section gap */
margin-bottom: 40px;  → margin-bottom: 30px;

/* Increase padding */
padding: 24px;        → padding: 36px;

/* Adjust logo spacing */
margin-bottom: 25px;  → margin-bottom: 12px;

/* Table row padding */
padding: 14px;        → padding: 18px;
```

---

### Adding a New Variable

**Step 1: Add variable to backend data (in analyzer.py)**
```python
context = {
    'url': url,
    'summary': summary,
    'new_variable': 'my_value',  # Add this
    # ... other variables ...
}
```

**Step 2: Use in template**
```html
<p>{{ new_variable }}</p>

<!-- Or conditionally -->
{% if new_variable %}
    <p>{{ new_variable }}</p>
{% endif %}
```

**Step 3: Test**
Generate a PDF and verify the variable displays.

**Step 4: Document**
Add to `TEMPLATE_VARIABLES_REFERENCE.md`

**Step 5: Commit both files**
```bash
git add analyzer.py templates/jumoki_*.html TEMPLATE_VARIABLES_REFERENCE.md
git commit -m "feat: Add new_variable to templates and backend"
```

---

### Creating a Template Variation

**Step 1: Duplicate existing template**
```bash
cp templates/jumoki_summary_report_light.html \
   templates/jumoki_summary_report_extended.html
```

**Step 2: Make modifications**
- Add new sections
- Change colors
- Adjust layout
- Update heading text

**Step 3: Test thoroughly**
In PDF Maker dashboard, test the new template.

**Step 4: Update documentation**
Document the new template:
- When to use it
- What's different from original
- Special variables it needs

**Step 5: Commit**
```bash
git add templates/jumoki_summary_report_extended.html
git commit -m "feat: Add extended summary report template with more details"
```

---

## Testing Template Changes

### Testing in PDF Maker Dashboard (Recommended)

1. **Modify template file locally**
   ```bash
   cd /path/to/weblser
   nano templates/jumoki_summary_report_light.html
   ```

2. **Upload to VPS** (or edit directly on VPS)
   ```bash
   scp templates/jumoki_summary_report_light.html \
       root@140.99.254.83:/var/www/pdf-maker/templates/
   ```

3. **Open PDF Maker in browser**
   ```
   https://pdf-maker.jumoki.agency
   Login with credentials
   ```

4. **Select your template and check preview**
   - Verify layout looks correct
   - Check that variables display properly
   - Verify colors and spacing
   - Check both light and dark themes

5. **Generate a test PDF**
   - Click "Generate & Download PDF"
   - Download the PDF
   - Open and verify it looks perfect

6. **If there are issues:**
   - Go back to template
   - Make corrections
   - Save and refresh browser
   - Test again

---

### Testing in Browser (Quick Check)

You can also test by viewing the raw HTML:

1. Right-click on dashboard → "View Page Source"
2. Scroll to the preview section
3. Verify your HTML changes are there
4. Check for syntax errors

---

### Testing Before Committing

**Checklist before git commit:**

- [ ] Template renders in PDF Maker preview
- [ ] All variables display correctly
- [ ] CSS styling looks good
- [ ] Responsive (test mobile view)
- [ ] Jinja2 syntax is correct (no errors)
- [ ] Colors are intentional
- [ ] Spacing is balanced
- [ ] No Lorem ipsum or placeholder text remains
- [ ] All templates match branding (if updated multiple)
- [ ] Generated PDF looks professional

---

## Git Workflow for Template Updates

### Complete workflow:

**1. Create a feature branch** (optional but recommended):
```bash
git checkout -b feature/update-summary-template
```

**2. Make your changes:**
```bash
nano templates/jumoki_summary_report_light.html
```

**3. Test thoroughly** (see Testing section above)

**4. Check what changed:**
```bash
git diff templates/jumoki_summary_report_light.html
```

**5. Stage your changes:**
```bash
git add templates/jumoki_summary_report_light.html
```

**6. Commit with descriptive message:**
```bash
git commit -m "feat: Update summary report colors to match new branding"
```

**Commit message format:**
- `feat:` for new features
- `fix:` for bug fixes
- `style:` for styling changes
- `refactor:` for structural changes
- `docs:` for documentation
- `chore:` for maintenance

**7. Push to GitHub:**
```bash
git push origin feature/update-summary-template
```

**8. Create pull request** (if using GitHub workflow)

**9. Get code review** (recommended)

**10. Merge to main:**
```bash
git checkout main
git merge feature/update-summary-template
git push origin main
```

---

## Best Practices

### DO ✅

1. **Use semantic HTML:**
   ```html
   ✅ Good
   <h2 class="section-title">Key Strengths</h2>

   ❌ Bad
   <div style="font-size: 20px; font-weight: bold;">Key Strengths</div>
   ```

2. **Group related CSS rules:**
   ```css
   ✅ Good
   .section-title {
       font-size: 22px;
       font-weight: 700;
       color: #1f2937;
       margin-bottom: 20px;
   }

   ❌ Bad
   .section-title { font-size: 22px; }
   .section-title { font-weight: 700; }
   .section-title { color: #1f2937; }
   ```

3. **Use consistent spacing:**
   ```css
   /* Use multiples of 8px for consistency */
   margin: 40px;    ✅
   margin: 50px;    ❌
   ```

4. **Test across browsers:**
   - Chrome, Firefox, Safari, Edge
   - Desktop and mobile views

5. **Use classes for styling** (not IDs):
   ```html
   ✅ <div class="summary-box">
   ❌ <div id="summary-box">
   ```

6. **Comment complex logic:**
   ```html
   <!-- Display status badge based on score -->
   {% if score >= 8 %}
       <span class="badge-excellent">Excellent</span>
   {% endif %}
   ```

7. **Test template with real data:**
   - Use actual analysis data when testing
   - Not just placeholder values

8. **Keep templates DRY** (Don't Repeat Yourself):
   ```html
   ✅ Use CSS classes for repeated patterns
   ❌ Copy-paste same HTML multiple times
   ```

---

### DON'T ❌

1. **Don't use inline styles:**
   ```html
   ❌ <div style="background: #9018ad; padding: 20px;">
   ✅ <div class="cta-box">
   ```

2. **Don't hardcode colors:**
   ```html
   ❌ <span style="color: #9018ad;">Text</span>
   ✅ <span class="text-primary">Text</span>
   ```

3. **Don't modify logos manually:**
   - Logos should come from backend variables
   - Don't embed base64 in template

4. **Don't use table for layout:**
   ```html
   ❌ <table><tr><td>Layout</td></tr></table>
   ✅ <div class="grid-layout">
   ```

5. **Don't forget alt text on images:**
   ```html
   ❌ <img src="..." />
   ✅ <img src="..." alt="Company logo" />
   ```

6. **Don't commit test/debug code:**
   - Remove temporary changes before commit
   - Only commit production-ready code

7. **Don't modify templates on production:**
   - Always test locally first
   - Use git workflow
   - Deploy to production after testing

---

## Debugging Tips

### Problem: Variable Shows as Blank

**Check:**
1. Variable name spelling: `{{ variable }}` vs `{{ variabel }}`
2. Variable included in backend: `'variable': value`
3. Variable is not None or empty

**Debug:**
```html
<!-- Temporarily show what variables are available -->
<pre>{{ context|default('No context') }}</pre>
```

---

### Problem: CSS Not Applied

**Check:**
1. CSS selector matches HTML element
2. CSS is in `<style>` tag (in head)
3. Specificity not overridden by another rule

**Debug:**
```css
/* Add temporary border to see element */
.metadata { border: 2px solid red; }
```

---

### Problem: Jinja2 Syntax Error

**Check:**
1. Open and close tags match: `{% if %}...{% endif %}`
2. Variable names correct: `{{ variable }}`
3. Loop syntax: `{% for x in list %}...{% endfor %}`
4. Filter syntax: `{{ value|filter }}`

**Debug:**
Check browser console and VPS logs:
```bash
journalctl -u pdf-maker -f
```

---

### Problem: PDF Looks Wrong

**Check:**
1. Refresh browser (Ctrl+R)
2. Clear cache (Ctrl+Shift+Delete)
3. Try different browser
4. Check original HTML file (maybe upload didn't work)

---

## Performance Optimization

### Keep Template Size Small

**Current size:** ~8-10 KB (good)
**Target:** Stay under 20 KB
**Avoid:** Large embedded images or data

### Optimize CSS

```css
/* Bad - slow */
body * { margin: 0; padding: 0; }

/* Good - specific */
.container { margin: 0; padding: 0; }
```

### Use Efficient Selectors

```css
/* Good */
.summary-box { ... }

/* Slower */
div.container div.summary-box { ... }

/* Much slower */
body div div div.summary-box { ... }
```

---

## Support & Questions

### Common Questions

**Q: Can I use Bootstrap or Tailwind?**
A: No. Keep templates self-contained with inline styles. This makes PDFs portable and reliable.

**Q: Can I add JavaScript?**
A: Not recommended. JavaScript won't work in PDF generation context (Playwright renders as static HTML).

**Q: Can I use external fonts?**
A: Yes, via Google Fonts (like currently done with Raleway). Make sure font loads reliably.

**Q: How do I test on mobile?**
A: Use browser DevTools responsive mode (F12 → device toggle) or test on actual phone.

**Q: Can I modify templates on production VPS directly?**
A: Avoid if possible. Use git workflow: develop locally, test, commit, push, then deploy.

---

## Related Documents

- **TEMPLATE_VARIABLES_REFERENCE.md** - All available variables
- **PDF_MAKER_USER_GUIDE.md** - For non-technical users
- **PHASE_1_IMPLEMENTATION_PLAN.md** - Overall deployment plan
- **TECHNICAL_IMPLEMENTATION_OCT28.md** - System architecture

---

## Cheat Sheet

### HTML Structure Template

```html
<div class="section">
    <h2 class="section-title">Section Title</h2>
    {% if condition %}
        <div class="section-content">
            {{ variable }}
        </div>
    {% endif %}
</div>
```

### CSS Box Template

```css
.box {
    background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
    border: 1px solid #e5e7eb;
    border-radius: 12px;
    padding: 24px;
    margin-bottom: 36px;
}
```

### Jinja2 Loop Template

```html
{% for item in items_list %}
    <div class="item">
        {{ item.name }}
    </div>
{% endfor %}
```

---

**Questions or issues?** Contact the Technical Lead or Backend Developer.

