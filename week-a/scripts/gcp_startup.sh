# GCP Bootstrap Script
# TODO: Try to make dynamic/cloud agnostic

#!/bin/bash
set -e
exec > /var/log/bootstrap.log 2>&1
set -x

echo "Bootstrap started at $(date)"

# ------------------------------------------------------------
# Helper: wait for cloud-init (optional, with timeout)
# ------------------------------------------------------------
if command -v cloud-init >/dev/null 2>&1; then
    echo "INFO: Waiting for cloud-init (max 60s)..."
    timeout 60 cloud-init status --wait || echo "WARN: cloud-init wait skipped (timeout or no status)"
fi

# ------------------------------------------------------------
# Helper: wait for dpkg lock
# ------------------------------------------------------------
wait_for_apt() {
    local max_wait=120
    local waited=0
    if command -v fuser >/dev/null 2>&1; then
        while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
            if [ $waited -ge $max_wait ]; then
                echo "ERROR: dpkg lock held for too long (${max_wait}s)"
                exit 1
            fi
            echo "INFO: Waiting for dpkg lock... (${waited}s)"
            sleep 5
            waited=$((waited+5))
        done
    else
        while [ -f /var/lib/dpkg/lock-frontend ]; do
            if [ $waited -ge $max_wait ]; then
                echo "ERROR: dpkg lock file exists too long (${max_wait}s)"
                exit 1
            fi
            echo "INFO: Waiting for dpkg lock file to disappear... (${waited}s)"
            sleep 5
            waited=$((waited+5))
        done
    fi
}

# ------------------------------------------------------------
# Install git
# ------------------------------------------------------------
if command -v apt-get >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    wait_for_apt
    apt-get update -y -o Acquire::http::Timeout=10 -o Acquire::https::Timeout=10
    wait_for_apt
    apt-get install -y git
elif command -v yum >/dev/null 2>&1; then
    yum install -y git
elif command -v dnf >/dev/null 2>&1; then
    dnf install -y git
else
    echo "ERROR: No known package manager found"
    exit 1
fi

# ------------------------------------------------------------
# Clone repository (or pull updates)
# ------------------------------------------------------------
REPO_DIR="/opt/deploy"
if [ ! -d "$REPO_DIR" ]; then
    echo "INFO: Cloning repository..."
    timeout 120 git clone --depth 1 https://github.com/KirkAlton-Class7/devsecops-vm-dashboard.git "$REPO_DIR"
else
    echo "INFO: Repository exists, pulling updates..."
    cd "$REPO_DIR" && timeout 60 git pull --depth 1
fi

# ---------------------------------------------------------------
# Setup Dashboard API & Monitoring Endpoints Server (port 8080)
# ---------------------------------------------------------------
echo "INFO: Setting up dashboard API and monitoring endpoints server"

# Install Python3 if missing
if ! command -v python3 >/dev/null 2>&1; then
    echo "INFO: Installing Python3..."
    if command -v apt-get >/dev/null 2>&1; then
        wait_for_apt
        apt-get install -y python3
    elif command -v yum >/dev/null 2>&1; then
        yum install -y python3
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y python3
    else
        echo "ERROR: Cannot install Python3 – no package manager found"
        exit 1
    fi
fi

# The dashboard API script is expected at this location (in the repo)
API_SCRIPT="/opt/deploy/scripts/dashboard_api.py"
if [ ! -f "$API_SCRIPT" ]; then
    echo "ERROR: Dashboard API script not found at $API_SCRIPT"
    echo "INFO: Make sure the file exists in your repository at scripts/dashboard_api.py"
    exit 1
fi

chmod +x "$API_SCRIPT"
echo "SUCCESS: Dashboard API script permissions set"

# Create systemd service file
SERVICE_FILE="/etc/systemd/system/dashboard-api.service"
cat > "$SERVICE_FILE" << 'EOF'
[Unit]
Description=Dashboard API & Metadata Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/deploy/scripts
ExecStart=/usr/bin/python3 /opt/deploy/scripts/dashboard_api.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "SUCCESS: Systemd service file created at $SERVICE_FILE"

# Reload systemd, enable and start the service
systemctl daemon-reload
systemctl enable dashboard-api.service
systemctl start dashboard-api.service
sleep 2

# Check status
if systemctl is-active --quiet dashboard-api.service; then
    echo "SUCCESS: Dashboard API server is RUNNING on port 8080"
    echo "INFO: Test locally: curl http://localhost:8080/healthz"
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "unknown")
    if [ "$PUBLIC_IP" != "unknown" ]; then
        echo "INFO: From browser: http://$PUBLIC_IP:8080/healthz"
    fi
else
    echo "ERROR: Dashboard API server failed to start. Check logs:"
    systemctl status dashboard-api.service --no-pager
fi

echo "SUCCESS: Dashboard API server setup complete"

# ------------------------------------------------------------
# Run the main application bootstrap script
# ------------------------------------------------------------
MAIN_SCRIPT="/opt/deploy/scripts/bootstrap/app_bootstrap.sh"
if [ ! -f "$MAIN_SCRIPT" ]; then
    echo "ERROR: Main script not found at $MAIN_SCRIPT"
    exit 1
fi
chmod +x "$MAIN_SCRIPT"
echo "INFO: Running main application bootstrap..."
timeout 1200 bash -x "$MAIN_SCRIPT"