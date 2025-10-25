# Session Debug Log - Email Verification Hang Issue

**Date**: October 25, 2025
**Status**: DEBUGGING - Email verification flow hangs, improved logging added
**Current Build**: ✅ Running successfully with enhanced debugging

## Session Summary

This session focused on debugging why the "Check your email" screen hangs instead of auto-logging in after email verification.

### What Works ✅
- App builds successfully
- Callback server starts on localhost:3000
- Signup form works and accepts emails
- "Check Your Email" screen displays beautifully (improved in this session)
- Email is sent by Supabase
- Email link is clicked and callback server receives it
- Token is parsed from URL: `764832` (6-digit OTP)

### What Doesn't Work ❌
- After callback server receives token, the monitoring code doesn't detect it
- Screen hangs indefinitely on "Check Your Email"
- No auto-login occurs
- Times out silently after 30 seconds with no feedback

## Key Discovery

**Console Output from Previous Test** (Oct 25, 11:03 AM):
```
✅ Sign up successful: cj@stikistones.com
📧 Confirmation email sent - waiting for user to verify...
! Email verification required for: cj@stikistones.com
📧 Waiting for user to click confirmation link...

📨 Received request: ?token=764832&type=signup
📨 Full URL: http://localhost:3000/?token=764832&type=signup
📨 Parsing query parameters...
📨 Query params: {token: 764832, type: signup}
✅ Auth token received from query: 764832 (length: 6)
✅ Token type: signup
```

**What's missing**: No "Auth callback token detected" message after this point
- This means: **Callback handler stored token, but monitoring code never saw it**

## The Problem Identified

**Root Cause**: The token IS captured by `AuthCallbackHandler`, but `AuthService._monitorCallbackToken()` doesn't detect it

**Architecture**:
```
User clicks email link
    ↓
HTTP request to localhost:3000/?token=764832&type=signup
    ↓
AuthCallbackHandler._handleRequest() receives it
    ↓
AuthCallbackHandler stores: _accessToken = "764832"
    ↓
AuthService._monitorCallbackToken() checks every 500ms:
    while hasToken && accessToken != null
    ↓
❌ PROBLEM: This check never returns true!
```

**Why might it fail**:
1. Singleton instance issue - monitoring code checking wrong instance
2. Async race condition - monitoring starts before handler initialized
3. Token cleared before monitoring detects it
4. Handler instance not accessible from monitoring

## Changes Made This Session

### 1. Enhanced "Check Your Email" Screen UI
**File**: `lib/screens/auth_wrapper.dart` (lines 72-198)
**Commit**: a72081b

Changes:
- Added large email icon with blue background
- Clear "Check Your Email" heading
- Display user's email in highlighted box
- Detailed instructions
- Loading spinner with status message
- Helpful spam folder tip
- Professional spacing and layout

### 2. Added Comprehensive Logging
**File**: `lib/services/auth_service.dart`
**Commit**: 14a0fee

Changes to `_monitorCallbackToken()`:
- Added: `⏱️ Starting email verification monitoring (30 second timeout)...`
- Added progress logging every 5 seconds: `⏳ Still waiting for email confirmation... (5 seconds elapsed)`
- Added: `❌ Email verification monitoring timed out after 30 seconds`
- Helpful checklist on timeout

Changes to `_handleCallbackToken()`:
- Detailed logging of token: `🔑 Attempting to verify email with token: 764832`
- Response details: Session? User? Token format?
- Better error handling: `❌ AuthException during email verification`
- Unexpected errors: `❌ Unexpected error handling callback token`

### 3. Setup Supabase MCP
**Status**: ✅ Already configured
**How**: `npx @anthropic-ai/claude-code mcp add supabase`
**Purpose**: Direct access to Supabase database and logs (needs OAuth auth after reboot)

## Current App Status

**Build**: Successfully compiled and running
```
√ Built build\windows\x64\runner\Debug\weblser_app.exe
🔐 Auth callback server started on localhost:3000
✅ AuthService initialized
```

**Ready for testing**: YES - All improvements are active

## How to Test After Reboot

### Step 1: Start App
```bash
cd C:\Users\Ntro\weblser\webaudit_pro_app
flutter run -d windows
```

Wait for:
```
🔐 Auth callback server started on localhost:3000
✅ AuthService initialized
```

### Step 2: Run Signup Flow
1. Click "Don't have an account? Sign Up"
2. Fill form:
   - Email: `test@example.com` (or your email)
   - Password: `ValidPass123`
   - Name: Your Name
   - Check "I agree to Terms..."
3. Click "Create Account"

### Step 3: WATCH Console for These Messages
```
After clicking "Create Account":
⏱️ Starting email verification monitoring (30 second timeout)...
```

If you DON'T see this message: **The monitoring never started**

### Step 4: Check Email & Click Link
- Check inbox for Supabase email
- Look for link starting with: `http://localhost:3000/?token=...`
- Click the link

### Step 5: Watch Console Again
```
Should see (in this order):
📨 EMAIL CONFIRMATION CALLBACK RECEIVED
✅ Auth token received from query: 764832
🎉 Auth callback token detected: 764832...
🔑 Attempting to verify email with token: 764832
✅ verifyOTP response received
   - Session: Yes
   - User: Yes (test@example.com)
✅ Email verified successfully!
```

OR if it fails:
```
❌ Email verification monitoring timed out after 30 seconds
⚠️ The callback server may not have received the confirmation link
💡 Check that:
   1. You clicked the confirmation link in the email
   2. The link starts with http://localhost:3000
   3. Your browser can reach localhost:3000
   4. The Flask callback server is still running
```

## Critical Console Output to Capture

When testing, **COPY AND SHARE**:

1. **From startup** (3-5 lines showing init):
   ```
   🔐 Auth callback server started on localhost:3000
   ✅ AuthService initialized
   ```

2. **After signup** (immediately):
   ```
   ⏱️ Starting email verification monitoring (30 second timeout)...
   ```

3. **After clicking email link** (everything from the callback onwards):
   ```
   📨 Received request...
   ✅ Auth token received from query...
   🎉 Auth callback token detected (or ❌ timeout message)
   ```

## Files Modified

```
lib/screens/auth_wrapper.dart          +119 lines (UI improvement)
lib/services/auth_service.dart         +32 lines (enhanced logging)
```

## Commits This Session

```
a72081b - feat: Enhance "Check your email" screen with improved UX
14a0fee - fix: Add comprehensive logging for email verification debugging
```

## Next Steps to Diagnose

### If monitoring doesn't start:
- Check that AuthService is initialized before monitoring
- Verify `_monitorCallbackToken()` is called in `initialize()`

### If token isn't detected:
- Check if AuthCallbackHandler singleton is same instance
- Verify token isn't being cleared prematurely
- Check if monitoring is checking the right handler instance

### If verifyOTP fails:
- Token might be expired (30 second window)
- Wrong OTP type (should be `OtpType.signup`)
- Supabase configuration issue

### With Supabase MCP (after reboot auth):
```
# Query to check email_confirmed_at field
SELECT id, email, email_confirmed_at FROM auth.users
WHERE email = 'test@example.com'

# Check if user profile was created
SELECT id, email FROM public.users
WHERE email = 'test@example.com'
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│ AuthWrapper (Shows "Check Your Email" screen)           │
└─────────────────────────────────────────────────────────┘
                            ↑
                            │
                    notifyListeners()
                            │
┌─────────────────────────────────────────────────────────┐
│ AuthService (Monitors for token)                        │
│  - _monitorCallbackToken() - Polls every 500ms          │
│  - _handleCallbackToken() - Calls verifyOTP()           │
│  - _handleAuthStateChange() - Checks email_verified     │
└─────────────────────────────────────────────────────────┘
                            ↑
                            │
                    token stored?
                            │
┌─────────────────────────────────────────────────────────┐
│ AuthCallbackHandler (HTTP server on :3000)              │
│  - Starts on app init                                   │
│  - Receives email confirmation link                     │
│  - Parses token from query parameters                   │
│  - Stores in _accessToken                               │
└─────────────────────────────────────────────────────────┘
```

## Known Working Parts

✅ Supabase initialization
✅ Email/password signup
✅ Supabase sends confirmation email
✅ Email contains correct link: `http://localhost:3000/?token=XXXXXX`
✅ Browser can reach localhost:3000
✅ Callback handler receives HTTP request
✅ Token is parsed and stored

## Known Failing Parts

❌ Monitoring detects token (likely issue here)
❌ verifyOTP is called (depends on monitoring)
❌ Email is marked verified (depends on verifyOTP)
❌ Auto-login occurs (depends on verification)

## Environment Info

- **Platform**: Windows
- **Flutter**: Latest
- **Supabase Project**: websler-pro
- **Supabase URL**: https://vwnbhsmfpxdfcvqnzddc.supabase.co
- **Auth**: Email/password with OTP verification
- **Callback Server**: Shelf (Dart HTTP server)
- **Port**: localhost:3000

## Session Goals

### Completed ✅
- Enhanced "Check your email" UI for clarity
- Added comprehensive logging throughout verification flow
- Identified gap: monitoring not detecting token
- Setup Supabase MCP for future debugging

### In Progress 🔄
- Diagnose why monitoring doesn't detect token
- Determine if it's instance/singleton issue or race condition
- Fix the detection mechanism

### Next 🔮
- Use improved logging output to identify exact failure point
- Fix the issue once identified
- Test complete flow end-to-end
- Document the solution for reference

## Quick Reference

**How to kill all Flutter processes:**
```bash
powershell -Command "Get-Process weblser_app -ErrorAction SilentlyContinue | Stop-Process -Force"
```

**How to clean and rebuild:**
```bash
flutter clean
flutter pub get
flutter run -d windows
```

**How to restart fresh:**
1. Close app or press `q`
2. Remove lock file: `rm -f "C:\Users\Ntro\Documents\auth\supabase_authentication.lock"`
3. Rebuild: `flutter run -d windows`

---

**Last Updated**: Oct 25, 2025 - 00:11 AM (when app was built and running)
**Session Duration**: ~90 minutes
**Status**: App running, ready for testing with improved debugging
