# PDF Development - Quick Start (2 Minutes)

## 🚀 Start Here

### Step 1: Launch the Server (30 seconds)
```bash
# Double-click in Windows Explorer:
start-pdf-dev.bat

# Or from command line:
python pdf_dev_server.py
```

**You should see:**
```
╔══════════════════════════════════════════════════════════════╗
║          🎨 PDF Development Preview Server Started          ║
╠══════════════════════════════════════════════════════════════╣
║  📍 Open in browser:  http://localhost:8888                 ║
```

### Step 2: Open Browser (30 seconds)
- **URL:** http://localhost:8888
- **Bookmark it!** You'll use this a lot

### Step 3: Load a Preview (30 seconds)
1. **Select:** Summary Report (or Audit)
2. **Theme:** Light (or Dark)
3. **Data:** Example.com
4. **Click:** "Load Preview"

**Result:**
- Left side = PDF preview
- Right side = Template editor
- Both update together

---

## ✏️ Workflow: 3-Step Iteration

### Step 1: Edit Template
- Find the section you want to improve in the right panel
- Edit the HTML/CSS
- Preview updates are instant

### Step 2: Save & Reload
- Click "**💾 Save & Reload**" button
- PDF re-renders with your changes

### Step 3: Repeat
- Make more edits
- Keep saving and reloading
- Until it looks perfect!

---

## 🎯 Quick Wins You Can Try

### 1. Better CTA Button (2 minutes)
In summary template, find:
```html
<div class="cta-box">
    <h3>Ready for Deeper Insights?</h3>
```

**Try:**
- Change color to brighter purple
- Add an icon emoji like "🚀"
- Change button text to be more action-oriented

### 2. Add Separator Line (1 minute)
Between sections, add:
```html
<div style="border-bottom: 2px solid #e5e7eb; margin: 30px 0;"></div>
```

### 3. Better Section Titles (2 minutes)
Find:
```html
<h2 class="section-title">Executive Summary</h2>
```

**Try:**
- Add background color
- Add padding
- Make text larger/bolder

### 4. Visual Score Card (5 minutes)
For audit scores, instead of plain text:
```html
<div style="display: inline-block;
           background: #e0f2fe;
           padding: 8px 12px;
           border-radius: 6px;
           font-weight: bold;">
  {{ score }}/10
</div>
```

---

## 📊 Template Variables Reference

### Summary Reports
```
{{ url }}                  // https://example.com
{{ title }}                // Example Domain
{{ summary }}              // AI-generated text
{{ timestamp }}            // October 27, 2025 at 2:45 PM
{{ company_name }}         // Jumoki Agency LLC
{{ company_details }}      // Address, phone, email
```

### Audit Reports
```
{{ url }}                  // https://example.com
{{ overall_score }}        // 8.5 (number 0-10)
{{ categories }}           // Dict: {'Performance': 8.2, 'Security': 7.1, ...}
{{ strengths }}            // List of bullet points
{{ timestamp }}            // October 27, 2025 at 2:45 PM
{{ company_name }}         // Jumoki Agency LLC
{{ company_details }}      // Address, phone, email
```

---

## 🔧 Common Edits

### Change Color
```css
/* Old */
color: #9018ad;

/* New - try these */
color: #7c3aed;  /* Vibrant purple */
color: #2563eb;  /* Blue */
color: #059669;  /* Green */
```

### Increase Font Size
```css
/* Old */
font-size: 16px;

/* New */
font-size: 18px;  /* Larger */
```

### Add More Spacing
```css
/* Old */
margin-bottom: 20px;

/* New */
margin-bottom: 40px;  /* Bigger gap */
```

### Better Borders
```css
/* Old */
border: 1px solid #e5e7eb;

/* New */
border: 2px solid #9018ad;  /* Thicker, purple */
border-radius: 12px;        /* Rounded corners */
```

---

## ❌ When It's Broken (Quick Fixes)

### "PDF is blank"
- Server might not be running → Restart with `start-pdf-dev.bat`
- Browser might be cached → Hard refresh (Ctrl+Shift+R)
- Playwright might be missing → Run: `pip install playwright`

### "Can't find template"
- Make sure you're editing the right template
- Template must be in `templates/` folder
- Filename must match: `jumoki_[TYPE]_report_[THEME].html`

### "Changes not showing"
- Did you click "Save & Reload"? (not just save!)
- Check browser console (F12) for errors
- Try different test data

### "Fonts look wrong"
- Check internet connection (Google Fonts needs it)
- Clear browser cache (Ctrl+Shift+Delete)
- Restart server

---

## 🎨 Inspiration Ideas

### Make Summary PDFs Better
- ✅ Add visual hierarchy with colors
- ✅ Use icons for different sections
- ✅ Add more whitespace/breathing room
- ✅ Make CTA button more compelling
- ✅ Add trust badges or testimonials
- ✅ Better typography with font weights

### Make Audit PDFs Better
- ✅ Color code scores (red/yellow/green)
- ✅ Add progress bars for each criterion
- ✅ Highlight "Excellent" in green
- ✅ Highlight "Needs Work" in red
- ✅ Add "Quick Wins" section
- ✅ Add implementation timeline
- ✅ Better recommendation display

---

## 📋 Checklist Before Committing

- [ ] Tested with Example.com data
- [ ] Tested with GitHub.com data
- [ ] Tested with Light theme
- [ ] Tested with Dark theme
- [ ] Fonts render correctly
- [ ] Colors look good
- [ ] Layout doesn't break
- [ ] Spacing looks balanced
- [ ] No typos or errors
- [ ] Ready for clients to see!

---

## 🚀 After You're Done

### Save to Git
```bash
# Terminal
git add templates/jumoki_*.html
git commit -m "feat: Improve PDF templates"
git push origin main
```

### Next TestFlight Build
- Your improved templates will be used automatically
- Clients will see your improvements!

---

## 💡 Pro Tips

1. **Test multiple scenarios** - Short text, long text, high scores, low scores
2. **Use the browser's inspect tool** (F12) to debug styling
3. **Keep it simple** - Best designs are often the cleanest
4. **Mobile view** - Check if PDFs print well on all devices
5. **Commit often** - Small commits are easier to debug if something breaks
6. **Ask for feedback** - Show improvements to business partner before final commit

---

## Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Hard refresh PDF | Ctrl+Shift+R |
| Open dev tools | F12 |
| Save template | Click button or Ctrl+S (in editor) |
| Reload server | Restart server with Ctrl+C then run again |

---

**Time to start:** < 2 minutes ⏱️
**Time to first improvement:** < 5 minutes 🎨
**Ready to deploy:** When it looks great! 🚀

Go to: **http://localhost:8888** and get started! 🎯
