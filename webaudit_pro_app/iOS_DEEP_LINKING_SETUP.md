# iOS Deep Linking Setup - Production Configuration

**Date**: October 26, 2025
**Status**: ✅ Files Created | ⏳ Deployment Pending
**Purpose**: Enable email verification for iOS via Universal Links (websler.app)

---

## Configuration Details

### Bundle ID & Team Info
- **Bundle ID**: `io.jumoki.weblser`
- **Team ID**: `38BQCMMR5C`
- **Team Name**: Jumoki Agency LLC
- **Domain**: `websler.app`

---

## Files Created

### 1. Apple App Site Association File ✅
**Location**: `C:\Users\Ntro\weblser\apple-app-site-association`

**Content**:
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "38BQCMMR5C.io.jumoki.weblser",
        "paths": [
          "/verify",
          "/verify?*",
          "/auth/callback",
          "/auth/callback?*"
        ]
      }
    ]
  },
  "webcredentials": {
    "apps": [
      "38BQCMMR5C.io.jumoki.weblser"
    ]
  }
}
```

**Purpose**: Tells iOS that websler.app domain is associated with the app
**Deployment**: Must be at `https://websler.app/.well-known/apple-app-site-association`

### 2. iOS Info.plist Updated ✅
**Location**: `ios/Runner/Info.plist`

**Changes Made**:
- Added `NSLocalNetworkUsageDescription` for localhost callback server
- Added `NSBonjourServices` for mDNS support
- These enable the app to listen for callbacks on `localhost:3000` on desktop

**Current Configuration** (already in file):
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>This app uses local network access for email verification callbacks</string>
<key>NSBonjourServices</key>
<array>
    <string>_http._tcp</string>
</array>
```

---

## How iOS Deep Linking Will Work

### Email Verification Flow
```
1. User on iPhone receives verification email from noreply@websler.app
2. Email contains link: https://websler.app/verify?token=ABC123
3. User taps link
4. iOS checks apple-app-site-association on websler.app
5. iOS recognizes app is associated with domain
6. iOS opens app directly (not browser)
7. Flutter app receives deep link with token
8. App verifies token with Supabase
9. User auto-logs in
10. Home screen displays
```

---

## Files to Deploy to Hostinger

### Must Deploy Before Testing
1. **apple-app-site-association**
   - Location: `/public_html/.well-known/apple-app-site-association`
   - Must be publicly accessible at: `https://websler.app/.well-known/apple-app-site-association`
   - No file extension
   - Must be valid JSON

### Optional - Landing Page
1. **index.html** (one-page site)
   - Location: `/public_html/index.html`
   - Will be created separately

---

## Next Steps - Deployment

### Step 1: Create .well-known Directory
```bash
# On Hostinger via FTP or File Manager
Create directory: public_html/.well-known/
```

### Step 2: Upload apple-app-site-association
```
Upload file: apple-app-site-association (NO EXTENSION)
To: public_html/.well-known/
```

### Step 3: Verify Accessibility
```bash
# Test via browser
curl https://websler.app/.well-known/apple-app-site-association

# Should return valid JSON
```

### Step 4: Update Supabase
In Supabase Auth → URL Configuration:
- Add Redirect URL: `https://websler.app/verify`
- Keep existing `http://localhost:3000` for Windows testing

---

## Flutter Deep Linking Handler

### Current Status
- ✅ `lib/services/auth_callback_handler.dart` - Handles localhost:3000
- 🔄 Needs update to handle deep links: `https://websler.app/verify?token=xxx`

### Required Updates
1. Modify callback handler to accept both:
   - `http://localhost:3000?token=xxx` (Windows desktop)
   - `https://websler.app/verify?token=xxx` (iOS)

2. Add deep link initialization in `main.dart`:
   ```dart
   // Initialize deep links
   _initDeepLinks();
   ```

3. Handler should:
   - Extract token from query parameter
   - Call `verifyOTP(token)`
   - Auto-login user
   - Route to home screen

---

## Testing Checklist

### Before Testing
- [ ] Deploy apple-app-site-association to Hostinger
- [ ] Verify file is accessible at https://websler.app/.well-known/apple-app-site-association
- [ ] Update Supabase redirect URLs
- [ ] Update Flutter app with deep link handler
- [ ] Build new TestFlight version

### Testing on iOS
- [ ] Sign up for new account in TestFlight build
- [ ] Wait for verification email (should arrive from noreply@websler.app)
- [ ] Tap link in email
- [ ] Verify app opens automatically (not browser)
- [ ] Verify user auto-logs in
- [ ] Verify home screen displays

### Fallback (If Deep Link Fails)
- [ ] Email link still works in browser
- [ ] Manual token entry (backup if needed)

---

## Important Notes

### Apple App Site Association Requirements
1. ✅ Valid JSON format (tested)
2. ✅ Correct appID format: `TEAMID.BUNDLEID`
3. ✅ HTTPS only (http:// NOT supported)
4. ✅ Must be at `.well-known/apple-app-site-association`
5. ✅ No file extension
6. ✅ Must be publicly accessible
7. ⚠️ Apple caches this file for 24 hours after first access

### Why Both localhost:3000 and https://websler.app
- **localhost:3000**: Desktop users (Windows, macOS, Linux)
  - App runs local HTTP server
  - Callback server is on user's machine
  - No internet connectivity required

- **https://websler.app**: Mobile users (iPhone, iPad, Android)
  - No local server
  - Uses universal/app links
  - Requires internet connectivity

---

## Supabase Configuration (Pending)

### Current Setting
```
Site URL: http://localhost:3000
Redirect URLs:
  - http://localhost:3000
  - http://localhost:3000/
  - http://localhost:3000/auth/callback
```

### Need to Update To
```
Site URL: https://websler.app
Redirect URLs:
  - http://localhost:3000 (KEEP for Windows)
  - http://localhost:3000/
  - http://localhost:3000/auth/callback
  - https://websler.app (NEW for iOS)
  - https://websler.app/verify (NEW for iOS)
```

---

## Git Status
- **New File**: `apple-app-site-association` (root)
- **Modified**: `ios/Runner/Info.plist`
- **Ready to Commit**: Yes, once tested

---

## Timeline

- ✅ Created: apple-app-site-association
- ✅ Updated: Info.plist with network permissions
- 🔄 Pending: Deploy to Hostinger
- 🔄 Pending: Update Flutter deep link handler
- 🔄 Pending: Update Supabase redirect URLs
- 🔄 Pending: Test on iOS via TestFlight

**Estimated Completion**: 2-3 hours (including deployment and testing)

---

## Troubleshooting

### Deep Link Not Opening App
- **Check 1**: Verify apple-app-site-association is accessible
  - Go to: https://websler.app/.well-known/apple-app-site-association
  - Should return JSON (not 404 or HTML error)

- **Check 2**: Verify file format
  - Must be valid JSON
  - No extra spaces or formatting issues
  - Use JSON validator: https://jsonlint.com/

- **Check 3**: App bundle ID matches
  - File: `38BQCMMR5C.io.jumoki.weblser`
  - Must match exactly: `TEAMID.BUNDLEID`

- **Check 4**: Rebuild app
  - Apple caches for 24 hours
  - After uploading file, rebuild iOS app in Codemagic
  - Fresh build will re-validate association

### Email Not Opening Deep Link
- **Check 1**: Verify email template includes link
  - Supabase should send: `https://websler.app/verify?token=xxx`
  - Not: `http://localhost:3000?token=xxx`

- **Check 2**: Verify Supabase redirect URLs
  - Must include `https://websler.app/verify`

- **Check 3**: Test with different email
  - Send test email from Supabase admin panel
  - Verify link format in email source

---

## Success Indicators

✅ **You'll know it's working when:**
1. Email arrives from noreply@websler.app
2. Link format in email is: `https://websler.app/verify?token=...`
3. Tapping link opens app directly (not browser)
4. App shows "Verifying email..." then auto-logs in
5. Home screen displays with user's email
6. Can log out and re-login normally

---

**Next Action**: Deploy apple-app-site-association to Hostinger and update Supabase configuration.
