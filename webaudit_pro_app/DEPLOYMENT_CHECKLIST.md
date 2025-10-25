# Production Deployment Checklist

**Status**: Phase 2 - iOS Deep Linking Configuration
**Date**: October 26, 2025
**Target Users**: Windows Desktop + iPhone (Apple-only business partner)

---

## ✅ COMPLETED - SMTP & Email Setup

### Hostinger Configuration
- ✅ Domain registered: `websler.app`
- ✅ Email account created: `noreply@websler.app`
- ✅ SMTP credentials obtained:
  - Host: `smtp.hostinger.com`
  - Port: `465` (SSL)
  - Username: `noreply@websler.app`

### Supabase Configuration
- ✅ Custom SMTP enabled with Hostinger credentials
- ✅ Sender name: "Websler Pro"
- ✅ Ready to send production emails

### Result
Email verification emails will now come from professional domain: `noreply@websler.app`

---

## ✅ COMPLETED - iOS Deep Linking Files

### Files Created
1. ✅ **apple-app-site-association** (JSON file)
   - Location: `C:\Users\Ntro\weblser\apple-app-site-association`
   - Status: Ready for deployment
   - Content: Valid JSON with Team ID and Bundle ID

2. ✅ **ios/Runner/Info.plist** (Updated)
   - Added network permissions for localhost callback
   - Added NSBonjourServices for mDNS support

### Configuration Data Stored
- Bundle ID: `io.jumoki.weblser`
- Team ID: `38BQCMMR5C`
- Team Name: Jumoki Agency LLC

---

## 🔄 IN PROGRESS - Hostinger Deployment

### NEXT: Deploy apple-app-site-association

**Step 1: Connect to Hostinger**
- Log into Hostinger control panel
- Open File Manager or FTP

**Step 2: Create Directory**
```
Create: /public_html/.well-known/
```

**Step 3: Upload File**
```
File: apple-app-site-association (no extension)
Destination: /public_html/.well-known/apple-app-site-association
```

**Step 4: Verify**
- Visit: https://websler.app/.well-known/apple-app-site-association
- Should show JSON content (not 404 or error)

**Importance**: CRITICAL - Email deep linking won't work without this file

---

## ⏳ PENDING - Flutter App Updates

### Update Deep Link Handler
**File**: `lib/services/auth_callback_handler.dart`

**Current**: Handles only `localhost:3000?token=xxx`
**Needed**: Also handle `https://websler.app/verify?token=xxx`

**Change Required**:
- Detect if request is from localhost or websler.app
- Extract token from either URL pattern
- Same verification flow for both

**Estimated Time**: 15 minutes

---

## ⏳ PENDING - Supabase URL Configuration

### Update Redirect URLs
**Location**: Supabase Auth → URL Configuration

**Add These**:
- `https://websler.app`
- `https://websler.app/verify`

**Keep Existing** (for Windows desktop):
- `http://localhost:3000`
- `http://localhost:3000/`
- `http://localhost:3000/auth/callback`

**Estimated Time**: 5 minutes

---

## ⏳ PENDING - Landing Page

### Create HTML5 One-Pager
**Location**: Create `index.html` for deployment to Hostinger

**Sections Needed**:
1. Hero Section
   - Websler logo
   - Tagline: "AI-Powered Website Analyzer"
   - CTA: "Download Now"

2. Features
   - 10-Point Web Audit
   - Instant AI Summary
   - Professional Reports

3. How It Works
   - Enter Website URL
   - Get AI Analysis
   - View Detailed Audit

4. Download Section
   - Windows Installer
   - TestFlight Link
   - Coming: macOS, Android

5. Footer
   - Contact: info@websler.app
   - Links: Privacy, Terms
   - Copyright: © 2025 Jumoki Agency

**Estimated Time**: 1 hour to create + test

---

## ⏳ PENDING - Testing

### Windows Desktop Testing
1. Run app: `flutter run -d windows`
2. Sign up with test email
3. Verify email arrives from `noreply@websler.app`
4. Click link: Should go to `localhost:3000`
5. Verify auto-login works

**Timeline**: 10 minutes

### iOS TestFlight Testing
1. Build new version in Codemagic
2. Submit to TestFlight
3. Install on iPhone
4. Sign up with test email
5. Verify email arrives from `noreply@websler.app`
6. Click link: Should open app directly (not browser)
7. Verify auto-login works

**Timeline**: 30 minutes (once Codemagic build is done)

---

## Git Commits

### Ready to Commit
```
- apple-app-site-association (new file)
- ios/Runner/Info.plist (updated)
- iOS_DEEP_LINKING_SETUP.md (documentation)
- SESSION_PRODUCTION_SETUP_2025-10-26.md (session notes)
- DEPLOYMENT_CHECKLIST.md (this file)
```

**Suggested commit message**:
```
feat: Set up iOS deep linking for production email verification
- Create apple-app-site-association for websler.app domain
- Update iOS Info.plist with network permissions
- Configure Team ID (38BQCMMR5C) and Bundle ID (io.jumoki.weblser)
- Add comprehensive deployment guide
```

---

## Critical Path - What Must Happen First

### BLOCKING ITEMS (Can't test iOS without these):
1. ✅ SMTP configured (DONE)
2. ⏳ Deploy apple-app-site-association to Hostinger (NEXT)
3. ⏳ Update Flutter deep link handler (DEPENDS on #2)
4. ⏳ Update Supabase redirect URLs (DEPENDS on #2)
5. ⏳ Build & test on TestFlight (DEPENDS on #3, #4)

### OPTIONAL (Can do anytime):
- Landing page (web presence, not critical for app functionality)
- DKIM records (email deliverability, optional)

---

## Timeline Estimate

| Task | Est. Time | Status |
|------|-----------|--------|
| Deploy AASA file | 5 min | 🔄 Next |
| Update Flutter handler | 15 min | ⏳ Pending |
| Update Supabase URLs | 5 min | ⏳ Pending |
| Build Codemagic version | 10 min | ⏳ Pending |
| Windows desktop test | 10 min | ⏳ Pending |
| iOS TestFlight test | 20 min | ⏳ Pending |
| **Create landing page** | 60 min | ⏳ Optional |
| **Deploy landing page** | 10 min | ⏳ Optional |
| **Total (Core)** | **75 min** | 🟡 In Progress |
| **Total (With Landing)** | **145 min** | 🟡 In Progress |

---

## Success Criteria

### Email Verification Works
- [ ] Email arrives from `noreply@websler.app` (not Supabase domain)
- [ ] Windows desktop: Click email link → localhost:3000 → Auto-login
- [ ] iOS app: Click email link → Opens app directly → Auto-login

### Deep Linking Works
- [ ] iOS doesn't open browser on email click
- [ ] iOS opens Websler app directly
- [ ] Token captured correctly
- [ ] User auto-logged in

### Landing Page Live
- [ ] https://websler.app/ shows professional one-pager
- [ ] Download links work correctly
- [ ] Contact info accurate

---

## Important Notes

### Email Reputation
- Hostinger shows "poor" reputation (normal for new domain)
- Will improve as emails are sent successfully
- No action needed - automatic improvement

### AASA File Caching
- Apple caches this file for ~24 hours
- After uploading, may need to rebuild app
- Changes take effect after fresh app build

### Windows vs iOS Paths
- **Windows**: `http://localhost:3000` (local server on user's machine)
- **iOS**: `https://websler.app` (hosted on internet)
- Both work simultaneously - different users, different paths

---

## Questions to Answer Before Moving Forward

1. **Landing Page**: Want to create now or later?
   - Now: Faster to show to business partner
   - Later: Focus on email verification first

2. **Email Reputation**: Want to add DKIM records to improve?
   - Hostinger: Has guide in Email Reputation section
   - Optional but recommended for professional setup

3. **Android Support**: Plan to support Android?
   - Future: Can add later with same deep linking approach
   - Now: Not needed if only Windows + iOS

---

**Status**: Ready for Hostinger deployment
**Next Action**: Deploy apple-app-site-association file
**Timeline to Working Email Verification**: ~2 hours (including testing)
