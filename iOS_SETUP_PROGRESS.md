# iOS Build Setup Progress - Session Oct 21, 2025

## Current Status: 95% Complete - Waiting for Certificate Private Key

**Critical Blocker:** Need to export iOS certificate private key from old Mac to complete Codemagic setup.

---

## What We've Accomplished ✅

### Git & Repository
- ✅ Committed entire `weblser_app` Flutter project to GitHub (225 files)
- ✅ All iOS files now in repo: `weblser_app/ios/Runner.xcworkspace`, Podfile, ExportOptions.plist
- ✅ Repository ready for CI/CD

### Codemagic Configuration
- ✅ Created `codemagic.yaml` with iOS workflow
- ✅ Fixed instance type: `mac_mini_m2` (current standard)
- ✅ Working directory set at workflow level (Codemagic requirement)
- ✅ Added group reference: `ios-signing` for environment variables
- ✅ Flutter version: 3.35.6 (matches Dart SDK in codemagic.yaml)

### Environment Variables (Created in Codemagic Settings)
All with `ios-signing` group:
- ✅ `ISSUER_ID` = `4471b033-2905-43eb-934d-e736935b4470`
- ✅ `KEY_ID` = `3RVVTQ2JM7`
- ✅ `AUTH_KEY` = (private key from AuthKey_3RVVTQ2JM7.p8)

### Flutter App Configuration
- ✅ Version: 1.2.1+1 (bumped to avoid TestFlight bundle conflicts)
- ✅ SDK requirement: ^3.5.0 (relaxed from ^3.9.2)
- ✅ Bundle ID: `io.jumoki.weblser`
- ✅ Team ID: `PKB9P8F266` (hardcoded in codemagic.yaml)

### Code Signing Setup
- ✅ Automatic code signing enabled: `CODE_SIGN_STYLE="Automatic"`
- ✅ xcodebuild configured for App Store distribution
- ✅ iOS deployment target: 12.0

---

## Current Build Process (in codemagic.yaml)

1. Debug environment info
2. Get Flutter packages (`flutter pub get`)
3. Clean Flutter build cache (`flutter clean`)
4. **Fetch iOS code signing files** ← Currently failing here
5. Build iOS app (`flutter build ios --release --no-codesign`)
6. Build and archive with xcodebuild
7. Export IPA
8. Auto-submit to TestFlight

---

## The Problem: Step 4 Failing

**Error:** "Cannot save Signing Certificates without certificate private key"

**Why:** The certificate was created via Apple API key, and the private key was never exported to be available locally.

**Solution:** Export the private key from the old Mac's Keychain.

---

## Next Steps (5 minutes on old Mac)

### On the Old Mac:
1. Power on and connect to Wi-Fi
2. Open **Keychain Access** (Applications → Utilities)
3. Search for `iOS` or `Apple` certificates
4. If found: Right-click → Export as `.p12` file (no password needed)
5. Transfer `ios-certificate.p12` to Windows machine

### On Windows (back in Claude Code):
1. Add certificate private key to Codemagic as `CERT_KEY` variable
2. Trigger build
3. App will auto-submit to TestFlight

---

## Files & Locations

### GitHub Repo
- Repository: https://github.com/Ntrospect/weblser
- Main branch - all recent commits pushed

### Key Config Files
- `codemagic.yaml` - CI/CD pipeline (root directory)
- `weblser_app/pubspec.yaml` - Flutter app config
- `weblser_app/ios/Podfile` - CocoaPods configuration
- `weblser_app/ios/ExportOptions.plist` - IPA export settings
- `weblser_app/ios/Runner.xcworkspace` - Xcode workspace

### Apple Developer Credentials
- Location: `C:\Users\Ntro\weblser\Apple Developer files\`
- AuthKey file: `AuthKey_3RVVTQ2JM7.p8` (already in Codemagic as AUTH_KEY)
- Issuer ID: `4471b033-2905-43eb-934d-e736935b4470`
- Key ID: `3RVVTQ2JM7`
- Team ID: `PKB9P8F266`

### Xcode Workspace
- Path: `weblser_app/ios/Runner.xcworkspace`
- Scheme: `Runner`
- Bundle ID: `io.jumoki.weblser`

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| "cd: weblser_app/ios: No such file" | ✅ Fixed - committed weblser_app to GitHub |
| "mac_pro not supported" | ✅ Fixed - changed to mac_mini_m2 |
| "working_directory at script level" | ✅ Fixed - moved to workflow level |
| "No suitable provisioning profile" | ✅ Fixed - using automatic signing |
| "bundle version must be higher" | ✅ Fixed - bumped to 1.2.1+1 |
| "Cannot save Signing Certificates..." | ⏳ In progress - need certificate private key |

---

## What Happens After We Get the Certificate Key

Once private key is added as `CERT_KEY` variable:

1. Click **"Start new build"** in Codemagic
2. Select **ios-workflow**
3. Codemagic will:
   - Authenticate with Apple Developer Portal
   - Fetch/create provisioning profiles
   - Build the iOS app
   - Create the IPA file
   - **Auto-submit to TestFlight** (no manual upload needed!)
4. App appears in TestFlight for testing on iPad Pro

---

## Troubleshooting Checklist

- [ ] All 3 environment variables created in Codemagic with `ios-signing` group
- [ ] GitHub has all `weblser_app` files committed
- [ ] Team ID is `PKB9P8F266` in codemagic.yaml
- [ ] iOS deployment target is 12.0 minimum
- [ ] Bundle ID matches: `io.jumoki.weblser`
- [ ] xcodebuild has `CODE_SIGN_STYLE="Automatic"`

---

## Time Estimate

- Getting certificate from old Mac: ~10 minutes
- Adding to Codemagic: ~2 minutes
- Final build: ~5-10 minutes
- **Total to TestFlight: ~20 minutes**

---

## Questions for Next Session

If build still fails:
1. Check exact error message in Codemagic build logs
2. Verify certificate file format (should be `.p12` binary file)
3. Check if certificate is actually in old Mac's Keychain
4. Consider creating new certificate on Apple portal if old one can't be found

---

**Created:** Oct 21, 2025, ~2:45 PM UTC
**Frustration Level:** High (14 hours vs. 5 minutes for Windows installer) 😤
**Morale:** 95% of the hard work is done! Just need the private key now!
