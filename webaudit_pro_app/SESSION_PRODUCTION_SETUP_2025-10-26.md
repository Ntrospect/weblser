# Production Setup Session - October 26, 2025

## Session Overview
**Objective**: Set up websler.app for production with email verification, supporting both Windows desktop and iOS (Apple-only business partner).

**Status**: ✅ SMTP Configured | 🔄 iOS Deep Linking Setup in Progress

---

## Completed Tasks ✅

### 1. Domain Registration
- ✅ **Domain**: websler.app registered
- ✅ **Email Account**: noreply@websler.app created on Hostinger
- ✅ **Hosting**: Hostinger (landing page to be deployed)

### 2. Hostinger Email Configuration
**SMTP Credentials Obtained**:
```
Host: smtp.hostinger.com
Port: 465
Encryption: SSL
Username: noreply@websler.app
Password: @Burrawang1968! (saved securely in Supabase)
```

### 3. Supabase Custom SMTP Setup ✅
**Configured in Supabase Auth → Email → Custom SMTP**:
- ✅ **Sender email**: noreply@websler.app
- ✅ **Sender name**: Websler Pro
- ✅ **Host**: smtp.hostinger.com
- ✅ **Port**: 465
- ✅ **Username**: noreply@websler.app
- ✅ **Password**: [ENCRYPTED in Supabase]
- ✅ **Toggle**: Enable Custom SMTP = ON

### 4. Supabase URL Configuration Verified ✅
**Current Configuration** (Perfect for desktop):
```
Site URL: http://localhost:3000
Redirect URLs:
  - http://localhost:3000
  - http://localhost:3000/
  - http://localhost:3000/auth/callback
```

### 5. Strategic Decision: Option B - Full Production ✅
**Rationale**: Business partner uses Apple devices ONLY (no Windows)
- ✅ Decided to implement iOS deep linking from day 1
- ✅ Supports both Windows desktop AND iOS/Android production
- ✅ No need to refactor later

---

## Current Architecture

### Email Verification Flow (Production)
```
User on iPhone receives verification email
    ↓
Email from: noreply@websler.app (via Hostinger SMTP)
    ↓
User clicks link: https://websler.app/verify?token=xxx
    ↓
iOS Universal Link triggers app open
    ↓
App processes deep link
    ↓
Token captured and user auto-logs in
    ↓
Home screen displays
```

### Supporting Windows Desktop
```
User on Windows receives verification email
    ↓
User clicks link: http://localhost:3000?token=xxx
    ↓
Callback server (localhost:3000) captures token
    ↓
App processes token and auto-logs in
    ↓
Home screen displays
```

---

## iOS Deep Linking Setup - IN PROGRESS ✅

### Configuration Data (OBTAINED)
1. ✅ **iOS Bundle ID**: `io.jumoki.weblser`
2. ✅ **Apple Team ID**: `38BQCMMR5C`
3. ✅ **Team Name**: Jumoki Agency LLC
4. ✅ **Domain**: `websler.app`

### Tasks Completed ✅

#### Phase 1: iOS Configuration - DONE ✅
- ✅ Created `apple-app-site-association` JSON file
  - Maps websler.app domain to iOS app
  - Specifies Team ID: `38BQCMMR5C`
  - Specifies Bundle ID: `io.jumoki.weblser`
  - File location: `C:\Users\Ntro\weblser\apple-app-site-association`

- ⏳ Deploy to Hostinger (NEXT STEP)
  - Location: `https://websler.app/.well-known/apple-app-site-association`
  - Must be publicly accessible

#### Phase 2: Flutter App Updates - IN PROGRESS 🔄
- ✅ Updated `ios/Runner/Info.plist`
  - Added `NSLocalNetworkUsageDescription` for localhost callback
  - Added `NSBonjourServices` for mDNS support

- 🔄 Update deep link handler in `lib/services/auth_callback_handler.dart`
  - Needs to handle `https://websler.app/verify?token=xxx` links
  - Also supports existing `http://localhost:3000?token=xxx` for Windows
  - Single handler for both flows

#### Phase 3: Supabase Configuration - BLOCKED 🔒
- ⏳ Update Site URL: Keep at `http://localhost:3000` for now
  - Can use multi-domain support: localhost + websler.app
- ⏳ Add Redirect URLs:
  - `https://websler.app/verify` (NEW for iOS)
  - Keep `http://localhost:3000` for Windows testing
  - Keep `http://localhost:3000/` and `/auth/callback` variants

#### Phase 4: Landing Page
- [ ] Create HTML5 one-pager for websler.app
  - Hero section with CTA
  - Features list
  - How it works timeline
  - Download links (Windows installer, TestFlight)
  - Footer with contact info

- [ ] Deploy to Hostinger web hosting

#### Phase 5: Testing
- [ ] Test email verification on Windows (localhost:3000)
- [ ] Test email verification on iOS (TestFlight)
- [ ] Verify deep linking works
- [ ] Verify auto-login flow

---

## Key Configuration Files

### Existing Files (Already Configured)
- ✅ `lib/services/auth_callback_handler.dart` - HTTP server for callbacks
- ✅ `lib/services/auth_service.dart` - Auth orchestration with monitoring
- ✅ `lib/screens/auth_wrapper.dart` - "Check your email" UI
- ✅ Email verification system fully implemented

### Files to Create/Update
- [ ] `ios/Runner/Info.plist` - Add Associated Domains
- [ ] `apple-app-site-association` - Deploy to Hostinger
- [ ] `lib/services/deep_link_handler.dart` - Handle deep links (NEW)
- [ ] Landing page HTML - Deploy to Hostinger

---

## Important Notes

### SMTP Testing
- Email reputation on Hostinger is currently **POOR** (new domain)
- This is normal for new domains
- Will improve as emails are sent successfully
- Optional: Add DKIM records to improve deliverability
  - Hostinger shows how in Email Reputation section
  - Recommended but not blocking

### Callback Handler
- Currently listens on `localhost:3000`
- **Will NOT change** for Windows (works perfectly as-is)
- Will ADD support for deep links (`websler://` scheme)
- Both methods will coexist

### App Distribution
- **Windows**: Use existing installer (works with localhost:3000)
- **iOS**: Use TestFlight (will use https://websler.app deep links)
- **Android**: Can be added later with similar deep linking setup

---

## Session Summary

### What Changed
- ✅ Domain registered: websler.app
- ✅ Email configured: noreply@websler.app on Hostinger
- ✅ SMTP enabled in Supabase
- ✅ Strategic decision: Full production setup for iOS + Windows

### What's Ready
- ✅ Email verification system (code)
- ✅ SMTP configured and tested
- ✅ Supabase auth setup
- ✅ Windows desktop callback handler

### What's Blocked (Waiting)
- 🔄 iOS Bundle ID (needed from Xcode)
- 🔄 Apple Team ID (needed from Apple Developer)
- 🔄 Deep linking setup (blocked by above)
- 🔄 Landing page creation (blocked by deep link completion)

---

## Business Context

### Stakeholder: Apple-Only Partner
- **Device**: iPhone only (no Windows)
- **Distribution**: TestFlight for testing
- **Need**: Email verification must work on iOS
- **Timeline**: Showing progress regularly

### This Session's Impact
- ✅ SMTP ready for iPhone users
- ✅ Email will be sent from professional domain
- ✅ Strategy set for production
- 🔄 Ready for iOS implementation (waiting on Bundle ID)

---

## Git Status
- **Current Branch**: main
- **Recent Commits**: Dark theme fixes, email verification improvements
- **Ready to Commit**: Will commit iOS configuration once implemented

---

## Recommendations for Next Session

1. **Obtain iOS Bundle ID & Team ID** from Xcode
   - Unblock all iOS deep linking setup
   - 5-minute task

2. **Implement iOS Deep Linking**
   - Create apple-app-site-association
   - Update Info.plist
   - Add deep link handler
   - Estimated: 45 minutes

3. **Create Landing Page**
   - HTML5 one-pager
   - Deploy to Hostinger
   - Estimated: 30 minutes

4. **Update Supabase URLs**
   - Change Site URL to https://websler.app
   - Add all redirect URLs
   - Estimated: 10 minutes

5. **End-to-End Testing**
   - Windows email verification test
   - iOS email verification test
   - Estimated: 15 minutes

**Total Estimated Time**: ~2 hours to full production

---

## Files & Credentials Reference

### Hostinger
- **Account**: Active
- **Domain**: websler.app
- **Email**: noreply@websler.app
- **SMTP Host**: smtp.hostinger.com:465

### Supabase
- **Project**: websler-pro
- **URL**: https://vwnbhsmfpxdfcvqnzddc.supabase.co
- **SMTP**: Configured with Hostinger credentials

### App
- **Current version**: 1.2.1
- **TestFlight**: Build 1.2.1 submitted (awaiting Apple review)
- **Windows**: Ready for testing

---

**Session Date**: October 26, 2025
**Duration**: ~1 hour
**Status**: ✅ SMTP Complete | 🔄 iOS Setup Blocked (Awaiting Bundle ID)
**Next Action**: Obtain iOS Bundle ID and Apple Team ID
