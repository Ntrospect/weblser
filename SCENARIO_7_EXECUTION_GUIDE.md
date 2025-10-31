# Scenario 7: Multi-User Data Isolation Testing
## Complete Execution Guide

**Status**: Ready to Execute
**Expected Duration**: 35-40 minutes (including audit generation time)
**Critical Goal**: Verify RLS policies prevent cross-user data access

---

## Pre-Flight Checks

Before starting, verify that the system is fully operational:

### ✅ 1. Backend API Status
Run this command to verify the FastAPI backend is running:
```bash
ssh root@140.99.254.83 "systemctl status weblser"
```

**Expected Output:**
- Status should show: `active (running)`
- Port should be: `443` (HTTPS)
- Service should have restarted recently

### ✅ 2. Frontend Availability
Open this URL in your browser:
```
https://websler-pro-staging.web.app
```

**Expected Result:**
- Landing page loads
- "Sign Up" option visible
- No errors in browser console (F12 → Console tab)

### ✅ 3. Database Connectivity
Verify Supabase is accessible:
```bash
ssh root@140.99.254.83 "curl -s https://vwnbhsmfpxdfcvqnzddc.supabase.co/rest/v1/ \
  -H 'Authorization: Bearer [ANON_KEY]' \
  -H 'Content-Type: application/json' | head -20"
```

**Expected Result:**
- No connection errors
- Database is reachable from backend

---

## Phase 1: Create Test Accounts

### Step 1.1: Create Account #1 (Test User 1)

1. **Open the app**: Navigate to https://websler-pro-staging.web.app
2. **Click "Sign Up"** button
3. **Fill in the form:**
   - Full Name: `Test User 1`
   - Email: `test1@jumoki.test`
   - Password: `TestPassword123!`
   - Confirm Password: `TestPassword123!`
4. **Accept Terms** checkbox ✓
5. **Click "Sign Up"** button
6. **Wait** for signup confirmation (should show success message)
7. **Note**: You should now be logged in as User #1

### Step 1.2: Create Account #2 (Test User 2)

1. **Go to Settings** (bottom menu)
2. **Click "Logout"** button
3. **Confirm logout** (may show confirmation dialog)
4. **You should now see the Sign Up screen again**
5. **Click "Sign Up"** (or if on Login screen, click "Sign Up" link)
6. **Fill in the form:**
   - Full Name: `Test User 2`
   - Email: `test2@jumoki.test`
   - Password: `TestPassword456!`
   - Confirm Password: `TestPassword456!`
7. **Accept Terms** checkbox ✓
8. **Click "Sign Up"** button
9. **Wait** for signup confirmation
10. **You should now be logged in as User #2**

**Checkpoint 1 Complete**: Two separate accounts created ✅

---

## Phase 2: Generate Audits (Different URLs)

### Step 2.1: User #1 Generates Audit for example.com

**Currently logged in as**: User #2
**First, switch to User #1:**

1. **Go to Settings**
2. **Click "Logout"**
3. **Click "Log In"**
4. **Enter credentials:**
   - Email: `test1@jumoki.test`
   - Password: `TestPassword123!`
5. **Click "Log In"**
6. **Wait** for authentication

**Now generate the audit:**

7. **You should be on the Home screen**
8. **Find the "Enter URL to analyze" input field**
9. **Type**: `https://example.com`
10. **Click "Generate Compliance Audit"** button
11. **Wait for completion** (~3 minutes)
    - You should see a loading dialog: "Running WebAudit Pro..."
    - Do NOT close the browser or navigate away
12. **When complete**, you should see:
    - The Compliance Report screen with "Overall Score" displayed
    - 4 jurisdiction tabs (Australia, New Zealand, GDPR, CCPA)
    - A "Download PDF" button
13. **Click "Download PDF"**
    - Check your Downloads folder
    - **Filename should contain**: `example-com` and a timestamp
    - **Expected format**: `compliance-report_example-com_20251031_HHMMSS.pdf`
14. **Go to History tab**
    - **Verify**: One audit visible for example.com
    - **Note the score** (e.g., 65/100)
15. **Logout** (Settings → Logout)

**Checkpoint 2.1 Complete**: User #1 audit generated ✅

### Step 2.2: User #2 Generates Audit for github.com

**Now switch to User #2:**

1. **Click "Log In"**
2. **Enter credentials:**
   - Email: `test2@jumoki.test`
   - Password: `TestPassword456!`
3. **Click "Log In"**
4. **Wait** for authentication

**Generate the audit:**

5. **Find the URL input field**
6. **Type**: `https://github.com`
7. **Click "Generate Compliance Audit"** button
8. **Wait for completion** (~3 minutes)
    - Loading dialog should appear
9. **When complete**, verify you see:
    - Compliance Report with score
    - 4 jurisdiction tabs
    - Download PDF button

**🔴 CRITICAL TEST**: Before proceeding, look at the History tab:
- **You should see ONLY**: github.com audit
- **You should NOT see**: example.com audit (from User #1)
- **If you see both**, there is a data isolation problem! Report this immediately.

10. **Click "Download PDF"**
    - Check Downloads folder
    - **Filename should contain**: `github-com` and timestamp
11. **Stay logged in as User #2** (don't logout yet)

**Checkpoint 2.2 Complete**: User #2 audit generated ✅

---

## Phase 3: Verify Data Isolation (CRITICAL TESTS)

This is the most important phase. RLS policies must prevent cross-user access.

### Test 3.1: User #2's History (Currently logged in)

**Currently**: Logged in as User #2

**Verification tasks:**

1. **Go to History tab**
2. **Look at the audit list:**
   - [ ] Only github.com audit should be visible
   - [ ] example.com audit must NOT be visible
   - [ ] Count should be: 1 audit
3. **Click on the github.com audit**
   - [ ] Audit details load correctly
   - [ ] Score displayed
   - [ ] Jurisdiction tabs work
4. **Try to click example.com (if it appears - it shouldn't)**
   - [ ] It should not appear in the list
   - [ ] If it does, this is a CRITICAL FAILURE ❌

**Result**: ✅ PASS (User #2 sees only their data)

### Test 3.2: Switch to User #1

1. **Go to Settings**
2. **Click "Logout"**
3. **Click "Log In"**
4. **Enter credentials:**
   - Email: `test1@jumoki.test`
   - Password: `TestPassword123!`
5. **Click "Log In"**
6. **Wait** for authentication

**Verification tasks:**

7. **Go to History tab**
8. **Look at the audit list:**
   - [ ] Only example.com audit should be visible
   - [ ] github.com audit must NOT be visible
   - [ ] Count should be: 1 audit
9. **Click on the example.com audit**
   - [ ] Audit details load correctly
   - [ ] Score displayed (should match what you saw earlier)
   - [ ] Jurisdiction tabs work
10. **Verify github.com NOT visible**
    - [ ] Should not appear anywhere in History
    - [ ] If it appears, this is a CRITICAL FAILURE ❌

**Result**: ✅ PASS (User #1 sees only their data)

**Checkpoint 3 Complete**: Data isolation verified ✅

---

## Phase 4: API-Level Verification (Optional but Recommended)

This validates that the RLS policies are working at the database level, not just the UI.

### Step 4.1: Inspect JWT Token

1. **While logged in as User #1**, press **F12** (Developer Tools)
2. **Go to Application tab** (or Storage tab in Firefox)
3. **Find Local Storage** section
4. **Look for Supabase auth data**
5. **Find the JWT token** (usually under `auth.currentSession`)
6. **Copy the token** (just the token, not the whole object)
7. **Visit https://jwt.io**
8. **Paste the token** in the Encoded section
9. **Look at Decoded section** for:
    - `user_id` field (should be a UUID)
    - `email` field (should be `test1@jumoki.test`)
10. **Note down the user_id** (e.g., `f47ac10b-58cc-4372-a567-0e02b2c3d479`)

### Step 4.2: Test API Endpoint with User #1 Token

1. **Open terminal/PowerShell**
2. **Run this command** (replace USER_ID_1 with the user_id from Step 4.1):
```powershell
$token = "YOUR_JWT_TOKEN_HERE"
$url = "https://websler-pro-staging.web.app/api/compliance-audit/history/list"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$response = Invoke-WebRequest -Uri $url -Headers $headers -UseBasicParsing
$json = $response.Content | ConvertFrom-Json

Write-Host "Audits visible to User #1:"
$json | ForEach-Object {
    Write-Host "- URL: $($_.website_url), Score: $($_.overall_score)"
}
```

3. **Expected Output**:
   - Should show: example.com audit
   - Should NOT show: github.com audit

### Step 4.3: Logout and Test User #2 Token

1. **Logout from User #1**
2. **Login as User #2** (test2@jumoki.test)
3. **Repeat Step 4.1** to get User #2's JWT token
4. **Repeat Step 4.2** with User #2's token
5. **Expected Output**:
   - Should show: github.com audit
   - Should NOT show: example.com audit

**Result**: ✅ Backend RLS policies are enforcing data isolation

---

## Success Criteria Checklist

Mark each item as you complete it:

- [ ] **Account Creation**
  - [ ] test1@jumoki.test account created ✅
  - [ ] test2@jumoki.test account created ✅

- [ ] **Audit Generation**
  - [ ] User #1 audit for example.com generated ✅
  - [ ] User #2 audit for github.com generated ✅
  - [ ] PDF filenames include domain and timestamp ✅

- [ ] **Data Isolation (CRITICAL)**
  - [ ] User #1 sees ONLY example.com audit ✅
  - [ ] User #1 does NOT see github.com audit ✅
  - [ ] User #2 sees ONLY github.com audit ✅
  - [ ] User #2 does NOT see example.com audit ✅

- [ ] **File Integrity**
  - [ ] PDF for example.com downloads and opens ✅
  - [ ] PDF for github.com downloads and opens ✅
  - [ ] Both PDFs have readable text (fixed by commit 9569e19) ✅

- [ ] **Optional: API Verification**
  - [ ] User #1 JWT token validated ✅
  - [ ] User #2 JWT token validated ✅
  - [ ] API returns correct user-scoped data ✅

---

## Troubleshooting

### Issue: Can't Sign Up (Error "Email already in use")
- **Cause**: Accounts already exist from previous test runs
- **Solution**: Use different email addresses (e.g., test1-v2@jumoki.test)
- **Or**: Contact Supabase admin to delete test users

### Issue: Audit Takes Too Long (> 5 minutes)
- **Cause**: Backend might be slow or overloaded
- **Solution**: Check VPS logs: `ssh root@140.99.254.83 "tail -50 /tmp/fastapi.log"`
- **Escalation**: If logs show errors, redeploy backend

### Issue: User #1 Can See User #2's Audits
- **Cause**: RLS policies not working correctly
- **CRITICAL**: This is a security issue
- **Solution**:
  1. Check Supabase RLS policies: https://app.supabase.com/projects
  2. Verify JWT token has correct user_id
  3. Check backend is using correct Supabase service role key
  4. If needed, rollback: `git reset --hard 6257de9`

### Issue: PDF Download Not Working
- **Cause**: Blob URL mechanism failing
- **Solution**: Check browser console for errors (F12 → Console)
- **If error**: "Failed to execute 'createObjectURL' on 'URL'"
  - Means PDF bytes are invalid
  - Check backend logs for PDF generation errors
  - Verify ReportLab is installed: `python3 -m pip list | grep reportlab`

### Issue: Filenames Don't Have Domain
- **Cause**: Backend PDF generation using old code
- **Solution**: Verify commit d7f457d is deployed
- **Command**: `ssh root@140.99.254.83 "grep 'domain_clean' /home/weblser/fastapi_server.py"`
- **Expected**: Should find the domain extraction code

---

## Post-Test Documentation

Once you complete all phases, document the results:

### Template for Results:

```markdown
## Scenario 7 Test Results - [DATE]

### Environment
- Frontend: websler-pro-staging.web.app
- Backend: 140.99.254.83:8000
- Database: websler-pro (Supabase)

### Test Accounts Created
- User #1: test1@jumoki.test ✅
- User #2: test2@jumoki.test ✅

### Audits Generated
- User #1 (example.com): Score 65/100 ✅
- User #2 (github.com): Score 72/100 ✅

### Data Isolation Results
- User #1 History: Only example.com visible ✅
- User #2 History: Only github.com visible ✅
- Cross-user access blocked: YES ✅

### PDF Filenames
- User #1: `compliance-report_example-com_20251031_095432.pdf` ✅
- User #2: `compliance-report_github-com_20251031_101245.pdf` ✅

### API-Level Verification
- User #1 JWT validated ✅
- User #2 JWT validated ✅
- RLS policies enforcing data isolation ✅

### Conclusion
✅ SCENARIO 7 PASSED - All multi-user data isolation tests successful!
```

---

## Quick Commands Reference

**If you need to restart backend during testing:**
```bash
ssh root@140.99.254.83 "systemctl restart weblser && systemctl status weblser"
```

**View recent backend errors:**
```bash
ssh root@140.99.254.83 "tail -100 /tmp/fastapi.log | grep -i 'error\|exception\|failed'"
```

**Check database table for stored audits:**
```bash
# This requires Supabase access, but shows what's stored
# Query: SELECT user_id, website_url, overall_score FROM compliance_audits ORDER BY created_at DESC;
```

---

## Expected Outcomes Summary

| Test | Expected Result | Status |
|------|-----------------|--------|
| User #1 account creation | Account created with email | ⏳ Pending |
| User #2 account creation | Account created with email | ⏳ Pending |
| User #1 audit generation | Audit for example.com generated | ⏳ Pending |
| User #2 audit generation | Audit for github.com generated | ⏳ Pending |
| **Data Isolation #1** | **User #1 sees only example.com** | **⏳ CRITICAL** |
| **Data Isolation #2** | **User #2 sees only github.com** | **⏳ CRITICAL** |
| PDF filename quality | Filenames have domain and timestamp | ⏳ Pending |
| API-level isolation | RLS policies enforced at API | ⏳ Pending |

---

## Timeline Estimate

- **Phase 1 (Account Creation)**: 5 minutes
- **Phase 2.1 (User #1 Audit)**: 3-5 minutes (waiting for audit to complete)
- **Phase 2.2 (User #2 Audit)**: 3-5 minutes (waiting for audit to complete)
- **Phase 3 (Data Isolation)**: 5 minutes (manual verification)
- **Phase 4 (API Testing)**: 5 minutes (optional)
- **Total**: 25-35 minutes active time + 6-10 minutes waiting for audits

---

**🚀 Ready to Begin?** Start with **Phase 1: Step 1.1** - Opening the app and creating Account #1.

**Need Help?** Check the **Troubleshooting** section above or contact support.

**Important**: Document results in Phase 4 template above for handoff to next session.
