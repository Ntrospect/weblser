# WebAudit Pro - Flutter App Build Plan

## Current Status: Backend Complete ✅ | Frontend In Progress 🔄

**Date:** October 22, 2025
**Project:** WebAudit Pro - Professional Website Audit & Analysis Tool
**Repository:** C:\Users\Ntro\weblser\webaudit_pro_app

---

## Backend Completion Summary ✅

### Completed Components:
1. ✅ **audit_engine.py** - 10-point website evaluation framework with Claude AI
2. ✅ **report_generator.py** - 3 professional PDF document templates
3. ✅ **fastapi_server.py** - Extended with audit endpoints

### Available API Endpoints:
```
POST   /api/audit/analyze
GET    /api/audit/{audit_id}
GET    /api/audit/history/list
POST   /api/audit/generate-pdf/{audit_id}/{document_type}
DELETE /api/audit/{audit_id}
DELETE /api/audit/history/clear
```

### Database:
- **Storage:** JSON files (audit_history.json)
- **Future:** PostgreSQL on VPS (140.99.254.83:8000)

---

## Frontend Implementation (Phase 3)

### Current Work:
- ✅ Cloned weblser_app → webaudit_pro_app
- ✅ Updated pubspec.yaml with new app name
- ✅ Updated main.dart with "WebAudit Pro" title

### Remaining Screens to Build/Modify:

#### 1. Home Screen (lib/screens/home_screen.dart)
**Purpose:** URL input and audit initiation

**Key Changes from weblser:**
- Replace "Enter Website URL" with larger input field
- Change CTA button to "Run Website Audit"
- Display recent audits in history list
- Add audit status indicators

**Components:**
- TextField for URL input
- "Audit Website" button (primary action)
- Recent Audits list (showing overall_score and website_name)
- Loading indicator during audit
- Error handling for invalid URLs

**Flow:**
```
User enters URL → Click "Audit Website"
→ API call to /api/audit/analyze
→ Show loading spinner
→ Navigate to Results Screen with audit_id
```

---

#### 2. Results Screen (lib/screens/results_screen.dart) - NEW
**Purpose:** Display 10-point audit scores and recommendations

**Design Layout:**
```
┌─────────────────────────────────────┐
│      Website Name / URL              │
│                                      │
│    Overall Score: 72.5/100          │  ← Large prominent display
│    (Circular gauge)                  │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ 10 Criterion Scores (Grid)      │  │
│  │ [Card] [Card] [Card]            │  │
│  │ Score/Color: Green (8+), Yellow │  │
│  │ (6-8), Red (0-5)                │  │
│  └────────────────────────────────┘  │
│                                      │
│  Key Strengths:                      │
│  • [Strength 1]                      │
│  • [Strength 2]                      │
│  • [Strength 3]                      │
│                                      │
│  Critical Issues:                    │
│  • [Issue 1]                         │
│  • [Issue 2]                         │
│  • [Issue 3]                         │
│                                      │
│  Priority Recommendations:           │
│  [Top 5 recommendations]             │
│                                      │
│  [Download Reports ▼]               │
└─────────────────────────────────────┘
```

**Widgets Needed:**
- Circular progress indicator for overall score
- Individual score cards (10 per audit)
- Expandable recommendation list
- "View Detailed Recommendations" button → Reports Screen

**Data Model:**
```dart
class AuditResult {
  String id;
  String url;
  String websiteName;
  double overallScore;
  Map<String, double> scores; // 10 criteria
  List<String> keyStrengths;
  List<String> criticalIssues;
  List<Map> priorityRecommendations;
}
```

---

#### 3. Reports Screen (lib/screens/reports_screen.dart) - NEW
**Purpose:** Download 3 PDF documents

**Design Layout:**
```
┌──────────────────────────────────────┐
│       Website: [domain.com]           │
│       Audit ID: [xxxx]                │
│                                       │
│  ┌─────────────────────────────────┐ │
│  │ 📋 Website Audit Report         │ │
│  │ Diagnostic assessment (Free)    │ │
│  │ • 10-point evaluation           │ │
│  │ • Strengths & weaknesses        │ │
│  │ • Quick overview                │ │
│  │  [Download PDF]                 │ │
│  └─────────────────────────────────┘ │
│                                       │
│  ┌─────────────────────────────────┐ │
│  │ 🎯 Website Improvement Plan     │ │
│  │ Strategic roadmap (Paid)        │ │
│  │ • Priority recommendations      │ │
│  │ • Implementation timeline       │ │
│  │ • Expected outcomes             │ │
│  │  [Download PDF]                 │ │
│  └─────────────────────────────────┘ │
│                                       │
│  ┌─────────────────────────────────┐ │
│  │ 💼 Digital Partnership Proposal │ │
│  │ Engagement package (Contract)   │ │
│  │ • Our approach                  │ │
│  │ • Scope & deliverables          │ │
│  │ • Timeline & pricing            │ │
│  │  [Download PDF]                 │ │
│  └─────────────────────────────────┘ │
│                                       │
│  [Back to Results]                   │
└──────────────────────────────────────┘
```

**Widgets Needed:**
- 3 Document cards (each is a button)
- Document type icons
- Description text
- Download button per card
- Loading indicator during PDF generation
- File save dialog (download to Downloads folder)

**PDF Generation Flow:**
```
User clicks [Download PDF]
→ Call /api/audit/generate-pdf/{audit_id}/{doc_type}
→ Show loading spinner
→ Save file to Downloads
→ Show "Open PDF" button in snackbar
```

---

### UI Changes Summary:

#### Modified Screens:
1. **home_screen.dart**
   - Change from website summary analyzer to audit URL input
   - Add audit history list
   - Show overall_score and website_name in history items

#### New Screens:
2. **results_screen.dart** - Display 10 audit scores
3. **reports_screen.dart** - 3 PDF document downloads

#### Modified Models:
4. Create **lib/models/audit_result.dart**
   ```dart
   class AuditResult {
     String id;
     String url;
     String websiteName;
     DateTime auditTimestamp;
     double overallScore;
     Map<String, double> scores;
     List<String> keyStrengths;
     List<String> criticalIssues;
     List<Map> priorityRecommendations;
   }
   ```

#### Modified Services:
5. Update **lib/services/api_service.dart**
   - Change base URL to /api/audit/
   - Add auditWebsite() method
   - Add downloadPDF() method
   - Add getAuditHistory() method

---

## Color Scheme (WebAudit Pro Branding)

```dart
// Primary Colors
const Color PRIMARY = Color(0xFF2563EB);      // Blue
const Color ACCENT = Color(0xFF7C3AED);       // Purple
const Color SUCCESS = Color(0xFF16A34A);      // Green
const Color WARNING = Color(0xFFEA580C);      // Orange
const Color DANGER = Color(0xFFDC2626);       // Red
const Color TEXT = Color(0xFF1F2937);         // Dark Gray
const Color LIGHT = Color(0xFFF3F4F6);        // Light Gray

// Score-based colors:
// 8-10: GREEN (SUCCESS)
// 6-8:  ORANGE (WARNING)
// 0-6:  RED (DANGER)
```

---

## Implementation Order (Estimated 3-4 days)

### Day 1: Models & Services
- [ ] Create audit_result.dart model
- [ ] Update api_service.dart with audit methods
- [ ] Test API connections to backend

### Day 2: Home Screen Modification
- [ ] Redesign home_screen.dart for audit input
- [ ] Add URL input field
- [ ] Connect to auditWebsite() API
- [ ] Display audit history
- [ ] Add loading/error states

### Day 3: Results Screen Creation
- [ ] Build results_screen.dart from scratch
- [ ] Implement 10 score cards layout
- [ ] Add overall score circular gauge
- [ ] Add strengths/issues sections
- [ ] Add recommendations list

### Day 4: Reports Screen Creation
- [ ] Build reports_screen.dart from scratch
- [ ] Create 3 document cards
- [ ] Implement PDF download buttons
- [ ] Handle file save to Downloads
- [ ] Add "Open PDF" functionality

### Day 5: Integration & Testing
- [ ] Test complete audit flow end-to-end
- [ ] Test with 3-5 sample websites
- [ ] Verify PDF generation
- [ ] Polish UI/UX
- [ ] Fix any bugs

---

## File Modification Checklist

### New Files to Create:
- [ ] lib/models/audit_result.dart
- [ ] lib/screens/results_screen.dart
- [ ] lib/screens/reports_screen.dart

### Files to Modify:
- [x] pubspec.yaml (✅ DONE)
- [x] lib/main.dart (✅ DONE)
- [ ] lib/screens/home_screen.dart
- [ ] lib/services/api_service.dart
- [ ] lib/screens/settings_screen.dart (update contact details)

### Files to Keep (No changes):
- lib/theme/ (dark_theme.dart, light_theme.dart)
- lib/services/theme_provider.dart
- lib/screens/splash_screen.dart
- lib/screens/history_screen.dart (can be adapted for audit history)

---

## Testing Plan

### Unit Tests:
- [ ] Test AuditResult model parsing
- [ ] Test API service methods

### Integration Tests:
- [ ] Test audit with valid URL
- [ ] Test audit with invalid URL
- [ ] Test PDF download
- [ ] Test error handling

### Manual Testing:
- [ ] Test with github.com
- [ ] Test with jumoki.com
- [ ] Test with any .com website
- [ ] Test offline error handling
- [ ] Test theme switching (light/dark)

---

## Known Dependencies

### Flutter Packages (Already in weblser_app):
```yaml
flutter: sdk
http: ^1.1.0
provider: ^6.0.0
shared_preferences: ^2.2.0
url_launcher: ^6.1.0
path_provider: ^2.0.0
```

### May need to add:
```yaml
# For PDF download progress
dio: ^5.2.0  # Better HTTP handling with progress

# For file operations
file_saver: ^0.0.10  # Save files to Downloads
```

---

## API Integration Points

### Home Screen:
```dart
// Trigger audit
POST /api/audit/analyze
{
  "url": "https://example.com",
  "timeout": 10,
  "deep_scan": true
}

Response: AuditResponse {
  id: UUID,
  url, website_name, overall_score,
  scores: {10 criteria},
  key_strengths, critical_issues, priority_recommendations
}
```

### Results Screen:
```dart
// Get existing audit
GET /api/audit/{audit_id}

// Get history
GET /api/audit/history/list?limit=100
```

### Reports Screen:
```dart
// Download PDF
GET /api/audit/generate-pdf/{audit_id}/{document_type}

document_type options:
- "audit-report"
- "improvement-plan"
- "partnership-proposal"
```

---

## Next Session Checklist

Before proceeding with Flutter implementation:

- [ ] Confirm overall design layout with user
- [ ] Confirm color scheme (PRIMARY blue, ACCENT purple)
- [ ] Confirm PDF branding (company name, footer details)
- [ ] Review API endpoints - all correct
- [ ] Confirm deployment plan (same VPS as weblser)

---

## Success Criteria

**MVP Complete when:**
1. ✅ User can enter URL in home screen
2. ✅ Audit runs and displays 10 scores
3. ✅ All 3 PDFs download correctly
4. ✅ App handles errors gracefully
5. ✅ Audit history persists
6. ✅ Dark/light theme works
7. ✅ Tested on iOS and Android (simulator)

---

## Timeline Summary

| Phase | Component | Status | ETA |
|-------|-----------|--------|-----|
| 1 | Backend (API + Engine + PDFs) | ✅ DONE | Oct 22 |
| 2 | Flutter Setup & Models | 🔄 In Progress | Oct 22 |
| 3 | Home Screen | ⏳ Pending | Oct 23 |
| 4 | Results Screen | ⏳ Pending | Oct 23 |
| 5 | Reports Screen | ⏳ Pending | Oct 24 |
| 6 | Integration & Testing | ⏳ Pending | Oct 24-25 |
| 7 | Deployment | ⏳ Pending | Oct 25 |

**Total Estimated Time:** 9-10 days (3 days backend ✅ + 5 days frontend + 2 days testing/deploy)

---

## Notes for Developer

- **Reuse Pattern:** Leverage weblser_app structure (Provider, SharedPreferences, theme system)
- **No Database Needed:** Store audit history locally in SharedPreferences (or JSON)
- **Responsive Design:** Use adaptive layouts for mobile/tablet/desktop
- **Error Handling:** Show user-friendly error messages for network/validation issues
- **Performance:** Cache audit results locally to avoid re-fetching

---

**Created:** Oct 22, 2025
**Status:** Ready for Flutter Screen Implementation
**Next Step:** Build Home Screen for URL input & audit trigger

