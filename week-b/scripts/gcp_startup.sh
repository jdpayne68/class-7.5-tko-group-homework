#!/bin/bash
set -e
exec > /var/log/bootstrap.log 2>&1
set -x

echo "Bootstrap started at $(date)"

# ------------------------------------------------------------
# Helper: wait for cloud-init (optional)
# ------------------------------------------------------------
if command -v cloud-init >/dev/null 2>&1; then
    echo "INFO: Waiting for cloud-init (max 60s)..."
    timeout 60 cloud-init status --wait || echo "WARN: cloud-init wait skipped"
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
                echo "ERROR: dpkg lock held too long (${max_wait}s)"
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
            echo "INFO: Waiting for lock file... (${waited}s)"
            sleep 5
            waited=$((waited+5))
        done
    fi
}

# ------------------------------------------------------------
# Install git (needed to clone the repo)
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
# Clone repository (shallow clone)
# ------------------------------------------------------------
REPO_DIR="/opt/deploy"
if [ ! -d "$REPO_DIR" ]; then
    echo "INFO: Cloning repository..."
    timeout 120 git clone --depth 1 https://github.com/KirkAlton-Class7/devsecops-vm-dashboard.git "$REPO_DIR"
else
    echo "INFO: Repository exists, pulling updates..."
    cd "$REPO_DIR" && timeout 60 git pull --depth 1
fi

# ------------------------------------------------------------
# Run the main application bootstrap script
# ------------------------------------------------------------
MAIN_SCRIPT="$REPO_DIR/scripts/bootstrap/app_bootstrap.sh"
if [ ! -f "$MAIN_SCRIPT" ]; then
    echo "ERROR: Main script not found at $MAIN_SCRIPT"
    exit 1
fi
chmod +x "$MAIN_SCRIPT"
echo "INFO: Running main application bootstrap..."
timeout 1200 bash -x "$MAIN_SCRIPT"