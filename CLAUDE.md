# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**weblser** - A Python CLI tool that analyzes websites and generates intelligent summaries of their purpose and content. It fetches a URL, extracts metadata and full page content, then uses Claude AI to generate concise, meaningful summaries that can be passed to other agents for further processing.

## Setup

### Installation

```bash
pip install -r requirements.txt
```

### API Key Setup

This tool requires an Anthropic API key to generate summaries using Claude.

**Get your API key:**
1. Visit https://console.anthropic.com/account/keys
2. Create a new API key
3. Set it as an environment variable

**Windows (Command Prompt):**
```cmd
set ANTHROPIC_API_KEY=your-api-key-here
```

**Windows (PowerShell):**
```powershell
$env:ANTHROPIC_API_KEY="your-api-key-here"
```

**Linux/macOS (Bash):**
```bash
export ANTHROPIC_API_KEY="your-api-key-here"
```

**Persistent setup (add to your shell profile):**
- Windows: Add to Environment Variables in System Settings
- Linux/macOS: Add to ~/.bashrc, ~/.zshrc, or equivalent

### Running the Analyzer

#### Option 1: Using Executable Scripts (Recommended)

**Windows:**
```bash
weblser.bat https://example.com
weblser.bat https://example.com --json
weblser.bat https://example.com --pdf
weblser.bat https://example.com --pdf --output my-report.pdf
weblser.bat https://example.com --pdf --company-name "Jumoki Agency LLC" --company-details "1309 Coffeen Avenue STE 1200, Sheridan WY 82801, 1(307)650-2395, info@jumoki.agency"
weblser.bat https://example.com --pdf --logo "path/to/logo.png" --company-name "Your Company"
weblser.bat https://example.com --timeout 15 --api-key your-key-here
```

**Linux/macOS:**
```bash
./weblser https://example.com
./weblser https://example.com --json
./weblser https://example.com --pdf
./weblser https://example.com --pdf --output my-report.pdf
./weblser https://example.com --pdf --company-name "Jumoki Agency LLC" --company-details "1309 Coffeen Avenue STE 1200, Sheridan WY 82801, 1(307)650-2395, info@jumoki.agency"
./weblser https://example.com --pdf --logo "path/to/logo.png" --company-name "Your Company"
./weblser https://example.com --timeout 15 --api-key your-key-here
```

The executable scripts automatically:
- Check for Python installation
- Install missing dependencies
- Use ANTHROPIC_API_KEY environment variable if set
- Run the analyzer

#### Option 2: Direct Python Execution

```bash
# Display intelligent summary
python analyzer.py https://example.com

# Output as JSON for programmatic use
python analyzer.py https://example.com --json

# Generate formatted PDF report (auto-named from domain)
python analyzer.py https://example.com --pdf

# Generate PDF with custom filename
python analyzer.py https://example.com --pdf --output my-report.pdf

# Generate branded PDF with company info
python analyzer.py https://example.com --pdf --company-name "Your Company" --company-details "Address, Phone, Email"

# Generate PDF with logo
python analyzer.py https://example.com --pdf --logo "path/to/logo.png" --company-name "Your Company"

# Customize request timeout
python analyzer.py https://example.com --timeout 15

# Pass API key directly
python analyzer.py https://example.com --api-key your-key-here
```

#### Global Installation (All Platforms)

Add the script directory to your PATH to run `weblser` from anywhere:

**Windows (Command Prompt):**
```cmd
set PATH=%PATH%;C:\Users\Ntro\weblser
weblser https://example.com
```

**Linux/macOS (Bash):**
```bash
export PATH="/path/to/weblser:$PATH"
weblser https://example.com
```

## Architecture

The project uses a simple, single-module architecture with Claude API integration:

### `analyzer.py`

The main module contains the `WebsiteAnalyzer` class with these key responsibilities:

- **`analyze(url)`** - Main entry point that:
  1. Normalizes the URL (adds https:// if no scheme provided)
  2. Fetches the page with requests library
  3. Parses HTML with BeautifulSoup
  4. Extracts metadata (title, meta description)
  5. Extracts full page content (removes noise, keeps meaningful text)
  6. Calls Claude API to generate intelligent summary
  7. Returns structured results

- **Metadata extraction methods**:
  - `_extract_title()` - Tries multiple sources: `<title>` tag, og:title meta tag, then H1 as fallback
  - `_extract_meta_description()` - Tries meta name="description", then og:description

- **Content extraction**:
  - `_extract_full_content()` - Removes scripts, styles, navigation, and footer elements; extracts main content from `<main>`, `<article>`, or primary content divs; cleans whitespace; limits to 5000 characters

- **Summarization**:
  - `_generate_summary_with_claude()` - Sends extracted content to Claude 3.5 Sonnet model with a prompt to generate a 2-3 sentence summary focused on purpose, features, and target audience

- **Error handling** - Returns a structured response with `success` flag and error message on failure. Handles network errors, API errors, and malformed HTML gracefully.

### Output Format

The analyzer returns a dictionary with:

```python
{
    'url': str,                           # The analyzed URL
    'title': str or None,                 # Page title
    'meta_description': str or None,      # Page meta description
    'extracted_content': str or None,     # First 500 chars of extracted content (for reference)
    'summary': str,                       # AI-generated summary or error message
    'success': bool                       # Whether analysis succeeded
}
```

### PDF Output Format

When using the `--pdf` flag, a formatted PDF report is generated containing:

- **Report Title** - "Website Analysis Report"
- **URL** - The analyzed website URL
- **Page Title** - Extracted from the page's title tag or metadata
- **Meta Description** - The page's meta description tag
- **Summary** - AI-generated summary of the website's purpose

**PDF Naming:**
- Default: Automatically generated from domain (e.g., `example-com-analysis.pdf`)
- Custom: Use `--output filename.pdf` to specify a custom name

**Example:**
```bash
weblser.bat https://github.com --pdf
# Creates: github-com-analysis.pdf

weblser.bat https://github.com --pdf --output git-analysis.pdf
# Creates: git-analysis.pdf
```

### Branded PDF Reports

You can customize PDF reports with your company branding:

**Available Branding Options:**
- `--logo <path-or-url>` - Path to logo file or URL to logo image
- `--company-name <name>` - Your company name (displayed in header)
- `--company-details <details>` - Contact information (displayed in footer)

**Examples:**

With company details only:
```bash
weblser.bat https://jumoki.com --pdf \
  --company-name "Jumoki Agency LLC" \
  --company-details "1309 Coffeen Avenue STE 1200, Sheridan WY 82801, 1(307)650-2395, info@jumoki.agency"
```

With logo file:
```bash
weblser.bat https://example.com --pdf \
  --logo "C:\path\to\logo.png" \
  --company-name "Your Company" \
  --company-details "Your contact details"
```

With logo URL:
```bash
weblser.bat https://example.com --pdf \
  --logo "https://example.com/assets/logo.png" \
  --company-name "Your Company"
```

**PDF Header & Footer Content:**
- Header includes: Company logo (if provided) and company name
- Footer includes: Company contact details with divider line
- Professional styling with purple company name (color: #7c3aed)

## Integration with Other Agents

### Using JSON Output

Pass the `--json` flag to get structured JSON output that can be easily parsed by other agents:

```bash
weblser.bat https://example.com --json
./weblser https://example.com --json
```

Extract just the summary:
```bash
weblser https://example.com --json | jq '.summary'
```

### Python Integration

Import and use directly in other Python code:

```python
from analyzer import WebsiteAnalyzer

# API key from environment or parameter
analyzer = WebsiteAnalyzer(api_key="your-api-key")  # or use ANTHROPIC_API_KEY env var
result = analyzer.analyze('https://example.com')
if result['success']:
    print(result['summary'])
else:
    print(f"Error: {result['summary']}")
```

## Extending the Analyzer

To modify the summarization behavior:

1. **Change the summary prompt** - Edit the prompt in `_generate_summary_with_claude()` to focus on different aspects
2. **Adjust content extraction** - Modify `_extract_full_content()` to include/exclude different elements
3. **Change the model** - Update the `model` parameter in `_generate_summary_with_claude()` (e.g., use claude-3-opus-20250219)
4. **Add metadata extraction** - Add new extraction methods following the pattern of `_extract_title()`
5. **Increase summary length** - Adjust the `max_tokens` parameter in the API call

## Common Issues

- **API Key Error** - Make sure ANTHROPIC_API_KEY is set or pass `--api-key your-key`
- **Rate Limiting** - If you hit API rate limits, add delays between requests or upgrade your API plan
- **Network Timeout** - Use `--timeout` parameter to increase timeout for slow websites
- **Content Extraction Issues** - Some sites may have unusual HTML structures; the tool tries main/article/content divs first, then falls back to full page text
- **SSL Certificate Errors** - Ensure requests library is up to date: `pip install --upgrade requests`

## Recent Development (Session Oct 24, 2025) - CONTINUED

### Supabase Integration & Phase 2: Offline Support ✅
**Complete offline-first architecture with local SQLite + automatic cloud sync**

#### Phase 1: Supabase Foundation ✅
**Completed:** Supabase PostgreSQL database with full security layer
- **Project Created**: `websler-pro` on agenticn8 Pro account
- **Database**: PostgreSQL SMALL instance (2GB RAM, US-East Virginia, $15/month)
- **API URL**: https://vwnbhsmfpxdfcvqnzddc.supabase.co
- **Credentials Saved**: Anon Key + Service Role Key in secure location

**Database Schema** (5 tables + security):
- `users` - User profiles extending Supabase auth
- `audit_results` - Full 10-point audit results with scores (JSONB)
- `website_summaries` - Quick Websler summaries
- `recommendations` - Individual recommendations per audit
- `pdf_generations` - Track PDF downloads for analytics

**Security Features**:
- Row-Level Security (RLS) enabled on all tables
- Each user can only see their own data
- Auto-trigger creates user profile on signup
- Primary keys, foreign keys, and constraints
- Strategic indexes for performance
- Auto-timestamp triggers for created_at/updated_at

#### Phase 2: Local Offline Support ✅
**Completed:** Full offline capability with automatic sync when online

**Architecture**:
```
User Action (audit/summary)
  ↓
Save to Local SQLite (always works)
  ↓
Is Online?
  ├─ YES → Sync to Supabase + mark synced
  └─ NO → Queue for later sync
    ↓
When Online → Auto-sync all queued items
```

**Files Created**:
1. **`lib/database/local_db.dart`** - SQLite Database Management (322 lines)
   - LocalDatabase singleton managing sqflite connection
   - Mirror schema of Supabase tables (users, audits, summaries, recommendations, sync_queue)
   - Methods: saveAuditLocal, saveSummaryLocal, getUnsyncedRecords, markSynced, addToSyncQueue
   - Retry logic with retry_count and last_error tracking

2. **`lib/services/connectivity_service.dart`** - Network Monitoring (26 lines)
   - Singleton tracking online/offline status
   - Stream for real-time connectivity changes
   - isOnline/isOffline getters
   - Automatic status detection and printing

3. **`lib/services/sync_service.dart`** - Offline Sync Orchestration (240 lines)
   - ChangeNotifier for Provider integration
   - Methods: saveAuditWithSync(), saveSummaryWithSync(), syncPendingChanges()
   - Automatic sync when connectivity restored
   - Retry logic with error tracking
   - Sync status for UI (isSyncing, syncStatus, pendingItemsCount)

4. **`lib/widgets/offline_indicator.dart`** - Offline Status UI (32 lines)
   - Banner showing "You're offline - changes will sync when online"
   - Auto-hides when online
   - Professional styling with icon

**Dependencies Added** (pubspec.yaml):
- `sqflite: ^2.3.0` - Local SQLite database
- `connectivity_plus: ^5.0.0` - Network status detection
- `path: ^1.8.3` - Path utilities
- `uuid: ^4.0.0` - ID generation

**Updated Files**:
- `lib/main.dart` - Added SyncService to Provider, integrated OfflineIndicator

**Git Commits** (Phase 2):
- `c0d5f2f` - "feat: Implement Phase 2 - Local offline support with sqflite and sync service"
- **Snapshot Tag**: `snapshot-phase2-offline-support`

#### Desktop Layout Improvements ✅
**Session Start**: Fixed audit results screen layout and styling

**UI Fixes**:
- Fixed ExpansionTile divider lines (removed black lines from expanded recommendations)
- Centered "Overall Score" on desktop (full-width on mobile)
- Increased "10-Point Evaluation" title size (32px, 40px top spacing, 4px bottom spacing)
- Updated "Analysis History" card titles (18px, Raleway font, blue/green color)

**Git Commits** (UI Work):
- `5ac8bc5` - fix: Restore mobile view while keeping desktop centered layout
- `6f41ddf` - fix: Account for logo width when centering Overall Score text
- `256c114` - style: Further reduce spacing below title
- `6581b32` - style: Increase Analysis History card titles size with Raleway font
- `a83d39b` - fix: Use valid ExpansionTile parameters for Flutter version
- **Snapshot Tag**: `snapshot-oct24-desktop-layout-improvements`

#### Current Status
✅ **Phase 1 & 2 Complete** - Ready for Phase 3 (Authentication)
- Local SQLite database ready with 6 tables
- Sync service ready for integration with Supabase
- Offline indicator working
- Connectivity monitoring in place

#### Next Steps: Phase 3 (Authentication)
🔄 **Planned Features**:
1. Email/password signup/login screens
2. Supabase auth integration
3. Session management with user persistence
4. Protected screens (require authentication)
5. User profile management in Settings
6. Logout functionality

**Recommendation**: Start Phase 3 immediately - foundation is solid and ready for auth integration.

---

## Recent Development (Session Oct 24, 2025)

### Unified Websler/Pro Workflow Architecture ✅
**Consolidated summary → audit upgrade funnel with clean navigation**

#### New Data Model
- `WebsiteAnalysis` model (lib/models/website_analysis.dart)
  - Single unified model for both summaries AND audits
  - Supports `AnalysisType.summary` and `AnalysisType.audit`
  - Automatic conversion from both weblser and audit API responses
  - Tracks linked summaries if audit was upgraded from summary

#### Enhanced API Service
- `getUnifiedHistory()` - Fetch combined summaries + audits (sorted newest first)
- `generateWebslerSummary()` - Quick summary wrapper
- `upgradeToAudit()` - Convert summary to full 10-point audit
- `generatePdfUnified()` - Works with both summary and audit PDFs
- `deleteAnalysisUnified()` - Delete either type uniformly
- All new methods backward compatible with existing endpoints

#### Navigation Refactor
- Simplified to clean **3-screen structure**: Home | History | Settings
- **Home Screen**: Websler summary generator
  - Simple URL input card with gradient design
  - "Generate Summary" button
  - Summary appears in dialog with "Upgrade to Pro" option
  - "How It Works" timeline explaining the flow
- **History Screen**: Unified history view
  - Combines summaries and audits in chronological order
  - Color-coded: Blue (summaries), Green/Orange/Red (audits)
  - Type-specific actions:
    * Summaries: "Upgrade to Pro" button
    * Audits: "View Audit" button
  - Delete individual items or clear all
  - Pull-to-refresh for latest data
- **Settings Screen**: Theme & API configuration

#### User Experience Improvements
- Loading dialogs with spinners when upgrading summaries
- "Running WebAudit Pro..." message with timeout guidance
- Non-dismissible dialogs prevent accidental cancellation
- Proper AppBar spacing (130px padding) to prevent content cutoff
- App version updated to 1.2.1
- Removed duplicate UI elements
- Professional timeline spacing

#### Git Commits (Session)
- `bf7829a` - feat: Implement unified Websler/Pro workflow
- `04cfaaa` - refactor: Simplify navigation to 3-screen structure
- `627575c` - feat: Add loading dialog for 'Upgrade to Pro' (History)
- `be448b4` - feat: Add loading dialog for 'Upgrade to Pro' (Home)
- `4c8a13e` - chore: Update app version to 1.2.1
- `951c566` - fix: Remove duplicate 'How It Works' title
- `b52b99a` - style: Add 40px timeline spacing
- `92c26dd` - fix: History screen padding

#### Technical Details
- Maintains separation of concerns (models, services, screens)
- All existing audit/summary functionality intact
- New unified methods are additive, not replacing
- Supports future features (export, sharing, advanced filtering)
- Ready for iOS TestFlight and Windows distribution

#### Product Flow
1. User opens Home → sees Websler summary input
2. Enters URL → gets instant AI summary
3. Summary dialog shows with "Upgrade to Pro" button
4. Can close or click upgrade
5. Loading spinner shows during audit (1+ minute)
6. Results display or saved to History
7. History tab shows all summaries and audits together
8. Users can view, upgrade, or delete any analysis

**Status**: Feature complete and tested. Ready for production use.

## Recent Development (Session Oct 21, 2025)

### Professional Splash Screen 🎨
✅ **Flutter splash screen with Websler branding**
- Smooth fade & scale animations (2-second display)
- Websler logo and "AI-Powered Website Analyzer" tagline
- Multi-platform support: Android, iOS, Windows, web
- Auto-generated splash assets via flutter_native_splash
- Dark theme background with light/dark mode compatibility
- Commit: `d5bc421` - "feat: Add professional splash screen with Websler branding"

## Recent Development (Session Oct 20, 2025)

### Windows Desktop App (v1.1.0)
✅ **Complete cross-platform Flutter application** with professional UI/UX
- Light & Dark theme support with persistent preferences (SharedPreferences)
- Responsive layouts for desktop and mobile (2-column desktop, stacked mobile)
- Jumoki branding with theme-aware logo swapping
- Professional Raleway typography globally applied

### Windows Installer (.exe)
✅ **Inno Setup installer** ready for distribution
- Professional installer with Start Menu shortcuts and uninstall support
- File: `weblser-1.1.0-installer.exe`
- Location: `installers/` folder

### PDF Download Feature
✅ **Enhanced PDF generation** with professional branding
- PDFs save to user's Downloads folder (Windows: `C:\Users\[User]\Downloads\`)
- Files named with timestamps: `weblser-analysis-[timestamp].pdf`
- "Open" button in snackbar to launch PDF immediately after download
- API Service updated: `lib/services/api_service.dart`

### Professional PDF Header
✅ **Dual-logo centered header** for branded reports
- Websler logo (left) - 1.0" width, auto height (proportional)
- Jumoki logo (right) - 1.1" width, auto height (proportional)
- 15px spacing between logos
- Logos centered on page with proper whitespace balance
- Backend: Updated `analyzer.py` with proportional image scaling

### Flutter Home Screen UI Improvements
✅ **Optimized layout spacing**
- Reduced section spacing: 32px → 20px
- Reduced outer padding: 24px → 16px (vertical)
- Added 40px bottom padding for better scrolling experience
- Improved overall container height for better content visibility

### App Icon
✅ **Custom Jumoki AI Robot icon**
- Replaced default Flutter logo with `jumoki_AI_robot.ico`
- Applied to: `windows/runner/resources/app_icon.ico`
- Appears in Windows taskbar, Start Menu, and installer

### CI/CD Pipeline
✅ **Codemagic automated builds**
- GitHub integration for automatic builds on push
- Android & iOS builds supported
- Workflow: Push to GitHub → Codemagic builds automatically

### iOS TestFlight Build (Oct 22, 2025) ✅
✅ **Build 1.2.1 (1) successfully submitted to TestFlight**
- Build completed and uploaded: Oct 22, 2025 at 2:20 PM UTC
- IPA size: 19.60 MB
- Code signing: Automatic via Codemagic Workflow Editor UI
- Build artifacts: Full archive (Runner.xcarchive) + debug symbols
- Current status: In Apple Beta App Review (24-48 hour typical review time)
- Key breakthrough: Switched from YAML certificate handling to Codemagic Workflow Editor UI
- Once approved: Ready to assign to jumoki-external test group (4 testers)

### Backend PDF Generation
✅ **Enhanced `analyzer.py`** with professional logo header
- Reads logo files from backend directory
- Automatic fallback if logos missing
- `weblser_logo.png` - Websler branding
- `jumoki_coloured_transparent_bg.png` - Jumoki branding
- Proportional scaling to prevent image distortion

### VPS Deployment
✅ **FastAPI backend** running on 140.99.254.83:8000
- Deployed via systemd service
- Environment variable: ANTHROPIC_API_KEY configured
- PDF generation with dual-logo headers fully functional

### Git Repository
✅ **Version control with GitHub**
- Repository: https://github.com/Ntrospect/weblser
- All changes committed and pushed
- Full backup and rollback capability

### Completed Tasks (Session Oct 22, 2025)
✅ **Apple Developer Account Setup**
- Account approved and configured ($99/year)
- TestFlight distribution now active
- iOS app submitted and awaiting Apple Beta App Review

### Current Tasks
🔄 **Apple Beta App Review in Progress**
- Build 1.2.1 (1) awaiting Apple's review (24-48 hours typical)
- Once approved: Assign to jumoki-external test group
- iPad Pro owner can then test the app
- Gather feedback and iterate if needed

### Technology Stack
- **Backend**: Python FastAPI (VPS deployment)
- **Frontend**: Flutter (cross-platform)
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Theming**: Material Design 3 (Light & Dark modes)
- **PDF Generation**: ReportLab (Python)
- **CI/CD**: Codemagic
- **Version Control**: Git/GitHub
- **Distribution**: Windows Installer (Inno Setup), iOS (TestFlight pending), macOS (pending)
