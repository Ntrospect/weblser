#!/bin/bash

# VPS Pre-Flight Verification Script (Bash)
# Purpose: Run pre-flight checklist on VPS via SSH
# Usage: bash run_vps_preflight.sh

VPS_HOST="140.99.254.83"
VPS_USER="root"

# Note: This script requires SSH key-based auth or interactive password entry
# If you're prompted for a password, enter: Burrawang1968

echo "======================================================================"
echo "  VPS PRE-FLIGHT VERIFICATION"
echo "  Connecting to $VPS_HOST..."
echo "======================================================================"
echo ""

# Check if we can connect
echo "Testing SSH connection..."
if ! ssh-keyscan -t rsa "$VPS_HOST" > /dev/null 2>&1; then
    echo "✗ Cannot reach VPS at $VPS_HOST"
    echo ""
    echo "Please verify:"
    echo "1. VPS IP address is correct"
    echo "2. VPS is running"
    echo "3. SSH port 22 is open"
    exit 1
fi

echo "✓ VPS is reachable"
echo ""
echo "Downloading and executing pre-flight checks..."
echo ""

# Run the pre-flight script from GitHub
ssh -o StrictHostKeyChecking=accept-new "$VPS_USER@$VPS_HOST" 'bash -s' << 'EOF'
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

# 1. Operating System
echo "======================================================================"
echo "1. OPERATING SYSTEM CHECK"
echo "======================================================================"
echo ""

if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "OS: $NAME $VERSION_ID"
    if [[ "$NAME" == *"Ubuntu"* ]] || [[ "$NAME" == *"Debian"* ]]; then
        pass_check "Ubuntu/Debian detected"
    else
        fail_check "OS is not Ubuntu/Debian"
    fi
else
    fail_check "Cannot determine OS"
fi
echo ""

# 2. Python Version
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
        pass_check "Python 3.11+ installed"
    else
        fail_check "Python version too old: $PYTHON_VERSION (need 3.11+)"
    fi
else
    fail_check "Python 3 not found"
fi
echo ""

# 3. Disk Space
echo "======================================================================"
echo "3. DISK SPACE CHECK"
echo "======================================================================"
echo ""

DISK_AVAILABLE=$(df -B1 / | awk 'NR==2 {print $4}')
DISK_AVAILABLE_GB=$((DISK_AVAILABLE / 1024 / 1024 / 1024))
echo "Available disk space: ${DISK_AVAILABLE_GB}GB"

if [ "$DISK_AVAILABLE_GB" -ge 5 ]; then
    pass_check "Sufficient disk space (need 5GB)"
else
    fail_check "Insufficient disk space (need 5GB, have ${DISK_AVAILABLE_GB}GB)"
fi
echo ""

# 4. Memory
echo "======================================================================"
echo "4. MEMORY CHECK"
echo "======================================================================"
echo ""

MEMORY_AVAILABLE=$(free -B1 | awk 'NR==2 {print $7}')
MEMORY_AVAILABLE_GB=$((MEMORY_AVAILABLE / 1024 / 1024 / 1024))
echo "Available memory: ${MEMORY_AVAILABLE_GB}GB+"

if [ "$MEMORY_AVAILABLE_GB" -ge 2 ]; then
    pass_check "Sufficient memory available"
else
    fail_check "Insufficient memory (need 2GB)"
fi
echo ""

# 5. Package Manager
echo "======================================================================"
echo "5. PACKAGE MANAGER CHECK"
echo "======================================================================"
echo ""

if command -v apt-get &> /dev/null; then
    pass_check "apt-get is available"
else
    fail_check "apt-get not found"
fi
echo ""

# 6. System Packages
echo "======================================================================"
echo "6. REQUIRED SYSTEM PACKAGES"
echo "======================================================================"
echo ""

for pkg in curl wget git build-essential; do
    if dpkg -l 2>/dev/null | grep -q "^ii  $pkg"; then
        pass_check "$pkg installed"
    else
        warn_check "$pkg not installed"
    fi
done
echo ""

# 7. Python Tools
echo "======================================================================"
echo "7. PYTHON DEPENDENCIES"
echo "======================================================================"
echo ""

if command -v pip3 &> /dev/null; then
    pass_check "pip3 available"
else
    fail_check "pip3 not found"
fi

if python3 -m venv --help &> /dev/null; then
    pass_check "venv module available"
else
    fail_check "venv module not available"
fi
echo ""

# 8. Nginx
echo "======================================================================"
echo "8. NGINX CHECK"
echo "======================================================================"
echo ""

if command -v nginx &> /dev/null; then
    pass_check "Nginx installed"
else
    warn_check "Nginx not installed (will be installed)"
fi
echo ""

# 9. Certbot
echo "======================================================================"
echo "9. SSL/CERTBOT CHECK"
echo "======================================================================"
echo ""

if command -v certbot &> /dev/null; then
    pass_check "Certbot installed"
else
    warn_check "Certbot not installed (will be installed)"
fi
echo ""

# 10. Systemd
echo "======================================================================"
echo "10. SYSTEMD CHECK"
echo "======================================================================"
echo ""

if command -v systemctl &> /dev/null; then
    pass_check "systemd available"
else
    fail_check "systemd not found"
fi
echo ""

# 11. Root Access
echo "======================================================================"
echo "11. ROOT/SUDO ACCESS"
echo "======================================================================"
echo ""

if [ "$(id -u)" -eq 0 ]; then
    pass_check "Running as root"
else
    warn_check "Not running as root"
fi
echo ""

# 12. Network
echo "======================================================================"
echo "12. NETWORK CHECK"
echo "======================================================================"
echo ""

if ping -c 1 8.8.8.8 &> /dev/null; then
    pass_check "Internet connectivity confirmed"
else
    warn_check "Cannot reach 8.8.8.8"
fi

if nslookup google.com &> /dev/null 2>&1; then
    pass_check "DNS resolution working"
else
    warn_check "DNS resolution failed"
fi
echo ""

# 13. Directories
echo "======================================================================"
echo "13. DIRECTORY STRUCTURE"
echo "======================================================================"
echo ""

if [ -d "/var/www" ]; then
    pass_check "/var/www exists"
else
    warn_check "/var/www does not exist"
fi

if id "www-data" &>/dev/null; then
    pass_check "www-data user exists"
else
    warn_check "www-data user does not exist"
fi
echo ""

# 14. Ports
echo "======================================================================"
echo "14. PORTS CHECK"
echo "======================================================================"
echo ""

for PORT in 8888 80 443; do
    if netstat -tuln 2>/dev/null | grep -q ":$PORT " || ss -tuln 2>/dev/null | grep -q ":$PORT "; then
        warn_check "Port $PORT is in use"
    else
        pass_check "Port $PORT is available"
    fi
done
echo ""

# Summary
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
    exit 0
else
    echo -e "${RED}✗ SOME CHECKS FAILED${NC}"
    echo "Please address the failures before proceeding."
    exit 1
fi
EOF

echo ""
echo "======================================================================"
echo "Pre-flight check complete!"
echo "======================================================================"
