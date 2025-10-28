#!/bin/bash

# WebAudit Pro + Weblser Backend Deployment Script
# Deploy to VPS: 140.99.254.83:8000
# Usage: bash deploy_to_vps.sh <VPS_IP>

set -e

VPS_IP="${1:-140.99.254.83}"
VPS_USER="root"
DEPLOY_DIR="/home/weblser"

echo "🚀 Starting deployment to VPS: $VPS_IP"
echo "=================================================="

# Step 1: Create deployment package
echo "📦 Creating deployment package..."
mkdir -p deployment_pkg
cd deployment_pkg

# Copy backend files
cp ../fastapi_server.py .
cp ../analyzer.py .
cp ../audit_engine.py .
cp ../report_generator.py .
cp ../backend_requirements.txt requirements.txt

# Create deployment script for VPS
cat > deploy.sh << 'VPSEOF'
#!/bin/bash
set -e

echo "Starting VPS deployment..."

# Navigate to working directory
cd /home/weblser

# Activate virtual environment
source venv/bin/activate

# Install/upgrade dependencies
echo "Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Restart the service
echo "Restarting weblser service..."
sudo systemctl restart weblser
sudo systemctl status weblser

echo "✅ Deployment complete!"
echo "Backend running at: http://140.99.254.83:8000"
VPSEOF

chmod +x deploy.sh

# Step 2: Upload files to VPS
echo "📤 Uploading files to VPS..."
scp -r ./* "${VPS_USER}@${VPS_IP}:${DEPLOY_DIR}/"

# Step 3: Run deployment on VPS
echo "🔧 Running deployment on VPS..."
ssh "${VPS_USER}@${VPS_IP}" "cd ${DEPLOY_DIR} && bash deploy.sh"

# Cleanup
cd ..
rm -rf deployment_pkg

echo ""
echo "✅ Deployment successful!"
echo "=================================================="
echo "Backend is now running at: http://${VPS_IP}:8000"
echo ""
echo "Test endpoints:"
echo "  Audit endpoint: curl http://${VPS_IP}:8000/api/audit/analyze -X POST"
echo "  Health check: curl http://${VPS_IP}:8000/docs"
