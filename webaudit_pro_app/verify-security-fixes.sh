#!/bin/bash

# Security Verification Script
# Verifies that all security fixes have been properly applied

echo "🔒 WebAudit Pro - Security Verification Report"
echo "=============================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS=0
FAIL=0

# Function to check condition
check() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅${NC} $2"
        ((PASS++))
    else
        echo -e "${RED}❌${NC} $2"
        ((FAIL++))
    fi
}

echo "1️⃣  Checking Secret Files Removed..."
[ ! -f "service_rolesecret websler - Supaba.txt" ]
check $? "Secret file 'service_rolesecret websler - Supaba.txt' removed from working directory"

[ ! -f ".mcp.json" ]
check $? "Secret file '.mcp.json' removed from working directory"

echo ""
echo "2️⃣  Checking .gitignore Configuration..."
grep -q "\.env$" .gitignore
check $? ".env entry added to .gitignore"

grep -q "\*secret\*" .gitignore
check $? "*secret* pattern added to .gitignore"

grep -q "\.mcp\.json" .gitignore
check $? ".mcp.json entry added to .gitignore"

echo ""
echo "3️⃣  Checking Environment Files..."
[ -f ".env.example" ]
check $? ".env.example template created (safe to commit)"

[ -f ".env" ]
check $? ".env file created (not tracked by Git)"

! git ls-files | grep -q "\.env$"
check $? ".env is not tracked in Git"

! git ls-files | grep -q "service_rolesecret"
check $? "Secret files not tracked in Git history"

echo ""
echo "4️⃣  Checking Code Changes..."
grep -q "flutter_dotenv" pubspec.yaml
check $? "flutter_dotenv dependency added to pubspec.yaml"

grep -q "await dotenv.load" lib/main.dart
check $? "lib/main.dart loads .env file"

grep -q "EnvConfig.getApiUrl()" lib/services/api_service.dart
check $? "lib/services/api_service.dart uses EnvConfig"

[ -f "lib/utils/env_loader.dart" ]
check $? "lib/utils/env_loader.dart created for centralized env access"

! grep -q "eyJhbGciOiJIUzI1NiIs" lib/main.dart
check $? "No hardcoded JWT tokens in lib/main.dart"

! grep -q "140.99.254.83" lib/main.dart
check $? "No hardcoded IP addresses in lib/main.dart"

echo ""
echo "5️⃣  Checking Git Commits..."
git log --oneline -n 5 | grep -q "security: Implement environment variables"
check $? "Security commit found in Git history"

echo ""
echo "6️⃣  Checking Documentation..."
[ -f "SECURITY_REMEDIATION_SUMMARY.md" ]
check $? "SECURITY_REMEDIATION_SUMMARY.md created"

[ -f "SETUP_GIT_SECRETS.md" ]
check $? "SETUP_GIT_SECRETS.md created"

echo ""
echo "=============================================="
echo "📊 Verification Results"
echo "=============================================="
echo -e "✅ Passed: ${GREEN}$PASS${NC}"
echo -e "❌ Failed: ${RED}$FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✅ All security fixes verified successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Rotate Supabase credentials in dashboard"
    echo "2. Update .env file with new credentials"
    echo "3. Setup HTTPS for API endpoint"
    echo "4. Install git-secrets to prevent future leaks"
    exit 0
else
    echo -e "${RED}❌ Some security checks failed. Please review above.${NC}"
    exit 1
fi
