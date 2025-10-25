# Quick Reference - Email Verification Debugging

## Problem Statement
**Check Your Email screen hangs instead of auto-logging in after email confirmation**

After user clicks the confirmation link in their email:
- ✅ Email link works (localhost:3000 receives request)
- ✅ Token is parsed (`764832`)
- ❌ **Monitoring code doesn't detect it - screen hangs for 30 seconds**
- ❌ No auto-login occurs

## Recent Commits

| Commit | Message | Files |
|--------|---------|-------|
| 3ecd60f | docs: Add comprehensive debug session log | SESSION_DEBUG_EMAIL_VERIFICATION.md |
| 14a0fee | fix: Add comprehensive logging for debugging | auth_service.dart |
| a72081b | feat: Enhance "Check your email" screen UI | auth_wrapper.dart |

## Key Files for This Issue

```
lib/services/auth_service.dart
└── _monitorCallbackToken()          ← Polls for token every 500ms
├── _handleCallbackToken()           ← Should call verifyOTP()
└── _handleAuthStateChange()         ← Checks email_verified status

lib/services/auth_callback_handler.dart
└── _handleRequest()                 ← Receives HTTP request, stores token

lib/screens/auth_wrapper.dart
└── Build() if authenticating        ← Shows "Check Your Email" screen
```

## Console Log - What to Watch For

### ✅ Good Startup
```
🔐 Auth callback server started on localhost:3000
✅ AuthService initialized
```

### ✅ Good Signup
```
✅ Sign up successful: email@example.com
📧 Confirmation email sent
! Email verification required
📧 Waiting for user to click confirmation link...
⏱️ Starting email verification monitoring (30 second timeout)...
```

### ✅ Good Callback Reception
```
📨 Received request: ?token=764832&type=signup
📨 Full URL: http://localhost:3000/?token=764832&type=signup
📨 Parsing query parameters...
✅ Auth token received from query: 764832 (length: 6)
```

### ❌ Current Problem (hangs here)
```
[Nothing happens here - monitoring should detect token]
[Screen hangs for 30 seconds]
[Times out with: ❌ Email verification monitoring timed out]
```

### ✅ What SHOULD happen (currently doesn't)
```
🎉 Auth callback token detected: 764832...
🔑 Attempting to verify email with token: 764832
📍 Calling verifyOTP with type=OtpType.signup...
✅ verifyOTP response received
   - Session: Yes
   - User: Yes (email@example.com)
✅ Email verified successfully!
```

## Suspected Root Cause

**AuthCallbackHandler stores token, but AuthService monitoring doesn't see it**

Possibilities:
1. Different singleton instances
2. Async race condition
3. Token cleared before monitoring detects
4. Monitoring checking wrong handler instance

## Testing Checklist

```bash
# After reboot:

1. [ ] Start app: flutter run -d windows
2. [ ] See: 🔐 Auth callback server started
3. [ ] Click "Sign Up"
4. [ ] Fill form and click "Create Account"
5. [ ] See: ⏱️ Starting email verification monitoring
6. [ ] Check email inbox
7. [ ] Click confirmation link
8. [ ] Watch console for token detection
9. [ ] Copy FULL console output (critical for diagnosis)
10. [ ] Check if screen auto-logs in or hangs
```

## Debug Commands

```bash
# Kill locked processes
powershell -Command "Get-Process weblser_app -ErrorAction SilentlyContinue | Stop-Process -Force"

# Remove lock file
rm -f "C:\Users\Ntro\Documents\auth\supabase_authentication.lock"

# Clean rebuild
flutter clean && flutter pub get && flutter run -d windows

# Git status
git status
git log --oneline -10
```

## Supabase MCP Commands (After Auth)

```bash
# List available resources
claude.ai/code mcp resources supabase

# Check user email verification status
SELECT id, email, email_confirmed_at FROM auth.users
WHERE email = 'test@example.com'

# Check if user profile created
SELECT id, email FROM public.users
WHERE email = 'test@example.com'
```

## Session Notes

- **Build**: Successfully compiles, app runs, callback server active
- **Missing**: Token detection in monitoring loop
- **Logging**: Comprehensive logging added to find exact failure point
- **MCP**: Supabase MCP ready to query database directly (needs OAuth)

## Next Actions

1. Test signup flow and capture console output
2. Identify exact point where process fails using logs
3. Fix root cause (likely singleton/instance issue)
4. Verify complete flow works end-to-end
5. Test on iOS/macOS/Android via TestFlight

## Contact Points

- **Full Debug Log**: `SESSION_DEBUG_EMAIL_VERIFICATION.md`
- **Email Verification Guide**: `EMAIL_VERIFICATION_GUIDE.md`
- **Code Changes This Session**: Commits a72081b, 14a0fee, 3ecd60f

## Status Summary

```
Authentication:     ✅ Works (signup succeeds)
Email Sending:      ✅ Works (emails arrive)
Callback Server:    ✅ Works (receives requests)
Token Parsing:      ✅ Works (extracts 764832)
Token Detection:    ❌ BROKEN (monitoring doesn't see it)
OTP Verification:   ⏸️ Untested (blocked by detection)
Auto-Login:         ⏸️ Untested (blocked by verification)
```

---

**For complete context**: Read `SESSION_DEBUG_EMAIL_VERIFICATION.md`
