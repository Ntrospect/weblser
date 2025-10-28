# VPS Pre-Flight Verification Guide

**Purpose:** Verify all prerequisites for Phase 1 PDF Maker deployment
**Target Host:** 140.99.254.83
**Expected Time:** 5-10 minutes

---

## Quick Start

### Option 1: Run Script Directly on VPS

```bash
# SSH into the VPS
ssh root@140.99.254.83
# or
ssh your_username@140.99.254.83

# Download the pre-flight script
wget https://raw.githubusercontent.com/Ntrospect/websler/main/PHASE_1_DOCUMENTATION/VPS_PREFLIGHT_CHECKLIST.sh

# Make it executable
chmod +x VPS_PREFLIGHT_CHECKLIST.sh

# Run the checklist
./VPS_PREFLIGHT_CHECKLIST.sh
```

### Option 2: Copy & Paste Commands

If you prefer to run commands individually, copy the relevant sections below.

---

## What the Script Checks

The pre-flight checklist verifies **14 critical areas**:

| # | Check | Required | What It Tests |
|---|-------|----------|---------------|
| 1 | Operating System | ✅ | Ubuntu/Debian Linux |
| 2 | Python Version | ✅ | Python 3.11 or higher |
| 3 | Disk Space | ✅ | 5GB available |
| 4 | Memory | ✅ | 2GB available RAM |
| 5 | Package Manager | ✅ | apt-get access |
| 6 | System Packages | ⚠️ | curl, wget, git, build-essential |
| 7 | Python Tools | ✅ | pip3 and venv |
| 8 | Nginx | ⚠️ | Web server (optional pre-install) |
| 9 | SSL/Certbot | ⚠️ | SSL certificate tool (optional pre-install) |
| 10 | systemd | ✅ | Service management |
| 11 | Sudo Access | ✅ | Root privilege escalation |
| 12 | Network | ✅ | Internet connectivity |
| 13 | Directory Structure | ⚠️ | /var/www exists |
| 14 | Ports | ✅ | 8888, 80, 443 available |

---

## Expected Output

### ✅ ALL CHECKS PASSED

```
======================================================================
SUMMARY
======================================================================

Passed: 14
Failed: 0

✓ ALL CHECKS PASSED
VPS is ready for Phase 1 deployment!
```

**Next Step:** Proceed to Week 1 tasks in PHASE_1_QUICK_START.md

---

### ❌ SOME CHECKS FAILED

```
======================================================================
SUMMARY
======================================================================

Passed: 12
Failed: 2

✗ SOME CHECKS FAILED
Please address the failures above before proceeding.
```

**Common Failures & Fixes:**

**Python Version Too Old**
```bash
# Current version
python3 --version

# If < 3.11, install newer version
sudo apt-get update
sudo apt-get install -y python3.11 python3.11-venv python3.11-dev
```

**Insufficient Disk Space**
```bash
# Check current usage
df -h /

# Clean up old files
sudo apt-get autoremove
sudo apt-get autoclean
```

**Insufficient Memory**
```bash
# Check memory
free -h

# Check if any processes are consuming excessive memory
top -b -n 1 | head -20
```

**apt-get Issues**
```bash
# Fix broken package list
sudo apt-get clean
sudo apt-get update
```

**Port Already In Use**
```bash
# Check what's using port 8888
sudo netstat -tlnp | grep 8888
# or
sudo ss -tlnp | grep 8888

# Kill process if needed (replace PID with actual process ID)
sudo kill -9 PID
```

---

## Manual Verification (Without Script)

If you prefer to run checks individually, use these commands:

### Check OS
```bash
cat /etc/os-release
# Should show Ubuntu or Debian
```

### Check Python Version
```bash
python3 --version
# Should show 3.11.0 or higher
```

### Check Disk Space
```bash
df -h /
# Look at "Avail" column - should be 5GB or more
```

### Check Memory
```bash
free -h
# "available" should be 2GB or more
```

### Check apt-get
```bash
apt-get update
# Should complete without errors
```

### Check Python Tools
```bash
pip3 --version
python3 -m venv --help
# Both should show version info
```

### Check systemd
```bash
systemctl is-system-running
# Should output "running" or similar
```

### Check Internet
```bash
ping -c 1 8.8.8.8
# Should show reply
```

### Check Ports
```bash
# Check port 8888
sudo netstat -tlnp | grep 8888
sudo ss -tlnp | grep 8888

# Check port 80
sudo netstat -tlnp | grep :80
sudo ss -tlnp | grep :80

# Check port 443
sudo netstat -tlnp | grep :443
sudo ss -tlnp | grep :443
```

---

## After Pre-Flight Check

Once all checks pass:

1. ✅ **Mark Pre-Deployment Checklist**
   - Open PHASE_1_QUICK_START.md
   - Mark all pre-flight items as complete

2. ✅ **Proceed to Week 1-2 VPS Deployment**
   - Follow Day 1-2 tasks: Environment Setup
   - Use PHASE_1_QUICK_START.md as your guide

3. ✅ **Document Results**
   - Note any warnings that appeared
   - Screenshot the final summary (optional)
   - Save for reference

---

## Troubleshooting

**Q: Script won't download**
- A: Copy the script content manually and create file on VPS

**Q: Permission denied when running script**
- A: Run `chmod +x VPS_PREFLIGHT_CHECKLIST.sh`

**Q: Some commands require sudo**
- A: Add `sudo` before the command if prompted

**Q: Can't SSH to VPS**
- A: Check IP address (140.99.254.83)
- A: Verify firewall allows port 22
- A: Check SSH credentials

**Q: Script output not clear**
- A: Run with `bash VPS_PREFLIGHT_CHECKLIST.sh 2>&1 | tee preflight_results.txt`
- A: This saves output to file for later review

---

## Quick Reference

**Script Location:** `PHASE_1_DOCUMENTATION/VPS_PREFLIGHT_CHECKLIST.sh`

**Host:** 140.99.254.83

**Minimum Requirements:**
- Ubuntu 18.04+ or Debian 10+
- Python 3.11+
- 5GB disk space
- 2GB RAM
- Internet connectivity
- Sudo/root access

**Time to Complete:** 5-10 minutes

---

**Next Document to Read:**
- PHASE_1_QUICK_START.md (after pre-flight passes)

