# TestFlight Deployment Guide - WebAudit Pro iOS App

**Last Updated:** October 27, 2025
**App Version:** 1.2.1 (Build 1)
**Current Status:** Awaiting Apple Beta App Review (or Ready for Testing)

---

## Quick Start: Check Build Status

### Step 1: Check Apple App Store Connect
1. Go to: https://appstoreconnect.apple.com
2. Login with: Your Apple Developer account
3. Navigate: **My Apps > WebAudit Pro > TestFlight**
4. Check **Build 1.2.1 (1)** status:
   - 🔄 **In Review** = Waiting for Apple's approval
   - ✅ **Ready to Test** = Approved! Ready to add testers
   - ❌ **Rejected** = Apple found issues (unlikely)

---

## Current Status (As of Oct 27, 2025)

**Build 1.2.1 (1)** was submitted on Oct 22 at 2:20 PM UTC.

**Typical Timeline:**
- Submission: Oct 22, 2:20 PM UTC
- Review Time: 24-48 hours (Apple SLA)
- Expected Approval: Oct 22-24
- Current Status: ✅ Should be approved by now (check Step 1 above)

---

## Process: Add Your Business Partner as Tester

### Phase 1: Setup (If Not Already Done)

#### 1.1 Create Test Group in App Store Connect
```
App Store Connect > My Apps > WebAudit Pro > TestFlight
  └─ Internal Testing (automatically includes app development team)
  └─ External Testing
       └─ Create Group: "jumoki-external" (if needed)
           └─ Add up to 10,000 testers
```

#### 1.2 Get Your Business Partner's Apple ID
- Ask them for: **Their Apple ID email address**
- This email must be connected to an Apple device
- They need it to access TestFlight

### Phase 2: Add Tester (When Build is Ready)

#### 2.1 Go to TestFlight Settings
```
App Store Connect > My Apps > WebAudit Pro > TestFlight > External Testing
  └─ Select group: "jumoki-external" (or create new group)
```

#### 2.2 Add Business Partner
1. Click **"Add Tester"**
2. Enter their Apple ID email
3. Click **"Add"**
4. Status: "Pending Invitation"

#### 2.3 They Accept Invitation
1. They receive email: "You're invited to test WebAudit Pro"
2. They click the link in email
3. They accept the TestFlight invitation
4. They install TestFlight app from App Store (if not already installed)

### Phase 3: Install and Test

#### 3.1 They Install TestFlight
- On iPad Pro or iPhone: Open App Store
- Search: "TestFlight"
- Download and install

#### 3.2 They Find Your App in TestFlight
- Open TestFlight app
- Look for "WebAudit Pro" in the list
- Click **"Install"** (or **"Update"** if older version installed)

#### 3.3 They Test the App
- They can use it for 90 days
- Test on iPad Pro (recommended for their use case)
- Send you feedback

---

## Step-by-Step: Complete Process

### A. Wait for Build Approval (If Not Yet Approved)

**Current Status:** Build submitted Oct 22, likely approved by Oct 24

**What to Do:**
1. Check Apple App Store Connect daily
2. Build status at: https://appstoreconnect.apple.com
3. Look for: **TestFlight > Builds > Build 1.2.1 (1)**
4. Wait for status to change from 🔄 "In Review" to ✅ "Ready to Test"

### B. Add Business Partner as Tester (Once Build Approved)

**Assuming build is now "Ready to Test":**

```
1. Go to: https://appstoreconnect.apple.com
2. Click: "My Apps"
3. Click: "WebAudit Pro"
4. Click: "TestFlight" tab
5. Click: "External Testing" (in left sidebar)
6. Click: "Create Group" (if "jumoki-external" doesn't exist)
   ├─ Name: jumoki-external
   └─ Click: "Create"
7. Click: "Add Testers" (inside jumoki-external group)
8. Paste your business partner's Apple ID email
9. Click: "Add"
10. Status shows: "Pending Invitation"
```

### C. Invite Business Partner

**Apple sends them an email automatically:**
- Subject: "You're invited to test WebAudit Pro"
- They click the link in the email
- They accept the invitation
- They get access to TestFlight

**Optional: Send them a separate message:**
```
Hey [Name],

You've been invited to test the new WebAudit Pro app on TestFlight!

Here's what to do:
1. Check your email from Apple (subject: "You're invited to test WebAudit Pro")
2. Click the link to accept the invitation
3. Install the TestFlight app (free, from App Store)
4. Open TestFlight and find "WebAudit Pro"
5. Click "Install"
6. Try it out on your iPad Pro!

You'll have 90 days to test. Please let me know what you think!
```

### D. They Test on iPad Pro

**Their Experience:**
1. Install TestFlight (if not already installed)
2. Tap on "WebAudit Pro" in TestFlight
3. Tap "Install"
4. Wait for download and installation
5. Tap "Open"
6. App launches and they can start testing

**Key Features to Test:**
- Login/signup with email
- Enter website URL and generate summary
- View analysis history
- Download PDF reports
- Light/dark theme switching
- Offline functionality (if they turn off WiFi)

---

## Current Build Information

**Build Details:**
- **Version:** 1.2.1
- **Build Number:** 1
- **Bundle ID:** io.jumoki.weblser
- **IPA Size:** 19.60 MB
- **Minimum iOS:** 12.0
- **Submit Date:** October 22, 2025
- **Submission Time:** 2:20 PM UTC

**Features in Build 1.2.1:**
- ✅ Multi-user authentication (email/password)
- ✅ JWT token management
- ✅ Offline data support with SQLite
- ✅ Automatic cloud sync
- ✅ Light/Dark theme
- ✅ PDF report generation
- ✅ Website analysis
- ✅ Professional UI with Raleway font

---

## Detailed Instructions: Add External Tester

### Using App Store Connect Website

**Login & Navigate:**
```
1. Open: https://appstoreconnect.apple.com
2. Login with your Apple Developer account
3. Click: "Apps" (or "My Apps")
4. Select: "WebAudit Pro"
5. Click: "TestFlight" (top navigation)
```

**Add Tester Group:**
```
6. In left sidebar, click: "External Testing"
7. You should see "jumoki-external" group (created earlier)
8. If not, click: "Create Group"
   ├─ Group Name: jumoki-external
   ├─ Click: "Create"
```

**Add Individual Tester:**
```
9. Under "jumoki-external" group, click: "Add Tester"
10. In the dialog, enter:
    ├─ First Name: [Their first name]
    ├─ Last Name: [Their last name]
    ├─ Email: [Their Apple ID email]
11. Click: "Add"
12. Status shows: "Pending Invitation"
```

**They Accept:**
```
13. They receive email from Apple
14. They click the link in the email
15. They accept the TestFlight invitation
16. They're now added to the test group
```

### Using App Store Connect App (iOS/macOS)

**If You're on Mac:**
```
1. Install App Store Connect app (search in Mac App Store)
2. Login with Apple Developer account
3. Navigate: My Apps > WebAudit Pro > TestFlight > External Testing
4. Add tester manually or via email invitation
```

---

## Common Scenarios

### Scenario 1: Build Is Still "In Review"

**What You See:** 🔄 "In Review" status

**What To Do:**
- ⏳ Wait for Apple's review (usually 24-48 hours)
- ✅ Check back tomorrow
- 📧 Apple will notify you when approved
- Once approved, status changes to "Ready to Test" and you can add testers

### Scenario 2: Build Was Rejected

**What You See:** ❌ "Rejected" status with reason

**Likely Reasons:**
- Missing metadata (screenshots, description)
- Content issues
- Binary corrupted

**What To Do:**
1. Read the rejection reason in App Store Connect
2. Fix the issue
3. Build and submit a new version
4. Start the review process again

### Scenario 3: Build Was Approved

**What You See:** ✅ "Ready to Test" status

**What To Do:**
1. Follow instructions in "Step B: Add Business Partner as Tester" above
2. Add their Apple ID email
3. Apple sends them invitation automatically
4. They accept and install via TestFlight

### Scenario 4: Multiple Testers

**If You Want Multiple Testers:**
```
1. Create external test group: "jumoki-external"
2. Add multiple testers to the same group
3. All testers get the same build
4. You manage feedback from all of them in one place
```

---

## What Your Business Partner Needs

1. **Apple ID Email**
   - Must be a valid Apple ID
   - Should be linked to an Apple device (iPad Pro)

2. **Apple Device**
   - iPad Pro (which they have)
   - iOS 12.0 or later (most modern iPads have this)

3. **TestFlight App**
   - Download from: App Store
   - Free to install
   - Required to install beta apps

4. **Internet Connection**
   - WiFi or cellular to download app
   - Needed for running the app

---

## Troubleshooting

### Issue: Build Still "In Review"

**Symptom:** Build status hasn't changed after 48+ hours

**Solutions:**
1. Wait a bit longer (sometimes Apple is slow)
2. Check if build was rejected (look for red status)
3. Contact Apple Support if urgent

### Issue: Tester Not Receiving Email Invitation

**Symptom:** Tester says they didn't get email from Apple

**Solutions:**
1. Check spam folder for email from Apple
2. Resend invitation from App Store Connect
3. Try adding them again with correct email
4. Verify email is valid Apple ID (ask them to log in to iCloud)

### Issue: Tester Can't Find App in TestFlight

**Symptom:** They installed TestFlight but don't see WebAudit Pro

**Solutions:**
1. Build must be "Ready to Test" status (not still "In Review")
2. They must accept the invitation first
3. They might need to refresh TestFlight (pull down to refresh)
4. Sign out and sign back in with the correct Apple ID

### Issue: App Crashes When Launched

**If They Report:** "App keeps crashing"

**What To Do:**
1. Ask for crash details (can see in TestFlight feedback)
2. Check your device logs
3. Create bug fix and submit new build
4. They can test the new build after approval

---

## Timeline: From Now to Testing

**Assuming build already approved (expected by Oct 24):**

```
Today (Oct 27):
  ├─ ✅ Build should be "Ready to Test"
  └─ ➜ Check Apple App Store Connect

Next Step:
  ├─ Get business partner's Apple ID email
  └─ ➜ Add them as tester

After Add:
  ├─ Apple sends them email (automatic)
  ├─ They accept invitation
  ├─ They install TestFlight
  └─ ➜ They can install your app

Testing Phase:
  ├─ They test for up to 90 days
  ├─ They send feedback
  └─ ➜ You iterate and submit updates
```

---

## Update App: Creating New Builds

**If You Need to Submit Updates:**

```
1. Make code changes in Flutter
2. Bump version in pubspec.yaml
   ├─ Version: increase (e.g., 1.2.2)
   ├─ Build number: increment (e.g., 2)
3. Commit to git: git commit -m "feat: description"
4. Push to GitHub: git push origin main
5. Codemagic automatically builds:
   ├─ Triggers on git push
   ├─ Builds iOS app
   ├─ Submits to TestFlight
6. New build appears in App Store Connect
7. Goes through Apple review again (usually faster for updates)
8. Once approved, testers see "Update Available"
9. They can install the new version
```

---

## Key Dates & Deadlines

**Build 1.2.1 (1) Timeline:**
- Submitted: October 22, 2025 @ 2:20 PM UTC
- Expected Approval: October 22-24, 2025
- Tester Access: 90 days from approval
- Max Testing Period: ~January 22, 2026

---

## Helpful Links

**Apple Resources:**
- App Store Connect: https://appstoreconnect.apple.com
- TestFlight Overview: https://developer.apple.com/testflight/
- TestFlight FAQ: https://help.apple.com/testflight/

**Your Project:**
- GitHub Repo: https://github.com/Ntrospect/weblser
- Flutter Docs: https://flutter.dev/docs
- Codemagic CI/CD: https://codemagic.io/

---

## Summary: What To Do Right Now

1. **Check Status:**
   - Go to: https://appstoreconnect.apple.com
   - Find: WebAudit Pro > TestFlight > Build 1.2.1 (1)
   - Look for: ✅ "Ready to Test" status

2. **If Ready to Test:**
   - Get your business partner's Apple ID email
   - Go to: External Testing > jumoki-external (or create group)
   - Add them as tester with their email
   - They receive invitation automatically

3. **They Install & Test:**
   - They accept the TestFlight invitation
   - They download TestFlight app (from App Store)
   - They find your app in TestFlight
   - They click "Install"
   - They start testing!

---

**Questions?** Check the "Troubleshooting" section above or contact Apple Support.

**Next Build?** When you're ready to submit updates, just commit to GitHub and Codemagic will auto-build and submit!
