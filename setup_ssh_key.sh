#!/bin/bash

# Setup SSH Key Authentication for VPS
# This script copies your public SSH key to the VPS

VPS_HOST="140.99.254.83"
VPS_USER="root"
VPS_PASSWORD="Burrawang1968"

echo "======================================================================"
echo "  SSH KEY SETUP FOR VPS"
echo "======================================================================"
echo ""
echo "Target: ${VPS_USER}@${VPS_HOST}"
echo ""

# Check if public key exists
if [ ! -f ~/.ssh/vps_key.pub ]; then
    echo "✗ Error: SSH public key not found at ~/.ssh/vps_key.pub"
    echo "Please generate a key first:"
    echo "  ssh-keygen -t rsa -b 4096 -f ~/.ssh/vps_key -N \"\""
    exit 1
fi

echo "Step 1: Adding VPS to known_hosts..."
ssh-keyscan -t rsa "$VPS_HOST" >> ~/.ssh/known_hosts 2>/dev/null
echo "✓ VPS host key added"
echo ""

echo "Step 2: Copying public key to VPS..."
echo "You will be prompted for the VPS password (Burrawang1968)"
echo ""

# Use ssh-copy-id which handles interactive passwords better
if command -v ssh-copy-id &> /dev/null; then
    # Try with ssh-copy-id
    ssh-copy-id -i ~/.ssh/vps_key.pub "${VPS_USER}@${VPS_HOST}"
else
    # Fallback: manual copy
    echo "ssh-copy-id not available. Using manual method..."

    # Create .ssh directory and authorized_keys on VPS if needed
    ssh "${VPS_USER}@${VPS_HOST}" "mkdir -p ~/.ssh && chmod 700 ~/.ssh"

    # Copy the public key
    cat ~/.ssh/vps_key.pub | ssh "${VPS_USER}@${VPS_HOST}" "cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
fi

echo ""
echo "Step 3: Testing SSH key authentication..."
echo ""

# Test the connection
if ssh -i ~/.ssh/vps_key -o BatchMode=yes "${VPS_USER}@${VPS_HOST}" "echo 'SSH key authentication successful!'" 2>/dev/null; then
    echo "✓ SSH key authentication working!"
    echo ""
    echo "======================================================================"
    echo "✓ SSH KEY SETUP COMPLETE"
    echo "======================================================================"
    echo ""
    echo "You can now use SSH without entering a password:"
    echo "  ssh -i ~/.ssh/vps_key ${VPS_USER}@${VPS_HOST}"
    echo ""
    exit 0
else
    echo "✗ SSH key authentication test failed"
    echo ""
    echo "Troubleshooting:"
    echo "1. Verify password was entered correctly"
    echo "2. Check VPS connectivity: ping $VPS_HOST"
    echo "3. Try manual SSH: ssh ${VPS_USER}@${VPS_HOST}"
    exit 1
fi
