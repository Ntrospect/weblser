# Scenario 7: Quick Verification Checklist

Print this page or save it - use it to track progress during testing.

---

## Phase 1: Account Creation ✅

### Account #1 Creation
- [ ] Navigated to https://websler-pro-staging.web.app
- [ ] Clicked "Sign Up"
- [ ] Entered: test1@jumoki.test / TestPassword123!
- [ ] Entered Full Name: Test User 1
- [ ] Accepted Terms
- [ ] Successfully created and logged in
- [ ] Can see Home screen with URL input

### Account #2 Creation
- [ ] Logged out from User #1 (Settings → Logout)
- [ ] Clicked "Sign Up" again
- [ ] Entered: test2@jumoki.test / TestPassword456!
- [ ] Entered Full Name: Test User 2
- [ ] Accepted Terms
- [ ] Successfully created and logged in
- [ ] Can see Home screen with URL input

**Phase 1 Status**: ✅ COMPLETE

---

## Phase 2: Audit Generation ✅

### User #1: example.com Audit
- [ ] Logged in as test1@jumoki.test
- [ ] Entered URL: https://example.com
- [ ] Clicked "Generate Compliance Audit"
- [ ] Saw loading dialog "Running WebAudit Pro..."
- [ ] **Waited 3 minutes** (do NOT close browser)
- [ ] Audit completed successfully
- [ ] Saw Compliance Report with score
- [ ] All 4 jurisdiction tabs present (AU, NZ, GDPR, CCPA)
- [ ] Downloaded PDF - check filename has "example-com" and timestamp
- [ ] **PDF opens and text is visible** (not blacked out)
- [ ] Went to History tab - saw example.com audit
- [ ] Noted the score (e.g., 65/100)
- [ ] Logged out

**User #1 Audit Score**: _________ / 100

### User #2: github.com Audit
- [ ] Logged in as test2@jumoki.test
- [ ] Entered URL: https://github.com
- [ ] Clicked "Generate Compliance Audit"
- [ ] Saw loading dialog "Running WebAudit Pro..."
- [ ] **Waited 3 minutes** (do NOT close browser)
- [ ] Audit completed successfully
- [ ] Saw Compliance Report with score
- [ ] All 4 jurisdiction tabs present
- [ ] Downloaded PDF - check filename has "github-com" and timestamp
- [ ] **PDF opens and text is visible**
- [ ] Went to History tab - **🔴 CRITICAL TEST**:
  - [ ] **ONLY github.com audit visible**
  - [ ] **example.com audit is NOT visible** ← This is the key test!
- [ ] Noted the score (e.g., 72/100)

**User #2 Audit Score**: _________ / 100

**Phase 2 Status**: ✅ COMPLETE

---

## Phase 3: Data Isolation Verification 🔴 CRITICAL

### Test 3.1: User #2 History (Currently logged in)
- [ ] In History tab - see only 1 audit (github.com)
- [ ] Do NOT see example.com audit
- [ ] Click github.com audit - loads correctly
- [ ] Score matches what you noted: _________ / 100
- [ ] Jurisdiction tabs work

**Test 3.1 Result**: ✅ PASS / ❌ FAIL

### Test 3.2: Switch to User #1
- [ ] Logged out from User #2 (Settings → Logout)
- [ ] Logged in as test1@jumoki.test
- [ ] In History tab - see only 1 audit (example.com)
- [ ] Do NOT see github.com audit
- [ ] Click example.com audit - loads correctly
- [ ] Score matches what you noted: _________ / 100
- [ ] Jurisdiction tabs work

**Test 3.2 Result**: ✅ PASS / ❌ FAIL

### Summary
- [ ] User #1 sees ONLY their audits ✅
- [ ] User #2 sees ONLY their audits ✅
- [ ] Cross-user data access is BLOCKED ✅

**Phase 3 Status**: ✅ COMPLETE

---

## Phase 4: Optional - API Verification

### User #1 JWT Token
- [ ] Logged in as User #1
- [ ] Opened DevTools (F12) → Application → Local Storage
- [ ] Found JWT token for User #1
- [ ] Copied to https://jwt.io
- [ ] Found user_id claim: _______________________________________
- [ ] Found email: test1@jumoki.test ✅

### User #2 JWT Token
- [ ] Logged in as User #2
- [ ] Opened DevTools (F12) → Application → Local Storage
- [ ] Found JWT token for User #2
- [ ] Copied to https://jwt.io
- [ ] Found user_id claim: _______________________________________
- [ ] Found email: test2@jumoki.test ✅

### API Test (Optional)
- [ ] Opened PowerShell
- [ ] Ran API test with User #1 token
- [ ] Verified result shows ONLY example.com audit
- [ ] Ran API test with User #2 token
- [ ] Verified result shows ONLY github.com audit

**Phase 4 Status**: ⏳ OPTIONAL

---

## Final Summary

### All Tests Passed? ✅

- [ ] All accounts created successfully
- [ ] All audits generated successfully
- [ ] All PDFs downloaded with correct filenames
- [ ] All PDF text is visible (not blacked out)
- [ ] **User #1 cannot see User #2's audits** ✅
- [ ] **User #2 cannot see User #1's audits** ✅
- [ ] RLS policies are working correctly ✅

### Overall Status

**Scenario 7: ✅ PASSED**

---

## Issues Encountered (if any)

Describe any issues or failures:

```
Issue #1: ___________________________________________________________________

Resolution: _________________________________________________________________


Issue #2: ___________________________________________________________________

Resolution: _________________________________________________________________
```

---

## Completion Time

- Start Time: ________________
- End Time: ________________
- Total Duration: ________________

---

## Next Steps

Once Scenario 7 is complete:

1. ✅ Commit this checklist to Git
2. ✅ Document any issues found
3. ✅ Mark Scenario 7 as COMPLETE in session backup
4. 🚀 Ready for production deployment (if all tests pass)

---

**Signature**: _________________ | **Date**: _________

