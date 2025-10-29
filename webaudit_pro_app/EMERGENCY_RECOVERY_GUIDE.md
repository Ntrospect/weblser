# 🚨 EMERGENCY RECOVERY GUIDE

**Use this when something breaks and you need to fix it NOW**

---

## ⚡ SCENARIO 1: Web App Not Loading (websler.pro down)

### ❌ Problem
Website not accessible at https://websler.pro or https://websler-pro.web.app

### ✅ Fix (5-15 minutes)

**Step 1**: Check DNS/CDN status
```bash
curl -v https://websler-pro.web.app
# Should return 200 OK
```

**Step 2**: If returns error, check Firebase
1. Go to https://console.firebase.google.com
2. Click "websler-pro" project
3. Go to Hosting
4. Check "Current release" status

**Step 3**: If status shows error, redeploy
```bash
cd C:\Users\Ntro\weblser\webaudit_pro_app
firebase deploy
```

**Step 4**: Wait 2-5 minutes for CDN cache clear

**Step 5**: Test
```bash
curl https://websler.pro
# Should return HTML (200 OK)
```

### ✨ If Still Not Working
- Check DNS: https://mxtoolbox.com/SuperTool.aspx?action=dns:websler.pro
- Expected A record: 199.36.158.100
- If wrong, update Hostinger DNS settings
- If correct, contact Firebase support

---

## ⚡ SCENARIO 2: Backend API Down (140.99.254.83:8000)

### ❌ Problem
Summary/audit generation fails with connection error or 500 error

### ✅ Fix (5-10 minutes)

**Step 1**: Check if service is running
```bash
ssh root@140.99.254.83
systemctl status weblser --no-pager
```

**Step 2**: If status shows inactive, restart
```bash
systemctl restart weblser
systemctl status weblser --no-pager
# Should show "active (running)"
```

**Step 3**: Test API health
```bash
curl http://140.99.254.83:8000/
# Should return: {"status":"ok","service":"weblser API","version":"1.0.0"}
```

**Step 4**: If still not responding, check logs
```bash
journalctl -u weblser -n 50 --no-pager
# Look for error messages in last 50 lines
```

**Step 5**: If logs show Python errors, check dependencies
```bash
python3 -m pip install fastapi uvicorn requests beautifulsoup4 anthropic anthropic sentry-sdk reportlab jinja2 playwright
systemctl restart weblser
```

### ✨ If Still Not Working
- SSH to VPS: `ssh root@140.99.254.83`
- Check disk space: `df -h` (need > 1GB free)
- Check memory: `free -h` (need > 512MB free)
- Restart machine if needed: `reboot`
- Check .env file: `cat /home/weblser/.env | grep ANTHROPIC`

---

## ⚡ SCENARIO 3: Database Issues

### ❌ Problem
App shows "Database connection error" or can't login

### ✅ Fix (5-15 minutes)

**Step 1**: Check Supabase status
1. Go to https://app.supabase.com
2. Select "websler-pro" project
3. Look at project status (should be ACTIVE_HEALTHY)

**Step 2**: Verify database connectivity
1. Go to SQL Editor in Supabase console
2. Run: `SELECT NOW();`
3. If returns timestamp, database is working

**Step 3**: If database shows degraded, check:
- Network connectivity from app
- Firewall rules (should allow all outbound)
- VPN/proxy issues

**Step 4**: If still down, restore from backup
1. In Supabase console, go to "Backups"
2. Find latest backup (usually within last 24 hours)
3. Click "Restore"
4. Confirm restoration

### ✨ Data Loss Prevention
- Supabase automatically backs up every 24 hours
- You can restore to any point in last 30 days
- All user data is replicated in real-time

---

## ⚡ SCENARIO 4: User Can't Login

### ❌ Problem
Login button shows error or session not restoring

### ✅ Fix (5-10 minutes)

**Step 1**: Clear local cache
```bash
# Windows desktop app
Clear SharedPreferences folder:
%APPDATA%/weblser_pro/

# Web browser
Clear cookies and local storage:
Browser DevTools → Application → Storage → Clear All
```

**Step 2**: Verify Supabase auth is working
1. Go to https://app.supabase.com
2. Select "websler-pro" project
3. Go to "Authentication" → "Users"
4. Look for test accounts (dean@invusgroup.com, dean@jumoki.agency)
5. If missing, create new test user

**Step 3**: Check API token configuration
In app, check that API_BASE_URL points to VPS:
- Open .env file
- Should show: `API_BASE_URL=http://140.99.254.83:8000`

**Step 4**: Test login with known good account
- Use: dean@invusgroup.com
- Password: (check secure notes)

### ✨ If Still Not Working
- Check backend API is running (Scenario 2)
- Check Supabase is healthy (Scenario 3)
- Check auth token not expired
- Review backend logs for auth errors

---

## ⚡ SCENARIO 5: DNS/Domain Issues

### ❌ Problem
websler.pro doesn't resolve or shows Firebase default page

### ✅ Fix (1 hour)

**Step 1**: Check DNS records in Hostinger
1. Go to https://hostinger.com (login to account)
2. Navigate to Domain DNS settings for websler.pro
3. Verify these records:
   - **A Record**: websler.pro → 199.36.158.100 (TTL 3600)
   - **TXT Record**: websler.pro → hosting-site=websler-pro (TTL 14400)

**Step 2**: If records are missing, add them
1. Click "Add Record"
2. Type: A, Name: @, Value: 199.36.158.100, TTL: 3600
3. Click "Add Record"
4. Type: TXT, Name: @, Value: hosting-site=websler-pro, TTL: 14400

**Step 3**: Wait for DNS propagation (15 minutes to 2 hours)
Test with:
```bash
nslookup websler.pro
# Should show: 199.36.158.100
```

**Step 4**: Verify in Firebase console
1. Go to https://console.firebase.google.com
2. Select "websler-pro" project
3. Go to Hosting → "Manage custom domains"
4. Check websler.pro status (should show "connected")

### ✨ If Still Not Working
- Use online DNS checker: https://mxtoolbox.com
- Verify A record points to 199.36.158.100
- May need to wait up to 24 hours for global propagation
- Temporary workaround: Use https://websler-pro.web.app

---

## 🔥 FULL SYSTEM FAILURE (Everything Down)

### Recovery Procedure (30-60 minutes)

**Step 1**: Assess damage
```bash
# Check each component
curl https://websler.pro  # Web
curl http://140.99.254.83:8000/  # Backend
# Check Supabase console for DB status
```

**Step 2**: Restore from Git backup
```bash
cd C:\Users\Ntro\weblser
git log --oneline | head -5  # See recent commits
git reset --hard snapshot-phase5-web-deployment-complete  # Restore to last known good state
```

**Step 3**: Redeploy web app
```bash
cd webaudit_pro_app
firebase deploy
```

**Step 4**: Restart backend
```bash
ssh root@140.99.254.83
systemctl restart weblser
systemctl status weblser
```

**Step 5**: Verify database
- Check Supabase console status
- If degraded, restore from backup

**Step 6**: Verify all systems
```bash
curl https://websler.pro  # Should return 200
curl http://140.99.254.83:8000/  # Should return {"status":"ok"}
```

**Step 7**: Run health checks (see BACKUP_COMPONENTS_INDEX.md)

---

## 🆘 NEED MORE HELP?

### Check These Resources First
1. **SNAPSHOT_PHASE5_WEB_DEPLOYMENT_COMPLETE.md** - Full system documentation
2. **BACKUP_COMPONENTS_INDEX.md** - Component-specific details
3. GitHub Issues: https://github.com/Ntrospect/weblser/issues

### Escalation
If scenario doesn't match your issue:
1. Document exact error message
2. Record timestamps
3. Check logs (see Scenario 2 for log locations)
4. Review recent Git commits (see what changed)
5. Contact development team

### Critical Commands Reference
```bash
# Web deployment
cd C:\Users\Ntro\weblser\webaudit_pro_app
firebase deploy

# Backend restart
ssh root@140.99.254.83
systemctl restart weblser
journalctl -u weblser -n 50 --no-pager

# Database backup restore
# Go to https://app.supabase.com → Backups

# Git rollback
git reset --hard snapshot-phase5-web-deployment-complete
git push -f
```

---

**Created**: October 29, 2025
**Last Updated**: October 29, 2025
**Status**: Production Ready
