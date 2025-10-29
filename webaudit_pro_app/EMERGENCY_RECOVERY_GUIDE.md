# WEBSLER PRO - EMERGENCY RECOVERY GUIDE
## Quick Reference for Critical Failures

**Last Updated**: October 29, 2025
**Version**: 1.2.1
**Status**: ALL SYSTEMS OPERATIONAL

---

## QUICK RECOVERY MATRIX

| Problem | Symptoms | Recovery Time | Action |
|---------|----------|----------------|--------|
| **Web Down** | websler.pro won't load | < 5 min | See #1 |
| **Backend Down** | API calls timeout | < 5 min | See #2 |
| **Database Down** | Auth fails / history empty | 5-15 min | See #3 |
| **Domain Issues** | DNS error / wrong site | < 1 hour | See #4 |
| **Offline Issues** | Sync stuck, changes lost | < 10 min | See #5 |

---

## 1. WEB APP DOWN (websler.pro unreachable)

**Symptoms**:
- "Connection refused" error
- Page doesn't load
- Shows Firebase 404 page

**Immediate Check** (30 seconds):
```bash
# Test basic connectivity
curl -I https://websler.pro
curl -I https://websler-pro.web.app

# Check Firebase status
# Visit: https://status.firebase.google.com
```

**Recovery Steps** (5 minutes):

```bash
# Step 1: Verify local build is clean
cd /c/Users/Ntro/weblser/webaudit_pro_app
flutter clean
flutter pub get

# Step 2: Rebuild for web
flutter build web --release

# Step 3: Redeploy to Firebase
firebase deploy --only hosting

# Step 4: Verify
curl -I https://websler.pro
# Should return: HTTP/2 200

# Alternative: Verify with browser
# Open: https://websler.pro
# Check: Page loads, login screen appears
```

**Rollback Plan** (if rebuild fails):
```bash
# Restore to previous working version
git log --oneline | head -5
# Find last working commit

git checkout <commit-sha>
flutter build web --release
firebase deploy --only hosting
```

**Escalation**:
- If still failing: Check Firebase console permissions
- Contact: Firebase support or GitHub issues

---

## 2. BACKEND API DOWN (140.99.254.83:8000)

**Symptoms**:
- Web loads but summary/audit generation hangs
- Timeout errors in app logs
- curl to API times out

**Immediate Check** (30 seconds):
```bash
# Test API health
curl http://140.99.254.83:8000/docs
# Should return: Swagger UI page

# Check with browser
# Visit: http://140.99.254.83:8000/docs
```

**Recovery Steps** (5 minutes):

```bash
# Step 1: SSH to VPS
ssh root@140.99.254.83

# Step 2: Check service status
systemctl status webaudit-backend

# Step 3: If not running, start it
systemctl start webaudit-backend

# Step 4: If that fails, restart it
systemctl restart webaudit-backend

# Step 5: Verify it's running
systemctl status webaudit-backend
# Should show: active (running)

# Step 6: Test API
curl http://140.99.254.83:8000/docs
# Should return: 200 OK
```

**Detailed Troubleshooting** (if still down):

```bash
# Check logs
journalctl -u webaudit-backend -f  # Follow logs
journalctl -u webaudit-backend -n 50  # Last 50 lines

# Check if process is running
ps aux | grep python
ps aux | grep uvicorn

# Check port 8000 is listening
netstat -tlnp | grep 8000

# Manually start the service (for debugging)
cd /root/webaudit_pro_app
python3 main.py --host 0.0.0.0 --port 8000
# Ctrl+C to stop
```

**Rebuild Backend** (if service corrupted):

```bash
# SSH to VPS
ssh root@140.99.254.83

# Step 1: Stop service
systemctl stop webaudit-backend

# Step 2: Backup current version
tar czf /root/backup-$(date +%s).tar.gz /root/webaudit_pro_app/

# Step 3: Clone latest code
cd /root
rm -rf webaudit_pro_app
git clone https://github.com/Ntrospect/weblser.git webaudit_pro_app
cd webaudit_pro_app

# Step 4: Install dependencies
pip install -r requirements.txt

# Step 5: Configure environment
# Copy .env from secure location or recreate with credentials:
cat > .env << 'EOL'
SUPABASE_URL=https://vwnbhsmfpxdfcvqnzddc.supabase.co
SUPABASE_ANON_KEY=[Get from https://app.supabase.com/project/vwnbhsmfpxdfcvqnzddc/settings/api]
SUPABASE_SERVICE_ROLE_KEY=[Get from same location]
API_BASE_URL=http://140.99.254.83:8000
ENVIRONMENT=development
EOL

# Step 6: Test manually
python3 main.py

# If works, Ctrl+C and start service
systemctl start webaudit-backend

# Step 7: Verify
systemctl status webaudit-backend
curl http://140.99.254.83:8000/docs
```

**Escalation**:
- Check /var/log/webaudit-backend.log
- Contact VPS provider if systemd or Python issues
- GitHub issues for code problems

---

## 3. DATABASE DOWN (Supabase unavailable)

**Symptoms**:
- Web loads but login fails
- History shows "Error loading data"
- Offline mode is only option

**Immediate Check** (30 seconds):
```bash
# Check Supabase status
# Visit: https://status.supabase.com

# Check project directly
# Visit: https://app.supabase.com/project/vwnbhsmfpxdfcvqnzddc

# Test from phone/browser
# Try login: Should see error message
```

**Recovery Steps** (while Supabase recovers):

**For Users**:
1. App will show "offline" banner
2. Generated summaries/audits save locally
3. Data will sync automatically when online
4. No action needed - continue using app

**For Admin**:

```bash
# Step 1: Check Supabase status page
# https://status.supabase.com

# Step 2: Check project health
# https://app.supabase.com/project/vwnbhsmfpxdfcvqnzddc

# Step 3: If service is up but data corrupted, restore backup
# https://app.supabase.com/project/vwnbhsmfpxdfcvqnzddc
# → Settings → Backups
# → Find timestamp of last good backup
# → Click "Restore"
# → Confirm (will overwrite current data)
# → Wait 5-15 minutes

# Step 4: Verify data restored
# Check project tables:
# → Table Editor → users, audit_results, website_summaries
# → Verify data is back
```

**Extended Downtime Plan** (> 1 hour):

1. **Notify users**: Post status update
2. **Monitor offline usage**: Check app logs for queued syncs
3. **Prepare migration**: If data loss, have backup SQL ready
4. **Auto-sync when online**: When Supabase returns, auto-sync all offline data

**Escalation**:
- Supabase support: https://supabase.com/support
- Check incident history: https://status.supabase.com/history
- Email: support@supabase.io

---

## 4. DOMAIN/DNS ISSUES (websler.pro resolves incorrectly)

**Symptoms**:
- "Cannot reach server" error
- Resolves to wrong IP
- Redirect loop

**Immediate Check** (1 minute):

```bash
# Check DNS resolution
nslookup websler.pro
dig websler.pro

# Expected output:
# websler.pro IN CNAME websler-pro.firebaseapp.com
# websler-pro.firebaseapp.com IN A [Firebase IP]

# Or check online:
# https://mxtoolbox.com/nslookup/websler.pro
```

**Recovery Steps** (< 1 hour):

```bash
# Step 1: Verify Firebase is correct target
# https://console.firebase.google.com
# → Hosting → Domain settings
# → Copy the CNAME target (likely websler-pro.firebaseapp.com)

# Step 2: Update DNS records
# 1. Login to domain registrar (where websler.pro was registered)
# 2. Find DNS settings
# 3. Update/verify records:
#    - websler.pro: CNAME → [Firebase target]
#    - *.websler.pro: CNAME → [Firebase target]
# 4. Wait 24-48 hours for propagation

# Step 3: Verify propagation
# Use: https://www.whatsmydns.net/
# Enter: websler.pro
# Should show Firebase IPs globally

# Step 4: Test when ready
nslookup websler.pro
curl -I https://websler.pro
```

**Bypass Plan** (while DNS propagates):
- Use Firebase URL directly: https://websler-pro.web.app
- Works immediately, no DNS propagation needed
- Share with users: "Use websler-pro.web.app until domain resolves"

**Escalation**:
- Domain registrar support
- Firebase support (if target unclear)
- DNS provider support (if managed separately)

---

## 5. OFFLINE/SYNC ISSUES (Changes not syncing)

**Symptoms**:
- Offline banner shows constantly
- Generated audits not appearing in history
- "Pending sync" message

**Immediate Check** (30 seconds):

```bash
# Check app logs (if you have access)
# Look for: "Sync failed", "Connection error", "Offline"

# Test connectivity from device
# Open any website in browser → should work

# Check backend API
curl http://140.99.254.83:8000/docs
```

**Recovery Steps** (5 minutes):

**User Actions**:
1. Close and reopen app
2. Go to Settings → Check "Sync Status"
3. If "Pending items": Tap "Sync Now" button
4. Wait for sync to complete
5. Check History screen for data

**If Still Not Syncing**:

```bash
# Step 1: Check network
# Device → Settings → WiFi/Network
# Ensure connected to internet

# Step 2: Check backend is accessible
# From device, test: http://140.99.254.83:8000/docs
# Should load (or at least connect)

# Step 3: Check database auth
# App should show "Online" in offline indicator
# If not, Supabase may be down (see #3)

# Step 4: Force sync
# In app Settings → Tap "Force Sync" (if button exists)
# Or: Close app, clear app data (Settings), reopen
```

**Nuclear Option** (last resort):
```bash
# Clear app data and re-login
# Device → Settings → Apps → WebAudit Pro
# → Storage → Clear All Data
# → Reopen app
# → Login again
# → Offline cache will be rebuilt from server

# Note: This will lose any unsynced offline data
# Only do if absolutely necessary
```

**Technical Debug** (admin):

```bash
# Check sync queue on server
ssh root@140.99.254.83
cd /root/webaudit_pro_app

# View recent sync logs
journalctl -u webaudit-backend -g "sync" -n 50

# Check database for pending items
# If using Supabase CLI:
# supabase db pull  # See schema
# psql postgresql://... # Connect to DB
```

**Escalation**:
- Check GitHub issues: https://github.com/Ntrospect/weblser/issues
- Enable debug logging in app (Settings → Debug Mode)
- Share logs with development team

---

## CRITICAL CREDENTIALS REFERENCE

**Keep These Secure** (not in public):

```
Supabase Project: websler-pro
URL: https://vwnbhsmfpxdfcvqnzddc.supabase.co

Credentials Location:
- Local: C:\Users\Ntro\weblser\webaudit_pro_app\.env
- VPS: /root/webaudit_pro_app/.env
- Secure: [Encrypted backup location - TODO]

Firebase Project: websler-pro
Console: https://console.firebase.google.com
Hosting: https://console.firebase.google.com → Hosting

VPS SSH:
Host: 140.99.254.83
User: root
Key: [Private key location]

GitHub:
Repository: https://github.com/Ntrospect/weblser
Branch: main
Commits: Tracked, pushable to remote
```

---

## FULL SYSTEM FAILURE (Everything Down)

**Nuclear Option Recovery** (if all components fail):

```bash
# Step 1: Restore from git snapshot
# This tag: snapshot-phase5-web-deployment-complete
cd ~
git clone https://github.com/Ntrospect/weblser.git websler-restore
cd websler-restore/webaudit_pro_app

# Step 2: Restore credentials
cp /path/to/backup/.env .env
# Or recreate .env with credentials from secure storage

# Step 3: Full system rebuild
# Web:
flutter build web --release
firebase deploy --only hosting

# Backend:
ssh root@140.99.254.83
cd /root
rm -rf webaudit_pro_app
git clone https://github.com/Ntrospect/weblser.git webaudit_pro_app
cp /path/to/backup/.env webaudit_pro_app/.env
cd webaudit_pro_app
pip install -r requirements.txt
systemctl start webaudit-backend

# Database:
# If corrupted, restore Supabase backup:
# https://app.supabase.com → Settings → Backups → Restore

# Verify:
curl -I https://websler.pro
curl http://140.99.254.83:8000/docs
# Both should return 200 OK
```

**Expected Recovery Time**:
- Database: 5-15 minutes (Supabase restore)
- Backend: 10-15 minutes (rebuild + deploy)
- Web: 5-10 minutes (rebuild + deploy)
- DNS: 0-48 hours (TTL dependent)
- **Total**: 20-60 minutes for full recovery

---

## MONITORING CHECKLIST

**Run Daily**:
```bash
# Web app
curl -I https://websler.pro
# Should return: HTTP/2 200

# Backend API
curl http://140.99.254.83:8000/docs
# Should return: HTTP/1.1 200

# Database (visual check)
# https://app.supabase.com/project/vwnbhsmfpxdfcvqnzddc
# Should load without errors
```

**Run Weekly**:
```bash
# Git status
cd /c/Users/Ntro/weblser/webaudit_pro_app
git status
# Should be clean (nothing to commit)

git log -1
# Should show recent commits

# Test full flow
# 1. Open web app: https://websler.pro
# 2. Login with test account
# 3. Generate summary
# 4. Check history
# 5. Generate audit
# 6. Verify all work
```

---

## CONTACT & ESCALATION

**Immediate Response** (all hands):
- GitHub Issues: https://github.com/Ntrospect/weblser/issues
- Slack: [Add team channel]
- Email: [Add team email]

**Technical Contacts**:
- Dev Lead: [Name/Contact]
- Ops Lead: [Name/Contact]
- Product Owner: [Name/Contact]

**External Escalation**:
- Firebase Support: https://firebase.google.com/support
- Supabase Support: https://supabase.com/support
- VPS Provider: [Add provider info]

---

## QUICK REFERENCE CARDS

### Card 1: Web Down Recovery
```
curl -I https://websler.pro              # Check status
cd /c/Users/Ntro/weblser/webaudit_pro_app
flutter clean && flutter pub get         # Clean dependencies
flutter build web --release              # Rebuild
firebase deploy --only hosting           # Redeploy
curl -I https://websler.pro              # Verify
```

### Card 2: Backend Down Recovery
```
ssh root@140.99.254.83                   # Connect to VPS
systemctl status webaudit-backend        # Check status
systemctl restart webaudit-backend       # Restart
journalctl -u webaudit-backend -f        # View logs
curl http://140.99.254.83:8000/docs      # Test API
```

### Card 3: Database Down Recovery
```
https://status.supabase.com              # Check status
https://app.supabase.com/project/...    # Check project
Settings → Backups → Restore             # Restore backup
Wait 5-15 minutes                        # Wait for completion
Test app login                           # Verify
```

### Card 4: Emergency Git Restore
```
git log --oneline | head -5              # Find commit
git checkout <commit-sha>                # Restore state
git clean -fd                            # Remove new files
git reset --hard HEAD                    # Reset to clean state
# Rebuild and redeploy as needed
```

---

## KNOWN ISSUES & WORKAROUNDS

**Issue**: Offline banner stuck on "offline"
- **Workaround**: Close app, reopen, check network connectivity

**Issue**: Old data showing after database restore
- **Workaround**: Clear app data and re-login (Settings → Apps → Clear Data)

**Issue**: Firebase deploy hanging
- **Workaround**: Ctrl+C, try again, or use Firebase console UI

**Issue**: Backend service won't start
- **Workaround**: Check .env file exists, restart with systemctl restart

---

## DISASTER RECOVERY TEST

**Monthly Drill** (every 1st Wednesday):

```bash
# 1. Simulate web failure
# (Don't actually delete, just test rebuild)
cd /c/Users/Ntro/weblser/webaudit_pro_app
flutter clean
flutter build web --release
firebase deploy --only hosting
# Verify: curl -I https://websler.pro

# 2. Simulate backend failure
# (Don't restart, just test procedure)
ssh root@140.99.254.83
systemctl status webaudit-backend
# (Don't restart unless maintenance window)

# 3. Simulate database failure
# (Don't restore, just verify backup exists)
# https://app.supabase.com/project/.../settings/backups
# Verify: Recent backup timestamp exists

# 4. Report results
# Send to team: "All systems tested, recovery procedures verified"
```

---

**Last Tested**: [Date]
**Tested By**: [Name]
**Result**: [PASS/FAIL]
**Next Test**: [Date]

---

**Document Version**: 1.0
**Created**: October 29, 2025
**Last Updated**: October 29, 2025
**Owner**: Operations Team
**Distribution**: Keep printed copy and digital backup
