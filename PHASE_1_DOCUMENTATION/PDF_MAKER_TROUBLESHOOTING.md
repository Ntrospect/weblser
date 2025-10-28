# PDF Maker Troubleshooting Guide
## Jumoki Agency - Complete Diagnostic & Resolution Reference

**Document Version:** 1.0
**Created:** October 28, 2025
**For:** DevOps, Support, and Technical Teams
**Severity Levels:** Low 🟢 | Medium 🟡 | Critical 🔴

---

## Quick Diagnosis Tree

**Start here to quickly identify your issue:**

```
PDF Maker not working?
│
├─ Can't access https://pdf-maker.jumoki.agency?
│  └─ → "Cannot Connect" Issues (below)
│
├─ Login works but dashboard won't load?
│  └─ → "Dashboard Loading" Issues (below)
│
├─ Dashboard loads but preview is blank?
│  └─ → "Preview Rendering" Issues (below)
│
├─ Can't generate PDF / PDF button does nothing?
│  └─ → "PDF Generation" Issues (below)
│
├─ PDF generated but looks wrong?
│  └─ → "PDF Quality" Issues (below)
│
├─ Logo not showing in PDF?
│  └─ → "Logo Display" Issues (below)
│
└─ Performance/Slowness issue?
   └─ → "Performance" Issues (below)
```

---

## Category 1: Cannot Connect to PDF Maker

### Issue: "Cannot reach https://pdf-maker.jumoki.agency"

**Severity:** 🔴 Critical
**Symptoms:**
- Browser shows "Connection refused" or "ERR_CONNECTION_REFUSED"
- "This site can't be reached"
- "Connection timed out"

**Diagnosis Steps:**

1. **Check Internet Connection**
   ```bash
   ping google.com
   # Should show replies, not "unreachable"
   ```
   - If no response: User's internet is down
   - Solution: Check WiFi/Ethernet connection

2. **Check Domain DNS**
   ```bash
   nslookup pdf-maker.jumoki.agency
   # Should return 140.99.254.83
   ```
   - If no response: DNS not set up
   - Solution: Contact DevOps to configure DNS A record

3. **Check VPS is Running**
   ```bash
   # SSH into VPS
   ssh root@140.99.254.83

   # Check systemd service
   systemctl status pdf-maker
   # Should show: active (running)
   ```
   - If "inactive": Service is stopped
   - Solution: `systemctl start pdf-maker`

4. **Check Nginx is Running**
   ```bash
   systemctl status nginx
   # Should show: active (running)
   ```
   - If "inactive": Nginx stopped
   - Solution: `systemctl start nginx`

5. **Test Nginx Port**
   ```bash
   netstat -tlnp | grep 80
   netstat -tlnp | grep 443
   # Should show nginx listening on both ports
   ```
   - If no output: Nginx not listening
   - Solution: Check Nginx config for errors: `nginx -t`

6. **Check SSL Certificate**
   ```bash
   ls -la /etc/letsencrypt/live/pdf-maker.jumoki.agency/
   # Should show: fullchain.pem, privkey.pem
   ```
   - If files missing: Certificate not installed
   - Solution: Run `certbot certonly --nginx -d pdf-maker.jumoki.agency`

**Resolution Flowchart:**
```
Cannot Connect?
    │
    ├─ Internet down? → Fix internet connection
    │
    ├─ DNS not set? → Add DNS A record (140.99.254.83)
    │
    ├─ VPS not responding? → Check SSH access, restart VPS
    │
    ├─ Service not running? → systemctl start pdf-maker
    │
    ├─ Nginx not running? → systemctl start nginx
    │
    ├─ Certificate missing? → certbot certonly --nginx -d [domain]
    │
    └─ Still not working? → Check firewall rules, contact host
```

---

### Issue: "SSL Certificate Error" or "Not Secure"

**Severity:** 🟡 Medium
**Symptoms:**
- Browser shows warning about SSL/TLS
- "Your connection is not private"
- Certificate expired error

**Diagnosis:**
```bash
# Check certificate expiration
openssl x509 -in /etc/letsencrypt/live/pdf-maker.jumoki.agency/fullchain.pem \
  -noout -dates

# Output should show:
# notBefore=Oct 28 2025
# notAfter=Jan 26 2026
```

**Solutions:**

**If certificate expired:**
```bash
# Renew certificate
sudo certbot renew --force-renewal

# Verify renewal
sudo certbot certificates

# Restart Nginx
sudo systemctl reload nginx
```

**If certificate not trusted:**
- Try accessing with IP: `https://140.99.254.83`
- If that fails: Browser issue
- Solution: Update browser or try different browser

**If cert is self-signed:**
- This is OK for internal testing
- Add exception in browser or use `curl -k` for testing

---

### Issue: "Connection Refused" after Login

**Severity:** 🟡 Medium
**Symptoms:**
- Login works fine
- Dashboard starts loading
- Then connection drops

**Diagnosis:**
```bash
# Check if service is crashing
journalctl -u pdf-maker -n 50 | tail -20

# Look for errors like:
# - Memory errors
# - Broken pipe
# - Segmentation fault
```

**Solutions:**

**If service is crashing:**
```bash
# Check system resources
free -h          # Check memory
df -h            # Check disk
top -b -n 1      # Check CPU

# If low on memory:
# - Restart service
# - Check for memory leaks
# - Reduce concurrent users
```

**If Nginx connection drops:**
```bash
# Check Nginx logs
tail -f /var/log/nginx/pdf-maker-error.log

# Common issues:
# - proxy_read_timeout too short
# - Buffer issues
# - Connection upgrades failing

# Check Nginx config
nano /etc/nginx/sites-available/pdf-maker
# Verify proxy_read_timeout >= 60s
```

---

## Category 2: Dashboard Loading Issues

### Issue: Dashboard Loads But Appears Blank/Broken

**Severity:** 🟡 Medium
**Symptoms:**
- Page shows but no content
- Layout is messed up
- CSS not loading
- Images not showing

**Diagnosis:**

1. **Check Browser Console (F12)**
   ```
   Right-click → Inspect → Console tab
   Look for error messages like:
   - GET /styles.css 404 (CSS not found)
   - GET /app.js 404 (JavaScript not found)
   - CORS errors
   ```

2. **Check Server Logs**
   ```bash
   journalctl -u pdf-maker -f
   # Look for HTTP errors: 404, 500, etc.
   ```

3. **Test Plain HTML**
   ```bash
   # Access HTML directly without dashboard JS
   curl -u admin:password https://pdf-maker.jumoki.agency/ | head -50
   ```

**Solutions:**

**If CSS/JS not loading:**
- Verify files exist in pdf_dev_server.py
- Check Nginx static file serving
- Try hard refresh: `Ctrl+Shift+R`
- Clear browser cache: `Ctrl+Shift+Delete`

**If CORS errors:**
```bash
# Check server headers
curl -I https://pdf-maker.jumoki.agency/

# Should include:
# Access-Control-Allow-Origin: *
```

**If layout broken:**
- Clear browser cache
- Try different browser (Chrome, Firefox, Safari)
- Check for console errors

---

### Issue: "Authentication Required" or Login Loop

**Severity:** 🟡 Medium
**Symptoms:**
- Enter credentials correctly but get rejected
- Loop back to login screen repeatedly
- "Invalid credentials" error

**Diagnosis:**

1. **Verify .htpasswd file exists**
   ```bash
   ls -la /etc/nginx/.htpasswd
   cat /etc/nginx/.htpasswd
   # Should show: admin:[hashed-password]
   ```

2. **Test credentials directly**
   ```bash
   # Try to access with curl
   curl -u admin:your-password https://pdf-maker.jumoki.agency/
   # Should work or show 401, not connection error
   ```

3. **Check Nginx auth config**
   ```bash
   grep -A 5 "auth_basic" /etc/nginx/sites-available/pdf-maker
   # Should show:
   # auth_basic "PDF Maker - Restricted Access";
   # auth_basic_user_file /etc/nginx/.htpasswd;
   ```

**Solutions:**

**If .htpasswd missing:**
```bash
# Recreate credentials
sudo htpasswd -c /etc/nginx/.htpasswd admin
# Enter new password when prompted

# Reload Nginx
sudo systemctl reload nginx
```

**If password wrong:**
```bash
# Reset password
sudo htpasswd -D /etc/nginx/.htpasswd admin
sudo htpasswd -c /etc/nginx/.htpasswd admin
# Re-enter password

# Store securely and share with team
```

**If credentials work but login keeps looping:**
- Check for session cookie issues
- Try incognito/private browsing mode
- Clear all cookies for the domain

---

## Category 3: Preview Rendering Issues

### Issue: Preview Pane is Blank or Shows Loading Forever

**Severity:** 🟡 Medium
**Symptoms:**
- Preview area shows nothing
- Spinner spins indefinitely
- "Preview not available" message

**Diagnosis:**

1. **Check JavaScript console**
   ```
   F12 → Console tab
   Look for errors about:
   - Failed to fetch preview
   - Timeout waiting for response
   - JavaScript errors
   ```

2. **Check network requests**
   ```
   F12 → Network tab
   Trigger preview generation
   Look for failed requests or slow responses
   ```

3. **Check server logs**
   ```bash
   journalctl -u pdf-maker -f
   # Look for errors during preview generation
   ```

**Solutions:**

**If preview is slow (>5 seconds):**
- This is normal for first generation
- Subsequent previews should be faster
- If persists, check system resources: `free -h`, `top`

**If preview won't load at all:**
```bash
# Restart the service
sudo systemctl restart pdf-maker

# Check if it comes back
sudo systemctl status pdf-maker

# If still failing, check logs:
sudo journalctl -u pdf-maker -n 100
```

**If JavaScript error:**
- Try different browser
- Clear browser cache
- Check dashboard HTML loads: right-click → View Page Source

---

### Issue: Preview Shows Wrong Template or Old Data

**Severity:** 🟢 Low
**Symptoms:**
- Preview doesn't update after template change
- Shows old version of template
- Selected template not reflected

**Diagnosis:**

1. **Check if change was saved**
   ```bash
   # Compare local and server versions
   diff templates/jumoki_summary_report_light.html \
        /var/www/pdf-maker/templates/jumoki_summary_report_light.html
   ```

2. **Check cache**
   - Browser cache might be outdated
   - Template might be cached in memory

**Solutions:**

**Clear browser cache:**
- Hard refresh: `Ctrl+Shift+R`
- Clear cookies and cache: `Ctrl+Shift+Delete`
- Try incognito mode

**Redeploy template:**
```bash
# Copy latest template to VPS
scp templates/jumoki_summary_report_light.html \
    root@140.99.254.83:/var/www/pdf-maker/templates/

# Restart service to clear cache
ssh root@140.99.254.83 'systemctl restart pdf-maker'
```

**Verify changes on server:**
```bash
# SSH to VPS and check file
ssh root@140.99.254.83
nano /var/www/pdf-maker/templates/jumoki_summary_report_light.html
# Check if your changes are there
```

---

## Category 4: PDF Generation Issues

### Issue: "Generate PDF" Button Does Nothing

**Severity:** 🟡 Medium
**Symptoms:**
- Click button, nothing happens
- No error message
- No PDF download
- No spinner/loading indication

**Diagnosis:**

1. **Check browser console**
   ```
   F12 → Console
   Click the PDF button
   Look for JavaScript errors
   ```

2. **Check network tab**
   ```
   F12 → Network tab
   Click the PDF button
   Look for failed HTTP requests
   Watch for timeout errors
   ```

3. **Check server**
   ```bash
   journalctl -u pdf-maker -f
   # Keep this open, click button in browser
   # Look for any error messages
   ```

**Solutions:**

**If browser error:**
- Try different browser
- Clear browser cache
- Check JavaScript enabled

**If network request fails (404, 500):**
```bash
# Check PDF generation endpoint exists
# in pdf_dev_server.py

# Restart service
sudo systemctl restart pdf-maker

# Try again
```

**If timeout (request never completes):**
- Service might be busy/slow
- Increase timeout in browser or curl
- Check Nginx timeout settings: `proxy_read_timeout`

---

### Issue: PDF Takes Too Long (>30 seconds)

**Severity:** 🟡 Medium
**Symptoms:**
- PDF generation starts
- Browser shows spinner for very long time
- Eventually times out or completes slowly

**Expected times:**
- First generation: 5-10 seconds (Playwright startup)
- Subsequent: 3-5 seconds (cached browser)
- Slow: 10-30 seconds (high load)
- Timeout: >60 seconds (problem)

**Diagnosis:**

1. **Check system resources**
   ```bash
   free -h              # Memory usage
   df -h /              # Disk space
   top -b -n 1          # CPU usage
   ```

2. **Check server load**
   ```bash
   uptime
   # Shows load average - should be < 4 for 4-core CPU
   ```

3. **Check Playwright browser memory**
   ```bash
   ps aux | grep chromium
   # Look for memory usage (VIRT, RES columns)
   ```

**Solutions:**

**If low memory:**
```bash
# Kill unused processes
killall python3 ; systemctl start pdf-maker

# Or reduce memory limit in systemd service
nano /etc/systemd/system/pdf-maker.service
# Edit MemoryLimit=2G to lower value like 1G
systemctl daemon-reload
systemctl restart pdf-maker
```

**If low disk space:**
```bash
# Check disk usage
df -h

# Clean up old logs
journalctl --vacuum=50M  # Keep only 50MB of logs

# Or expand disk (contact host)
```

**If high CPU usage:**
```bash
# Restart service to clear stuck processes
systemctl restart pdf-maker

# Limit CPU in systemd if needed
nano /etc/systemd/system/pdf-maker.service
# CPUQuota=50%  (already set - don't increase)
```

**If still slow:**
- Try reducing concurrent PDF generations
- Implement queue system
- Upgrade server specs

---

### Issue: PDF Generation Fails or Returns Error

**Severity:** 🔴 Critical
**Symptoms:**
- PDF generation starts but errors
- Browser shows error message
- PDF not downloaded
- Server logs show errors

**Diagnosis:**

1. **Check server logs**
   ```bash
   journalctl -u pdf-maker -n 50
   # Look for error messages about:
   # - Template syntax
   # - Playwright crashes
   # - Memory errors
   # - File not found
   ```

2. **Check specific error**
   ```
   Look for:
   - "No such file" → Missing template or file
   - "Timeout" → Playwright hung
   - "Memory error" → Out of RAM
   - "Template error" → Jinja2 syntax issue
   ```

**Solutions:**

**If "No such file" for template:**
```bash
# Verify templates exist
ls -la /var/www/pdf-maker/templates/

# If missing, upload them
scp templates/*.html root@140.99.254.83:/var/www/pdf-maker/templates/
```

**If Playwright error:**
```bash
# Check if Playwright installed
/var/www/pdf-maker/venv/bin/python3 -c "import playwright; print(playwright.__version__)"

# If error, reinstall
cd /var/www/pdf-maker
source venv/bin/activate
pip install playwright
playwright install chromium
```

**If template syntax error:**
1. Check template in editor for Jinja2 syntax
2. Look for unclosed `{% %}` or `{{ }}`
3. Test template locally before deploying
4. Run Python Jinja2 test:
   ```python
   from jinja2 import Template
   t = Template(open('template.html').read())
   print("Template OK")
   ```

**If memory error:**
```bash
# Restart service
systemctl restart pdf-maker

# Monitor memory during generation
watch -n 1 'free -h'
```

---

## Category 5: PDF Quality Issues

### Issue: PDF Generated But Content is Missing/Blank

**Severity:** 🟡 Medium
**Symptoms:**
- PDF file exists and is reasonable size
- But content is blank or incomplete
- Text not showing
- Sections missing

**Diagnosis:**

1. **Check PDF in different viewer**
   - Adobe Reader
   - Different browser
   - Online PDF viewer
   - If one works but others don't, it's a viewer issue

2. **Check file is valid PDF**
   ```bash
   # Download PDF to VPS
   file report.pdf
   # Should show: "PDF document, version 1.4"

   # Check PDF integrity
   pdftotext report.pdf -  # Try to extract text
   ```

3. **Check variables in template**
   ```bash
   # Verify variables are being passed
   # Check logs for variable values
   journalctl -u pdf-maker -f
   ```

**Solutions:**

**If blank in some viewers:**
- Try different PDF viewer
- Re-download the PDF
- Check browser PDF viewer settings

**If content missing:**
- Verify all template variables are passed from backend
- Check for Jinja2 errors in logs
- Test template with sample data locally

**If file is corrupted:**
```bash
# Try regenerating
# Click button again in dashboard

# If still corrupt:
# Check disk space: df -h /
# Restart service: systemctl restart pdf-maker
```

---

### Issue: PDF Layout is Broken or Text Overlaps

**Severity:** 🟡 Medium
**Symptoms:**
- Text overlaps or runs off page
- Columns misaligned
- Spacing wrong
- Layout different from preview

**Diagnosis:**

1. **Compare preview vs. PDF**
   - Does preview look correct?
   - If yes: Browser issue
   - If no: Template issue

2. **Check CSS in template**
   - Are widths specified?
   - Are breakpoints correct?
   - Any position: absolute without bounds?

3. **Check content length**
   - Is text too long for allocated space?
   - Are margins/padding correct?

**Solutions:**

**If preview correct but PDF wrong:**
- Playwright rendering issue
- Try different template
- Might be browser-specific

**If preview also wrong:**
- Fix template CSS
- Adjust widths/margins
- Test locally before deploying
- See TEMPLATE_EDITING_GUIDE.md

**If text overlaps:**
```css
/* Common fixes */
word-break: break-all;      /* For long URLs */
white-space: normal;         /* For wrapping text */
overflow: hidden;            /* For overflowing content */
max-width: 100%;            /* Set boundaries */
```

---

### Issue: Fonts Look Wrong or Don't Match Preview

**Severity:** 🟢 Low
**Symptoms:**
- Font different in PDF than preview
- Text smaller/larger
- Font style not applied
- Wrong typeface

**Diagnosis:**

1. **Check font in CSS**
   ```css
   /* Current template uses: */
   font-family: 'Raleway', sans-serif;
   ```

2. **Check if Google Fonts loads**
   ```
   Look at template head section:
   <link href="https://fonts.googleapis.com/css2?family=Raleway:wght@400;500;600;700;800&display=swap">
   ```

3. **Check font sizes**
   ```
   Are sizes in px? (preferred)
   Are sizes in em? (might scale differently)
   ```

**Solutions:**

**If font not available in PDF:**
- Fallback to system font (sans-serif)
- This is OK, readable but different

**If font looks different:**
- Expected behavior (PDF rendering vs. browser)
- Check preview looks similar to PDF
- Adjust sizes if needed

**If Google Fonts not loading:**
- Check internet connection on VPS
- Might need firewall rule for googleapis.com
- Fallback to system fonts automatically

---

## Category 6: Logo Display Issues

### Issue: Logo Not Showing in PDF

**Severity:** 🟡 Medium
**Symptoms:**
- Logo space is blank
- No image appears where logo should be
- Alt text shows instead of logo

**Diagnosis:**

1. **Check logo variables in backend**
   ```python
   # In analyzer.py or pdf_dev_server.py:
   print(f"websler_logo: {websler_logo}")  # Debug output
   print(f"jumoki_logo: {jumoki_logo}")
   ```

2. **Check logo files exist**
   ```bash
   ls -la *.svg *.png
   # Should show: websler_pro.svg, jumoki_logov3.svg
   ```

3. **Check encoding**
   ```bash
   # SVG should be URL-encoded
   python3 -c "from urllib.parse import quote; print(quote(open('websler_pro.svg').read()))"
   ```

4. **Check template HTML**
   ```html
   <!-- Correct format: -->
   <img src="data:image/svg+xml,{{ websler_logo }}" alt="Websler">

   <!-- Not this (base64 wrong): -->
   <img src="data:image/svg+xml;base64,{{ websler_logo }}" alt="Websler">
   ```

**Solutions:**

**If logo files missing:**
1. Copy logo files to VPS:
   ```bash
   scp websler_pro.svg jumoki_logov3.svg root@140.99.254.83:/var/www/pdf-maker/
   ```

2. Verify files readable:
   ```bash
   ls -la /var/www/pdf-maker/*.svg
   ```

**If logo not encoded correctly:**
1. Check backend code:
   ```python
   # Should be:
   with open('websler_pro.svg') as f:
       websler_logo = quote(f.read())

   # Not:
   websler_logo = base64.b64encode(...)
   ```

2. Fix encoding and restart:
   ```bash
   systemctl restart pdf-maker
   ```

**If logo still not showing:**
- Try regenerating PDF
- Try different template
- Check browser console for image load errors

---

### Issue: Logo Appears but with Wrong Size/Position

**Severity:** 🟢 Low
**Symptoms:**
- Logo visible but too large/small
- Logo positioned wrong
- Logo overlaps text
- Logo proportions wrong

**Solutions:**

**To change logo size:**
```css
/* In template CSS */
.logo-container img {
    max-height: 60px;    /* Change this value */
    width: auto;         /* Keep auto for proportions */
}
```

**To change logo position:**
```css
.logo-container {
    margin-bottom: 25px;    /* Change spacing */
    gap: 20px;              /* Change gap between logos */
}
```

**To fix proportions:**
```html
<!-- Make sure aspect ratio is preserved: -->
<img src="..." style="height: 60px; width: auto;">

<!-- Not: -->
<img src="..." style="height: 60px; width: 100px;">
```

**See:** TEMPLATE_EDITING_GUIDE.md for detailed styling changes

---

## Category 7: Performance & Optimization

### Issue: Slow Dashboard Response / Slow PDF Generation

**Severity:** 🟡 Medium
**Symptoms:**
- Dashboard takes >5 seconds to load
- PDF takes >30 seconds to generate
- Spinner spins for very long time

**Diagnosis:**

```bash
# Check system resources
free -h                    # Memory
df -h /                    # Disk
top -b -n 1               # CPU
uptime                     # Load average
ps aux | grep python3      # Process list
```

**Expected Performance:**
- Dashboard load: 1-2 seconds
- PDF generation: 3-5 seconds (first 10-15 seconds)
- Query response: <1 second

**Solutions:**

**If memory low:**
```bash
# Current memory usage
free -h

# If <500MB free, restart service
systemctl restart pdf-maker

# Monitor after restart
free -h
```

**If disk full:**
```bash
# Check disk
df -h

# Clean logs
journalctl --vacuum=30M

# Remove old files
find /var/www/pdf-maker -name "*.tmp" -delete
```

**If CPU high:**
```bash
# See what's using CPU
top -n 1

# If python3 using 100%+:
# Too many concurrent PDFs being generated
# Kill excess processes and restart:
killall python3
systemctl start pdf-maker
```

**If load average high:**
```bash
# uptime shows load > 4
# System is overwhelmed

# Solutions:
# 1. Wait 5 minutes for load to decrease
# 2. Restart service
# 3. Reduce concurrent users
# 4. Upgrade server
```

---

### Issue: High Memory Usage / Memory Leak

**Severity:** 🟡 Medium
**Symptoms:**
- VPS RAM constantly high (>80%)
- Memory doesn't decrease after PDF generation
- Server gets slower over time
- Eventually crashes

**Diagnosis:**

```bash
# Monitor memory over time
watch -n 5 'free -h'

# Check Python process memory
ps aux | grep python3 | head -5

# Check if memory keeps growing
# Take note of RSS column, check after 10 minutes
```

**Solutions:**

**Restart the service** (temporary fix):
```bash
systemctl restart pdf-maker
free -h    # Check memory back to normal
```

**Long-term fix - Check for leaks:**
1. In pdf_dev_server.py:
   - Look for unclosed file handles
   - Look for objects not being garbage collected
   - Check for circular references

2. Limit Playwright memory:
   ```bash
   nano /etc/systemd/system/pdf-maker.service
   # Add or modify:
   MemoryLimit=1G
   systemctl daemon-reload
   systemctl restart pdf-maker
   ```

3. Restart service regularly (cron job):
   ```bash
   # Add to crontab
   crontab -e
   # Add: 0 2 * * * systemctl restart pdf-maker
   # (Restarts at 2 AM daily)
   ```

---

## Category 8: Integration Issues

### Issue: Backend Can't Find Templates

**Severity:** 🔴 Critical
**Symptoms:**
- Backend analyzer.py fails with "Template not found"
- WebslerPro app can't generate PDFs
- Error: "No such file or directory: templates/"

**Diagnosis:**

```bash
# Check if shared template directory exists
ls -la /var/www/weblser/templates/

# Check template path in backend
grep -n "templates" /var/www/weblser/analyzer.py

# Verify templates are accessible
python3 -c "from pathlib import Path; print(list(Path('/var/www/weblser/templates/').glob('*.html')))"
```

**Solutions:**

**If templates missing:**
1. Copy from PDF Maker:
   ```bash
   cp /var/www/pdf-maker/templates/*.html /var/www/weblser/templates/
   ```

2. Verify access:
   ```bash
   ls -la /var/www/weblser/templates/
   ```

**If path wrong in backend:**
1. Edit analyzer.py:
   ```python
   # Find template loading code
   templates_dir = Path('/var/www/weblser/templates')  # Correct path
   ```

2. Restart backend:
   ```bash
   systemctl restart weblser  # or whatever backend service name
   ```

**If permissions wrong:**
```bash
# Check permissions
ls -la /var/www/weblser/templates/*.html

# Should be readable by www-data:
chmod 644 /var/www/weblser/templates/*.html

# Check directory:
chmod 755 /var/www/weblser/templates/
```

---

## Category 9: Certificate & Security Issues

### Issue: SSL Certificate Expired

**Severity:** 🔴 Critical
**Symptoms:**
- HTTPS shows warning
- Browser shows "certificate expired"
- Can't access with HTTPS

**Diagnosis:**

```bash
# Check certificate expiration
openssl x509 -in /etc/letsencrypt/live/pdf-maker.jumoki.agency/fullchain.pem \
  -noout -dates

# Should show future date:
# notAfter=Jan 26 2026  (not past date)
```

**Solutions:**

```bash
# Renew certificate
sudo certbot renew --force-renewal

# Verify renewal
sudo certbot certificates

# Restart Nginx
sudo systemctl reload nginx

# Test
curl https://pdf-maker.jumoki.agency/
# Should work without warnings
```

---

### Issue: Authentication Failures / Brute Force Attempts

**Severity:** 🔴 Critical
**Symptoms:**
- Repeated 401 errors in logs
- Many failed login attempts from different IPs
- Server being attacked

**Diagnosis:**

```bash
# Check auth failures
grep "401" /var/log/nginx/pdf-maker-error.log | wc -l

# See which IPs are trying
grep "401" /var/log/nginx/pdf-maker-error.log | awk '{print $1}' | sort | uniq -c

# Check htpasswd changes
stat /etc/nginx/.htpasswd
```

**Solutions:**

**Add IP whitelist** (if known IPs):
```nginx
# In /etc/nginx/sites-available/pdf-maker:
allow 192.168.1.0/24;      # Only allow office network
allow 203.0.113.50;         # Specific IP
deny all;                   # Deny everyone else
```

**Use stronger password:**
```bash
# Generate 20-character random password
openssl rand -base64 20

# Update htpasswd
sudo htpasswd -c /etc/nginx/.htpasswd admin
# Enter the strong password

# Reload Nginx
sudo systemctl reload nginx
```

**Block attacking IPs:**
```bash
# Add to firewall (ufw)
sudo ufw deny from 192.0.2.1

# Or with iptables:
sudo iptables -A INPUT -s 192.0.2.1 -j DROP
```

---

## Emergency Recovery Procedures

### Complete Service Down

**If PDF Maker completely unavailable:**

```bash
# Step 1: Emergency restart
sudo systemctl restart pdf-maker pdf-maker.service
sudo systemctl restart nginx

# Step 2: Check status
sudo systemctl status pdf-maker
sudo systemctl status nginx

# Step 3: Check if accessible
curl -k https://pdf-maker.jumoki.agency/

# Step 4: If still down, check critical issues
free -h                    # Is there memory?
df -h /                    # Is there disk space?
sudo journalctl -u pdf-maker -n 100   # What are the errors?
```

### Rollback to Previous Version

```bash
# If recent template change caused problems:

# Check git history
git log --oneline templates/

# Revert to previous version
git checkout HEAD~1 templates/jumoki_summary_report_light.html

# Deploy to VPS
scp templates/jumoki_summary_report_light.html \
    root@140.99.254.83:/var/www/pdf-maker/templates/

# Restart
ssh root@140.99.254.83 'systemctl restart pdf-maker'
```

### Manual Backup & Restore

```bash
# Backup current version
tar -czf pdf-maker-backup-$(date +%Y%m%d).tar.gz \
    /var/www/pdf-maker/templates/

# Restore from backup
tar -xzf pdf-maker-backup-20251028.tar.gz -C /var/www/pdf-maker/
```

---

## Escalation Procedure

### When to Contact Support

**Contact DevOps Lead immediately if:**
- 🔴 Service completely unavailable (can't access at all)
- 🔴 Security breach suspected (unauthorized access)
- 🔴 Data loss or corruption (PDFs corrupt, templates missing)
- 🔴 Certificate errors that won't renew
- 🔴 Persistent memory leaks or crashes

**Contact Backend Developer if:**
- 🟡 Template variables not working
- 🟡 Integration issues with WebslerPro app
- 🟡 PDF content missing or incorrect

**Contact Product Manager if:**
- 🟢 Feature requests for new templates
- 🟢 Design changes needed
- 🟢 Feedback on user experience

### Information to Include in Report

When reporting issues, include:

1. **Error description** - What exactly is happening?
2. **When it started** - When did you first notice?
3. **How to reproduce** - Steps to make it happen again
4. **Error messages** - Exact text from error
5. **Logs** - Copy/paste from journalctl
6. **Environment** - Browser, OS, network
7. **Impact** - How many users affected?
8. **Severity** - 🟢 Low / 🟡 Medium / 🔴 Critical

---

## Quick Reference Commands

```bash
# Check service status
systemctl status pdf-maker nginx

# View logs
journalctl -u pdf-maker -f          # Follow logs
journalctl -u pdf-maker -n 50       # Last 50 lines

# Restart services
systemctl restart pdf-maker
systemctl reload nginx

# Check resources
free -h                 # Memory
df -h /                 # Disk
top                     # CPU/Processes

# Test connection
curl -u admin:pass https://pdf-maker.jumoki.agency/
curl -k https://pdf-maker.jumoki.agency/    # Ignore SSL

# SSH to VPS
ssh root@140.99.254.83

# Edit config files
nano /etc/nginx/sites-available/pdf-maker
nano /etc/systemd/system/pdf-maker.service

# Check certificate
openssl x509 -in /etc/letsencrypt/live/pdf-maker.jumoki.agency/fullchain.pem -noout -dates
```

---

## Related Documents

- **PHASE_1_IMPLEMENTATION_PLAN.md** - Deployment procedures
- **TEMPLATE_EDITING_GUIDE.md** - Template issues
- **PDF_MAKER_USER_GUIDE.md** - User-facing issues
- **TECHNICAL_IMPLEMENTATION_OCT28.md** - System architecture

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Oct 28, 2025 | Initial troubleshooting guide |

---

**Need help?** Contact DevOps: [Name] - [Email]

**Found a new issue?** Add it here and create a PR to update this guide.
