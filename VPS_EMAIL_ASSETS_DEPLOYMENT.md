# VPS Email Assets Deployment Guide

**Date**: October 25, 2025
**Status**: Ready to Deploy
**VPS IP**: 140.99.254.83
**VPS Port**: 8000

---

## Overview

Email template logos are now hosted on your VPS FastAPI server instead of using CDN. This provides:
- ✅ Full control over assets
- ✅ Guaranteed availability
- ✅ Fast local serving
- ✅ No external dependencies

---

## What Changed

### FastAPI Server (`fastapi_server.py`)
✅ Added static file serving support:
```python
from fastapi.staticfiles import StaticFiles

# Mount static directory at /static
static_dir = Path(__file__).parent / "static"
if static_dir.exists():
    app.mount("/static", StaticFiles(directory=str(static_dir)), name="static")
```

### Static Directory Structure
```
weblser/
├── fastapi_server.py          (Updated with static file support)
├── static/                     (New - contains email assets)
│   ├── websler_pro_logo-email-confirm.png    (47 KB)
│   └── jumoki_logo-email-confirm.png          (41 KB)
```

### Email Template
Updated `assets/email/confirmation-template.html`:
```html
<!-- Changed from CDN URLs to VPS URLs -->
<img src="http://140.99.254.83:8000/static/websler_pro_logo-email-confirm.png" alt="Websler Pro">
<img src="http://140.99.254.83:8000/static/jumoki_logo-email-confirm.png" alt="Jumoki">
```

---

## Deployment Steps

### Step 1: Copy Files to VPS

From your local machine, copy the updated files to the VPS:

**Option A: Using SCP (Recommended)**

```bash
# Copy FastAPI server
scp C:\Users\Ntro\weblser\fastapi_server.py root@140.99.254.83:/home/weblser/

# Copy static directory with logos
scp -r C:\Users\Ntro\weblser\static root@140.99.254.83:/home/weblser/

# Verify files on VPS
ssh root@140.99.254.83 "ls -lh /home/weblser/static/"
```

**Option B: Using SFTP**

```bash
sftp root@140.99.254.83
cd /home/weblser
put -r C:\Users\Ntro\weblser\static static
put C:\Users\Ntro\weblser\fastapi_server.py fastapi_server.py
exit
```

**Option C: Direct Upload via SSH**

```bash
ssh root@140.99.254.83
cd /home/weblser
mkdir -p static
# Then paste logo files into static directory
```

### Step 2: Verify Files on VPS

```bash
ssh root@140.99.254.83

# Check FastAPI server
cat /home/weblser/fastapi_server.py | grep -A 3 "mount.*static"

# Check static files
ls -lh /home/weblser/static/
# Expected output:
# -rw-r--r-- 47K jumoki_logo-email-confirm.png
# -rw-r--r-- 41K websler_pro_logo-email-confirm.png
```

### Step 3: Restart FastAPI Service

```bash
ssh root@140.99.254.83

# Restart the weblser service
systemctl restart weblser

# Check service status
systemctl status weblser

# Tail logs to verify startup
journalctl -u weblser -f
```

Expected log output:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     Lifespan startup complete
```

### Step 4: Test Logo URLs

From your local machine:

```bash
# Test Websler Pro logo
curl -I http://140.99.254.83:8000/static/websler_pro_logo-email-confirm.png
# Expected: HTTP/1.1 200 OK

# Test Jumoki logo
curl -I http://140.99.254.83:8000/static/jumoki_logo-email-confirm.png
# Expected: HTTP/1.1 200 OK

# Download and verify (optional)
curl http://140.99.254.83:8000/static/websler_pro_logo-email-confirm.png -o websler_test.png
```

Or open in browser:
- http://140.99.254.83:8000/static/websler_pro_logo-email-confirm.png
- http://140.99.254.83:8000/static/jumoki_logo-email-confirm.png

### Step 5: Test Email Template

1. Go to Supabase Dashboard
2. Copy the updated template from: `assets/email/confirmation-template.html`
3. Paste into: **Authentication → Email Templates → Confirmation Email**
4. Sign up with a test email
5. Check email for logos (should display both Websler Pro and Jumoki logos in purple header)

---

## Troubleshooting

### Logos Don't Show in Email

**Problem**: Email displays broken image placeholders

**Solutions**:

1. **Verify VPS is running**
   ```bash
   curl http://140.99.254.83:8000/
   # Should return: {"status":"ok","service":"weblser API","version":"1.0.0"}
   ```

2. **Check static files are accessible**
   ```bash
   curl -v http://140.99.254.83:8000/static/websler_pro_logo-email-confirm.png
   # Should return 200 with image data
   ```

3. **Check firewall rules**
   - Port 8000 must be open on VPS
   - Run: `sudo ufw status`
   - Open if needed: `sudo ufw allow 8000`

4. **Verify FastAPI mounted static files correctly**
   ```bash
   ssh root@140.99.254.83
   cat /home/weblser/fastapi_server.py | grep -A 3 "StaticFiles"
   ```

5. **Restart FastAPI service**
   ```bash
   ssh root@140.99.254.83
   systemctl restart weblser
   sleep 2
   systemctl status weblser
   ```

### Static Files Directory Missing

**Problem**: `FileNotFoundError: static directory not found`

**Solution**:
```bash
ssh root@140.99.254.83
mkdir -p /home/weblser/static
# Copy logo files to /home/weblser/static/
ls -lh /home/weblser/static/
```

### Service Won't Start

**Problem**: FastAPI service fails to start after changes

**Solutions**:

1. **Check for syntax errors**
   ```bash
   ssh root@140.99.254.83
   python3 -m py_compile /home/weblser/fastapi_server.py
   ```

2. **Check service logs**
   ```bash
   journalctl -u weblser -n 50
   ```

3. **Restart with diagnostics**
   ```bash
   systemctl stop weblser
   cd /home/weblser
   python3 fastapi_server.py  # Run manually to see errors
   ```

4. **Rollback if needed**
   ```bash
   cd /home/weblser
   git checkout fastapi_server.py
   systemctl restart weblser
   ```

---

## File Sizes & Performance

| File | Size | Type | Purpose |
|------|------|------|---------|
| websler_pro_logo-email-confirm.png | 41 KB | PNG | Header logo |
| jumoki_logo-email-confirm.png | 47 KB | PNG | Header logo |
| **Total** | **88 KB** | - | Both logos |

**Email Size Impact**:
- Template HTML: ~8 KB
- With embedded logos: ~96 KB total per email
- Email client limit: Usually 25-50 MB
- **Performance**: Excellent ✓

---

## Rollback Plan

If issues occur and you need to revert to CDN:

1. **Update email template**
   ```html
   <!-- Change back to CDN URLs -->
   <img src="https://cdn.jsdelivr.net/gh/Ntrospect/weblser@main/assets/websler_pro_logo-email-confirm.png">
   <img src="https://cdn.jsdelivr.net/gh/Ntrospect/weblser@main/assets/jumoki_logo-email-confirm.png">
   ```

2. **Revert FastAPI server** (optional if not using other static features)
   ```bash
   cd /home/weblser
   git checkout fastapi_server.py
   systemctl restart weblser
   ```

3. **Update Supabase template** with CDN URLs

---

## Monitoring

Monitor email logo delivery:

```bash
# SSH into VPS
ssh root@140.99.254.83

# Monitor static file access logs
tail -f /var/log/weblser.log | grep "static"

# Check disk usage
du -sh /home/weblser/static/

# Monitor VPS traffic
iftop  # Real-time network usage
```

---

## Success Criteria

✅ **Deployment Successful When:**
- [ ] FastAPI service restarts without errors
- [ ] `curl http://140.99.254.83:8000/static/websler_pro_logo-email-confirm.png` returns 200
- [ ] `curl http://140.99.254.83:8000/static/jumoki_logo-email-confirm.png` returns 200
- [ ] Logos display in browser: http://140.99.254.83:8000/static/websler_pro_logo-email-confirm.png
- [ ] Email template updated in Supabase with VPS URLs
- [ ] Test signup email arrives with both logos visible
- [ ] Headers display logos correctly (not broken)

---

## Files Modified

```
C:\Users\Ntro\weblser\
├── fastapi_server.py                          [MODIFIED - Added static file mounting]
├── static/                                     [NEW - Logo assets]
│   ├── websler_pro_logo-email-confirm.png
│   └── jumoki_logo-email-confirm.png
└── webaudit_pro_app/
    └── assets/email/
        └── confirmation-template.html         [MODIFIED - Updated logo URLs to VPS]
```

---

## Testing After Deployment

### Test 1: Direct Logo Access
```bash
# From any machine
curl -o /tmp/test-logo.png http://140.99.254.83:8000/static/websler_pro_logo-email-confirm.png
file /tmp/test-logo.png  # Should be: PNG image data
```

### Test 2: Email Preview
1. Go to Supabase Dashboard
2. Authentication → Email Templates → Confirmation Email
3. Click **Preview** tab
4. Should show both logos in purple header
5. Should show no broken image errors

### Test 3: Full Signup Flow
1. Open Flutter app
2. Click "Create Account"
3. Fill form and submit
4. Check email inbox
5. Logos should display correctly
6. Click verification link
7. Verify auto-login works

---

## Next Steps

1. Deploy files to VPS using steps above
2. Verify logs show successful startup
3. Test logo URLs directly in browser
4. Update Supabase template with new URLs
5. Send test signup email
6. Verify logos appear in email

---

## Support

If deployment issues occur:

1. Check VPS logs: `journalctl -u weblser -n 100`
2. Verify network connectivity: `curl http://140.99.254.83:8000/`
3. Check file permissions: `ls -l /home/weblser/static/`
4. Review troubleshooting section above
5. Rollback to CDN if needed

---

**Status**: Ready to Deploy
**Deployment Difficulty**: Low (3 simple steps)
**Estimated Time**: 5-10 minutes
**Risk Level**: Very Low

Deploy with confidence! 🚀
