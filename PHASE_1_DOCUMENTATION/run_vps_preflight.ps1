# VPS Pre-Flight Verification Script (PowerShell)
# Purpose: Run pre-flight checklist on VPS via SSH
# Usage: powershell -ExecutionPolicy Bypass -File run_vps_preflight.ps1

# VPS Configuration
$VPS_HOST = "140.99.254.83"
$VPS_USER = "root"
$VPS_PASSWORD = "Burrawang1968"

# Color codes
$GREEN = [char]27 + "[32m"
$RED = [char]27 + "[31m"
$YELLOW = [char]27 + "[33m"
$NC = [char]27 + "[0m"

Write-Host "======================================================================"
Write-Host "  VPS PRE-FLIGHT VERIFICATION"
Write-Host "  Connecting to $VPS_HOST..."
Write-Host "======================================================================"
Write-Host ""

# Pre-flight checklist script (inline bash)
$PREFLIGHT_SCRIPT = @'
#!/bin/bash

echo "======================================================================"
echo "  VPS PRE-FLIGHT VERIFICATION CHECKLIST"
echo "  PDF Maker Phase 1 Deployment Prerequisites"
echo "======================================================================"
echo ""
echo "Host: 140.99.254.83"
echo "Date: $(date)"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0

pass_check() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((PASSED++))
}

fail_check() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((FAILED++))
}

warn_check() {
    echo -e "${YELLOW}⚠ WARN${NC}: $1"
}

echo "======================================================================"
echo "1. OPERATING SYSTEM CHECK"
echo "======================================================================"
echo ""

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME="$NAME"
    OS_VERSION="$VERSION_ID"
    echo "Operating System: $OS_NAME $OS_VERSION"

    if [[ "$OS_NAME" == *"Ubuntu"* ]] || [[ "$OS_NAME" == *"Debian"* ]]; then
        pass_check "Linux OS detected (required for deployment)"
    else
        fail_check "OS is not Ubuntu/Debian (detected: $OS_NAME)"
    fi
else
    fail_check "Cannot determine OS"
fi
echo ""

echo "======================================================================"
echo "2. PYTHON VERSION CHECK"
echo "======================================================================"
echo ""

if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    echo "Python version: $PYTHON_VERSION"

    PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
    PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

    if [ "$PYTHON_MAJOR" -gt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 11 ]); then
        pass_check "Python 3.11 or higher installed"
    else
        fail_check "Python version is $PYTHON_VERSION (need 3.11+)"
    fi
else
    fail_check "Python 3 not found (required)"
fi
echo ""

echo "======================================================================"
echo "3. DISK SPACE CHECK"
echo "======================================================================"
echo ""

DISK_USAGE=$(df -h / | awk 'NR==2 {print $4}')
DISK_AVAILABLE=$(df -B1 / | awk 'NR==2 {print $4}')
DISK_AVAILABLE_GB=$((DISK_AVAILABLE / 1024 / 1024 / 1024))

echo "Available disk space: ${DISK_AVAILABLE_GB}GB ($DISK_USAGE available)"

if [ "$DISK_AVAILABLE_GB" -ge 5 ]; then
    pass_check "Sufficient disk space (need 5GB, have ${DISK_AVAILABLE_GB}GB)"
else
    fail_check "Insufficient disk space (need 5GB, have ${DISK_AVAILABLE_GB}GB)"
fi
echo ""

echo "======================================================================"
echo "4. MEMORY CHECK"
echo "======================================================================"
echo ""

MEMORY_TOTAL=$(free -h | awk 'NR==2 {print $2}')
MEMORY_AVAILABLE=$(free -h | awk 'NR==2 {print $7}')

echo "Total memory: $MEMORY_TOTAL"
echo "Available memory: $MEMORY_AVAILABLE"

MEMORY_AVAIL_NUM=$(free -B1 | awk 'NR==2 {print $7}')
MEMORY_AVAIL_GB=$((MEMORY_AVAIL_NUM / 1024 / 1024 / 1024))

if [ "$MEMORY_AVAIL_GB" -ge 2 ]; then
    pass_check "Sufficient memory available (need 2GB, have ${MEMORY_AVAIL_GB}GB+)"
else
    fail_check "Insufficient memory (need 2GB, have ${MEMORY_AVAIL_GB}GB)"
fi
echo ""

echo "======================================================================"
echo "5. PACKAGE MANAGER CHECK"
echo "======================================================================"
echo ""

if command -v apt-get &> /dev/null; then
    pass_check "apt-get is available"

    echo "Testing apt-get access..."
    if apt-get update -qq 2>/dev/null; then
        pass_check "apt-get can access package repositories"
    else
        warn_check "apt-get update failed (may need credentials)"
    fi
else
    fail_check "apt-get not found (required for dependency installation)"
fi
echo ""

echo "======================================================================"
echo "6. REQUIRED SYSTEM PACKAGES"
echo "======================================================================"
echo ""

REQUIRED_PACKAGES=("curl" "wget" "git" "build-essential")

for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii  $pkg"; then
        pass_check "$pkg is installed"
    else
        warn_check "$pkg not installed (can install with: apt-get install $pkg)"
    fi
done
echo ""

echo "======================================================================"
echo "7. PYTHON DEPENDENCIES"
echo "======================================================================"
echo ""

if command -v pip3 &> /dev/null; then
    pass_check "pip3 is available"
    PIP_VERSION=$(pip3 --version)
    echo "  $PIP_VERSION"
else
    fail_check "pip3 not found (required for installing Python packages)"
fi

if python3 -m venv --help &> /dev/null; then
    pass_check "venv module is available"
else
    fail_check "venv module not available (required for virtual environments)"
fi
echo ""

echo "======================================================================"
echo "8. NGINX CHECK"
echo "======================================================================"
echo ""

if command -v nginx &> /dev/null; then
    pass_check "Nginx is installed"
    NGINX_VERSION=$(nginx -v 2>&1 | awk '{print $NF}')
    echo "  Version: $NGINX_VERSION"
else
    warn_check "Nginx not installed (will be installed during deployment)"
fi
echo ""

echo "======================================================================"
echo "9. SSL/CERTBOT CHECK"
echo "======================================================================"
echo ""

if command -v certbot &> /dev/null; then
    pass_check "Certbot is installed"
    CERTBOT_VERSION=$(certbot --version)
    echo "  $CERTBOT_VERSION"
else
    warn_check "Certbot not installed (will be installed during deployment)"
fi
echo ""

echo "======================================================================"
echo "10. SYSTEMD CHECK"
echo "======================================================================"
echo ""

if command -v systemctl &> /dev/null; then
    pass_check "systemd is available"

    if systemctl is-system-running &>/dev/null; then
        SYSTEMD_STATUS=$(systemctl is-system-running)
        pass_check "systemd is running (status: $SYSTEMD_STATUS)"
    else
        warn_check "systemd status check returned non-zero (may still be functional)"
    fi
else
    fail_check "systemd not found (required for service management)"
fi
echo ""

echo "======================================================================"
echo "11. SUDO/ROOT ACCESS"
echo "======================================================================"
echo ""

if sudo -n true 2>/dev/null; then
    pass_check "User can run sudo without password prompt"
elif sudo -v 2>/dev/null; then
    pass_check "User can run sudo (may prompt for password)"
else
    fail_check "User cannot run sudo (required for system configuration)"
fi
echo ""

echo "======================================================================"
echo "12. NETWORK CHECK"
echo "======================================================================"
echo ""

if ping -c 1 8.8.8.8 &> /dev/null; then
    pass_check "Internet connectivity confirmed"
else
    warn_check "Cannot reach 8.8.8.8 (check network connectivity)"
fi

if nslookup google.com &> /dev/null; then
    pass_check "DNS resolution working"
else
    warn_check "DNS resolution failed"
fi
echo ""

echo "======================================================================"
echo "13. DIRECTORY STRUCTURE CHECK"
echo "======================================================================"
echo ""

if [ -d "/var/www" ]; then
    pass_check "/var/www directory exists"
else
    warn_check "/var/www directory does not exist (will be created)"
fi

if id "www-data" &>/dev/null; then
    pass_check "www-data user exists (for Nginx/service)"
else
    warn_check "www-data user does not exist (will be created during setup)"
fi
echo ""

echo "======================================================================"
echo "14. PORTS CHECK"
echo "======================================================================"
echo ""

if netstat -tuln 2>/dev/null | grep -q ":8888 "; then
    warn_check "Port 8888 is already in use"
elif ss -tuln 2>/dev/null | grep -q ":8888 "; then
    warn_check "Port 8888 is already in use"
else
    pass_check "Port 8888 is available"
fi

if netstat -tuln 2>/dev/null | grep -q ":80 "; then
    warn_check "Port 80 is already in use"
elif ss -tuln 2>/dev/null | grep -q ":80 "; then
    warn_check "Port 80 is already in use"
else
    pass_check "Port 80 is available"
fi

if netstat -tuln 2>/dev/null | grep -q ":443 "; then
    warn_check "Port 443 is already in use"
elif ss -tuln 2>/dev/null | grep -q ":443 "; then
    warn_check "Port 443 is already in use"
else
    pass_check "Port 443 is available"
fi
echo ""

echo "======================================================================"
echo "SUMMARY"
echo "======================================================================"
echo ""
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}✓ ALL CHECKS PASSED${NC}"
    echo "VPS is ready for Phase 1 deployment!"
    echo ""
    exit 0
else
    echo -e "${RED}✗ SOME CHECKS FAILED${NC}"
    echo "Please address the failures above before proceeding."
    echo ""
    exit 1
fi
'@

# Write script to temp file
$TempScript = [System.IO.Path]::GetTempFileName()
$PREFLIGHT_SCRIPT | Out-File -FilePath $TempScript -Encoding ASCII -Force

Write-Host "Connecting to VPS..." -ForegroundColor Yellow
Write-Host ""

# SSH and run the script
try {
    # Copy script to VPS
    Write-Host "Uploading pre-flight script to VPS..."
    scp -o StrictHostKeyChecking=no -o BatchMode=no "$TempScript" "${VPS_USER}@${VPS_HOST}:/tmp/preflight.sh" 2>$null

    # Execute script on VPS
    Write-Host "Executing pre-flight checks..."
    Write-Host ""
    Write-Host "======================================================================"
    Write-Host ""

    ssh -o StrictHostKeyChecking=no "${VPS_USER}@${VPS_HOST}" "chmod +x /tmp/preflight.sh && bash /tmp/preflight.sh"

    $ExitCode = $LASTEXITCODE

    Write-Host ""
    Write-Host "======================================================================"

    if ($ExitCode -eq 0) {
        Write-Host "${GREEN}✓ PRE-FLIGHT VERIFICATION PASSED${NC}" -ForegroundColor Green
        Write-Host "VPS is ready for Phase 1 deployment!" -ForegroundColor Green
    } else {
        Write-Host "${RED}✗ PRE-FLIGHT VERIFICATION FAILED${NC}" -ForegroundColor Red
        Write-Host "Please address failures above and try again." -ForegroundColor Red
    }

} catch {
    Write-Host "${RED}Error connecting to VPS: $_${NC}" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting steps:" -ForegroundColor Yellow
    Write-Host "1. Verify SSH is enabled on VPS"
    Write-Host "2. Check VPS IP address is correct: $VPS_HOST"
    Write-Host "3. Verify username/password"
    Write-Host "4. Run manually: ssh ${VPS_USER}@${VPS_HOST}"
} finally {
    # Cleanup
    Remove-Item -Path $TempScript -Force -ErrorAction SilentlyContinue
}
