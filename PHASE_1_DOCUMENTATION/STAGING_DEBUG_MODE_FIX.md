# Staging Debug Mode Fix - October 29, 2025

## Problem

Staging deployment was using **production Supabase credentials** instead of staging credentials. Console showed:

```
🌍 Environment: Production
📦 Supabase Project: websler-pro
🔐 Supabase URL: https://vwnbhsmfpxdfcvqnzddc.supabase.co
```

This caused "Invalid API key" errors when trying to log in to staging.

## Root Cause

When building Flutter web, we need to explicitly use `--debug` flag to ensure `kDebugMode = true`:

- `flutter build web` (no flag) → Profile mode → `kDebugMode = false` → Uses production Supabase
- `flutter build web --debug` → Debug mode → `kDebugMode = true` → Uses staging Supabase
- `flutter build web --release` → Release mode → `kDebugMode = false` → Uses production Supabase

The previous deployment used `flutter build web` which defaulted to profile mode with production credentials.

## Solution

Changed staging build command from:
```bash
flutter build web              # ❌ Uses production Supabase
```

To:
```bash
flutter build web --debug      # ✅ Uses staging Supabase
firebase deploy -P staging
```

## Verification

After redeployment with `--debug` flag, console now correctly shows:

```
✅ .env file loaded successfully
🌍 Environment: Staging
📦 Supabase Project: websler-pro-staging
🔐 Supabase URL: https://kmlhslmkdnjakkpluwup.supabase.co
✅ Supabase initialized successfully for Staging
✅ AuthService initialized
```

## Updated Build Commands

### For Development (Local Testing)
```bash
flutter run                    # Uses staging Supabase
```

### For Staging Deployment
```bash
flutter build web --debug      # Staging Supabase
firebase deploy -P staging     # Deploy to staging.websler.pro
```

### For Production Deployment
```bash
flutter build web --release    # Production Supabase
firebase deploy -P production  # Deploy to websler.pro
```

## Key Files

- `lib/config/environment.dart` - Environment detection using `kDebugMode`
- `lib/main.dart` - Supabase initialization (lines 17-51)
- `.firebaserc` - Firebase project aliases for staging/production

## What Changed

✅ Redeployed staging with `flutter build web --debug`
✅ Staging now uses correct Supabase project (websler-pro-staging)
✅ Login/signup should work at https://staging.websler.pro/

## Timeline

- **Issue Discovered**: User tried to log in at staging.websler.pro, got "Invalid API key"
- **Root Cause Identified**: Build mode not set to debug for staging
- **Fix Applied**: Rebuilt with `--debug` flag and redeployed
- **Verification**: Console logs now show correct staging environment

---

**Status**: ✅ FIXED - Staging environment now correctly uses staging Supabase

