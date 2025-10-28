# Template Variables Reference Guide
## PDF Maker - Jinja2 Template Variables

**Document Version:** 1.0
**Created:** October 28, 2025
**Purpose:** Complete reference of all Jinja2 template variables for PDF Maker templates

---

## Overview

All PDF Maker templates use Jinja2 templating syntax to dynamically inject content from the analysis backend. This guide documents all available variables and how to use them in templates.

### Template Location
- Production: `/var/www/pdf-maker/templates/` (VPS)
- Development: `./templates/` (local)
- Shared with WebslerPro backend: `/var/www/weblser/templates/`

### File Naming Convention
- **Summary Reports:** `jumoki_summary_report_[light|dark].html`
- **Audit Reports:** `jumoki_audit_report_[light|dark].html`
- **Variations:** Can create custom templates following same naming pattern

---

## Variable Syntax & Basics

### Simple Variable Interpolation
```html
<!-- Display a variable value -->
<p>{{ variable_name }}</p>

<!-- Output: Value of variable_name -->
```

### Conditional Display (If Variable Exists)
```html
<!-- Only show if variable has a value -->
{% if variable_name %}
    <p>{{ variable_name }}</p>
{% endif %}
```

### Loops (For Each Item in List)
```html
<!-- Iterate over a list of items -->
{% for item in items_list %}
    <div>{{ item }}</div>
{% endfor %}
```

### Loops (For Each Key-Value Pair)
```html
<!-- Iterate over dictionary/object -->
{% for key, value in categories.items() %}
    <tr>
        <td>{{ key }}</td>
        <td>{{ value }}</td>
    </tr>
{% endfor %}
```

### Filters (Transform Values)
```html
<!-- Round decimal numbers -->
{{ score|round(1) }}          <!-- 7.8456 becomes 7.8 -->

<!-- Other useful filters -->
{{ text|upper }}              <!-- Convert to uppercase -->
{{ text|lower }}              <!-- Convert to lowercase -->
{{ text|length }}             <!-- Get string length -->
```

---

## Summary Report Variables

Used in: `jumoki_summary_report_light.html` and `jumoki_summary_report_dark.html`

### Metadata Section Variables

| Variable | Type | Description | Example | Required |
|----------|------|-------------|---------|----------|
| `url` | string | Website URL being analyzed | `https://example.com` | ✅ Yes |
| `title` | string | Page title from `<title>` tag | `Welcome to Example` | ⚠️ Optional |
| `meta_description` | string | Meta description tag content | `We provide amazing services` | ⚠️ Optional |
| `timestamp` | string | Report generation timestamp | `October 28, 2025 - 2:45 PM` | ✅ Yes |

### Logo Variables

| Variable | Type | Description | Format |
|----------|------|-------------|--------|
| `websler_logo` | string | WebslerPro logo SVG data | URL-encoded SVG |
| `jumoki_logo` | string | Jumoki Agency logo SVG data | URL-encoded SVG |

### Company Information Variables

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `company_name` | string | Company name for footer | `Jumoki Agency LLC` |
| `company_details` | string | Contact info for footer | `1309 Coffeen Ave, Sheridan WY 82801` |

### Report Content Variables

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `summary` | string | AI-generated 2-3 sentence summary | `This website is an e-commerce platform...` |

### Example: Summary Report Data Structure
```python
{
    'url': 'https://example.com',
    'title': 'Example - Awesome Products',
    'meta_description': 'Shop online for quality products',
    'summary': 'Example.com is a modern e-commerce platform...',
    'timestamp': 'October 28, 2025 - 2:45 PM',
    'company_name': 'Jumoki Agency LLC',
    'company_details': '1309 Coffeen Ave, Sheridan WY 82801, 1(307)650-2395',
    'websler_logo': '[URL-encoded SVG]',
    'jumoki_logo': '[URL-encoded SVG]'
}
```

### Template Example: Using Summary Variables
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
    {% if meta_description %}
    <div class="metadata-item">
        <span class="metadata-label">Meta Description</span>
        <span class="metadata-value">{{ meta_description }}</span>
    </div>
    {% endif %}
    <div class="metadata-item">
        <span class="metadata-label">Report Generated</span>
        <span class="metadata-value">{{ timestamp }}</span>
    </div>
</div>

<div class="summary-section">
    <h2 class="section-title">Executive Summary</h2>
    <div class="summary-box">
        {{ summary }}
    </div>
</div>
```

---

## Audit Report Variables

Used in: `jumoki_audit_report_light.html` and `jumoki_audit_report_dark.html`

### Metadata Section Variables

| Variable | Type | Description | Example | Required |
|----------|------|-------------|---------|----------|
| `url` | string | Website URL being analyzed | `https://example.com` | ✅ Yes |
| `report_date` | string | Date of audit | `October 28, 2025` | ✅ Yes |
| `overall_score` | float | Overall audit score (0-10) | `7.8` | ✅ Yes |
| `timestamp` | string | Report generation timestamp | `October 28, 2025 - 2:45 PM` | ✅ Yes |

### Evaluation Scores

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `categories` | dict | Dictionary of category scores | `{'Performance': 8.2, 'Security': 7.1, ...}` |

**Available Categories (10-Point Evaluation):**
1. **Performance** - Page load speed, rendering, optimization
2. **Security** - SSL/TLS, security headers, vulnerability checks
3. **SEO** - Meta tags, structured data, mobile-friendliness
4. **Accessibility** - WCAG compliance, screen reader support
5. **Mobile Responsiveness** - Mobile layout, touch targets
6. **Code Quality** - HTML validation, minification, best practices
7. **User Experience** - Navigation, clarity, visual design
8. **Compliance** - GDPR, CCPA, legal requirements
9. **Analytics** - Tracking setup, data collection
10. **Conversion** - CTAs, form optimization, conversion readiness

### Strengths & Issues

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `strengths` | list | List of key strengths | `['Mobile-responsive design', 'Fast load time']` |

### Logo Variables (Same as Summary)

| Variable | Type | Description | Format |
|----------|------|-------------|--------|
| `websler_logo` | string | WebslerPro logo SVG data | URL-encoded SVG |
| `jumoki_logo` | string | Jumoki Agency logo SVG data | URL-encoded SVG |

### Company Information Variables (Same as Summary)

| Variable | Type | Description |
|----------|------|-------------|
| `company_name` | string | Company name for footer |
| `company_details` | string | Contact info for footer |

### Example: Audit Report Data Structure
```python
{
    'url': 'https://example.com',
    'report_date': 'October 28, 2025',
    'overall_score': 7.8,
    'timestamp': 'October 28, 2025 - 2:45 PM',
    'categories': {
        'Performance': 8.2,
        'Security': 7.1,
        'SEO': 8.5,
        'Accessibility': 6.9,
        'Mobile Responsiveness': 9.0,
        'Code Quality': 7.4,
        'User Experience': 8.1,
        'Compliance': 7.2,
        'Analytics': 6.8,
        'Conversion': 7.6
    },
    'strengths': [
        'Mobile-responsive design',
        'Fast page load time',
        'Good SEO structure',
        'Proper security headers'
    ],
    'company_name': 'Jumoki Agency LLC',
    'company_details': '1309 Coffeen Ave, Sheridan WY 82801, 1(307)650-2395',
    'websler_logo': '[URL-encoded SVG]',
    'jumoki_logo': '[URL-encoded SVG]'
}
```

### Template Example: Using Audit Variables

**Displaying Overall Score:**
```html
<div class="metadata">
    <div>
        <div class="metadata-label">Overall Score</div>
        <div class="metadata-value" style="color: #9018ad; font-weight: 700;">
            {{ overall_score|round(1) }}/10
        </div>
    </div>
</div>

<div class="overall-score">
    <div class="score-number">{{ overall_score|round(1) }}</div>
    <div style="font-size: 18px; font-weight: 600;">Overall Website Score</div>
</div>
```

**Displaying Category Scores (Table):**
```html
<div style="margin-bottom: 40px;">
    <h2 class="section-title">10-Point Evaluation</h2>
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
</div>
```

**Displaying Strengths (List):**
```html
<div style="margin-bottom: 40px;">
    <h2 class="section-title">Key Strengths</h2>
    {% for strength in strengths %}
    <div class="list-item">• {{ strength }}</div>
    {% endfor %}
</div>
```

---

## Common Use Cases

### 1. Conditionally Display Content Based on Score

```html
{% if overall_score >= 8 %}
    <div class="excellent-score">
        <h3>Excellent Performance!</h3>
        <p>Your website scores above 8/10. Keep up the great work!</p>
    </div>
{% elif overall_score >= 6 %}
    <div class="good-score">
        <h3>Good Performance</h3>
        <p>Your website is performing well. Consider the recommendations below.</p>
    </div>
{% else %}
    <div class="needs-work-score">
        <h3>Improvement Needed</h3>
        <p>Several areas need attention. Review recommendations below.</p>
    </div>
{% endif %}
```

### 2. Create Progress Bars for Scores

```html
<div class="category-item">
    <div class="category-header">
        <span class="category-name">{{ criterion }}</span>
        <span class="category-score">{{ score|round(1) }}/10</span>
    </div>
    <div class="progress-bar">
        <div class="progress-fill" style="width: {{ (score / 10) * 100 }}%;"></div>
    </div>
</div>
```

### 3. Style Logo Display (SVG Data URI)

```html
<div class="logo-container">
    {% if websler_logo %}
        <img src="data:image/svg+xml,{{ websler_logo }}"
             alt="WebslerPro"
             style="height: 60px; width: auto;">
    {% endif %}
</div>
```

### 4. Format Dates and Times

```html
<div class="metadata-item">
    <span class="metadata-label">Report Generated</span>
    <span class="metadata-value">{{ timestamp }}</span>
</div>
```

### 5. Display Long URLs with Word Breaking

```html
<span class="metadata-value" style="word-break: break-all;">{{ url }}</span>
```

---

## Adding New Variables

To add a new variable to templates:

### 1. Decide Variable Name
Use snake_case format: `my_new_variable`

### 2. Add to Backend Data Structure
In `pdf_dev_server.py` or `analyzer.py`:
```python
context = {
    'url': url,
    'summary': summary,
    'my_new_variable': 'my_value',  # New variable
    # ... other variables
}
```

### 3. Use in Template
```html
<p>{{ my_new_variable }}</p>
```

### 4. Document in This File
Add to appropriate section (Summary or Audit variables)

### 5. Test & Commit
1. Generate test PDF to verify variable renders
2. Commit changes: `git commit -m "feat: Add my_new_variable to templates"`

---

## Variable Type Reference

### String Variables
```html
{{ url }}                 <!-- Direct output -->
{{ url|upper }}          <!-- Convert to uppercase -->
{{ url|lower }}          <!-- Convert to lowercase -->
```

### Numeric Variables
```html
{{ overall_score }}       <!-- Output as-is: 7.845 -->
{{ overall_score|round(1) }}  <!-- Round to 1 decimal: 7.8 -->
```

### List Variables
```html
{% for item in strengths %}
    <div>{{ item }}</div>
{% endfor %}
```

### Dictionary Variables
```html
{% for key, value in categories.items() %}
    <tr>
        <td>{{ key }}</td>
        <td>{{ value }}</td>
    </tr>
{% endfor %}
```

---

## Template Rendering Process

```
Backend Analysis Complete
    ↓
Data collected into context dict
    ↓
Select appropriate template (Summary or Audit)
    ↓
Jinja2 renders template with context variables
    ↓
HTML output passed to Playwright
    ↓
Playwright renders HTML in headless browser
    ↓
PDF generated and returned to user
```

---

## Troubleshooting

### Variable Shows as Blank or `{{ variable }}`
- ✅ Variable name spelled incorrectly
- ✅ Variable not included in backend context dict
- ✅ Variable is `None` or empty

**Solution:** Check spelling and verify backend is passing the variable

### Variable Shows But Is Incomplete
- ✅ Text is truncated in PDF
- ✅ Content is being cut off

**Solution:** Check CSS `max-width` properties and template padding/margins

### Variable Renders with HTML Tags
- ✅ Jinja2 is escaping HTML content (showing `<p>` tags literally)

**Solution:** Use `|safe` filter to mark content as safe:
```html
{{ summary|safe }}
```

### Loops Not Showing Items
- ✅ List/dictionary is empty
- ✅ Variable name incorrect
- ✅ Not using `.items()` for dictionaries

**Solution:** Verify backend is populating the list and check syntax

---

## Best Practices

1. **Always use conditional checks** for optional variables:
   ```html
   {% if title %}
       <p>{{ title }}</p>
   {% endif %}
   ```

2. **Use filters for formatting**:
   ```html
   {{ score|round(1) }}    <!-- Don't rely on Python formatting -->
   ```

3. **Group related variables** in the template:
   ```html
   <!-- Good -->
   <div class="metadata">
       {{ url }}
       {{ title }}
       {{ meta_description }}
   </div>

   <!-- Avoid scattering -->
   {{ url }} ... lots of HTML ... {{ title }} ... more HTML ... {{ meta_description }}
   ```

4. **Use semantic HTML classes** for styling:
   ```html
   <span class="metadata-label">Website URL</span>  <!-- Good -->
   <span class="blue">Website URL</span>            <!-- Avoid -->
   ```

5. **Comment complex Jinja2 logic**:
   ```html
   <!-- Display status badge based on score -->
   {% if score >= 8 %}
       <span class="badge-excellent">Excellent</span>
   {% endif %}
   ```

6. **Test after adding variables**:
   - Add variable to template
   - Save & reload in PDF Maker dashboard
   - Verify it renders correctly in preview
   - Commit to git

---

## Document Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Oct 28, 2025 | Initial release - all current variables documented |

---

## Related Documents

- **PDF_MAKER_USER_GUIDE.md** - For non-technical users
- **TEMPLATE_EDITING_GUIDE.md** - For developers modifying templates
- **PHASE_1_IMPLEMENTATION_PLAN.md** - Overall Phase 1 roadmap
- **TECHNICAL_IMPLEMENTATION_OCT28.md** - System architecture

---

**Questions?** Contact the Technical Lead or DevOps for clarification on variables.
