#!/bin/bash
set -euo pipefail

# ----------------------------------------------------------------------
# VM Dashboard / Super B 2 - Startup Script
# Basic GCE startup-script deployment: nginx + static HTML + metadata JSON.
# ----------------------------------------------------------------------

sleep 10

export DEBIAN_FRONTEND=noninteractive

safe_apt() {
  local cmd="$1"
  local max_retries=15
  local retry=0
  local status=0

  while [ "$retry" -lt "$max_retries" ]; do
    set +e
    eval "$cmd"
    status=$?
    set -e

    if [ "$status" -eq 0 ]; then
      return 0
    fi

    if [ "$status" -eq 100 ]; then
      echo "apt/dpkg not ready, waiting 3 seconds... (attempt $((retry + 1))/$max_retries)"
      sleep 3
      retry=$((retry + 1))
    else
      echo "apt command failed with status $status: $cmd"
      return "$status"
    fi
  done

  echo "Failed to complete apt command after $max_retries attempts: $cmd"
  return 1
}

safe_apt "apt-get update -y"
safe_apt "apt-get install -y nginx curl jq ca-certificates"

# ----------------------------------------------------------------------
# Metadata helpers (GCE)
# ----------------------------------------------------------------------
METADATA="http://metadata.google.internal/computeMetadata/v1"
HDR="Metadata-Flavor: Google"

md() {
  curl -fsS -H "$HDR" "${METADATA}/$1" 2>/dev/null || echo "unknown"
}

json_string() {
  jq -Rn --arg value "$1" '$value'
}

percent() {
  awk -v used="${1:-0}" -v total="${2:-0}" 'BEGIN { if (total > 0) printf "%d", (used / total) * 100 + 0.5; else printf "0" }'
}

status_for_percent() {
  local value="${1:-0}"
  if [ "$value" -ge 90 ] 2>/dev/null; then
    echo "critical"
  elif [ "$value" -ge 70 ] 2>/dev/null; then
    echo "warning"
  else
    echo "healthy"
  fi
}

# ----------------------------------------------------------------------
# Gather VM metadata
# ----------------------------------------------------------------------
INSTANCE_NAME="$(md instance/name)"
INSTANCE_ID="$(md instance/id)"
HOSTNAME_VALUE="$(hostname)"
PROJECT_ID="$(md project/project-id)"
ZONE_FULL="$(md instance/zone)"
ZONE="${ZONE_FULL##*/}"
REGION="${ZONE%-*}"
MACHINE_TYPE_FULL="$(md instance/machine-type)"
MACHINE_TYPE="${MACHINE_TYPE_FULL##*/}"
SERVICE_ACCOUNT="$(md instance/service-accounts/default/email)"

INTERNAL_IP="$(md instance/network-interfaces/0/ip)"
EXTERNAL_IP="$(md instance/network-interfaces/0/access-configs/0/external-ip)"
VPC_FULL="$(md instance/network-interfaces/0/network)"
SUBNET_FULL="$(md instance/network-interfaces/0/subnetwork)"
VPC="${VPC_FULL##*/}"
SUBNET="${SUBNET_FULL##*/}"

START_TIME_UTC="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
STUDENT_NAME="$(md instance/attributes/student_name)"
if [[ -z "$STUDENT_NAME" || "$STUDENT_NAME" == "unknown" ]]; then
  STUDENT_NAME="Anonymous Padawan"
fi

# Metadata: app_name (replaces old "headline") and tagline
APP_NAME="$(md instance/attributes/app_name)"
if [[ -z "$APP_NAME" || "$APP_NAME" == "unknown" ]]; then
  APP_NAME="VM Dashboard - Starter"
fi

TAGLINE="$(md instance/attributes/tagline)"
if [[ -z "$TAGLINE" || "$TAGLINE" == "unknown" ]]; then
  TAGLINE="GCP deployment"
fi

OS_PRETTY="$(. /etc/os-release 2>/dev/null && echo "${PRETTY_NAME:-unknown}" || echo "unknown")"

# ----- UPTIME FIX (human-readable from /proc/uptime) -----
if [[ -r /proc/uptime ]]; then
  UPTIME_SEC=$(awk '{print int($1)}' /proc/uptime)
  UPTIME_DAYS=$((UPTIME_SEC / 86400))
  UPTIME_HOURS=$(( (UPTIME_SEC % 86400) / 3600 ))
  UPTIME_MINS=$(( (UPTIME_SEC % 3600) / 60 ))
  if [[ $UPTIME_DAYS -gt 0 ]]; then
    UPTIME_HUMAN="${UPTIME_DAYS} day(s), ${UPTIME_HOURS} hour(s), ${UPTIME_MINS} minute(s)"
  elif [[ $UPTIME_HOURS -gt 0 ]]; then
    UPTIME_HUMAN="${UPTIME_HOURS} hour(s), ${UPTIME_MINS} minute(s)"
  else
    UPTIME_HUMAN="${UPTIME_MINS} minute(s)"
  fi
else
  UPTIME_HUMAN="unknown"
fi
# ---------------------------------------------------------

LOADAVG="$(awk '{print $1" "$2" "$3}' /proc/loadavg 2>/dev/null || echo "unknown")"
LOAD_1M="$(awk '{print $1}' /proc/loadavg 2>/dev/null || echo "0")"
CPU_CORES="$(nproc 2>/dev/null || echo "1")"

MEM_TOTAL_MB="$(awk '/MemTotal:/ {printf "%d", $2 / 1024}' /proc/meminfo 2>/dev/null || echo "0")"
MEM_AVAILABLE_MB="$(awk '/MemAvailable:/ {printf "%d", $2 / 1024}' /proc/meminfo 2>/dev/null || echo "0")"
MEM_USED_MB=$((MEM_TOTAL_MB - MEM_AVAILABLE_MB))
if [ "$MEM_USED_MB" -lt 0 ] 2>/dev/null; then
  MEM_USED_MB=0
fi
MEM_USEP="$(percent "$MEM_USED_MB" "$MEM_TOTAL_MB")"
MEM_STATUS="$(status_for_percent "$MEM_USEP")"

DISK_LINE="$(df -Pm / | tail -n 1)"
DISK_TOTAL_MB="$(echo "$DISK_LINE" | awk '{print $2}')"
DISK_USED_MB="$(echo "$DISK_LINE" | awk '{print $3}')"
DISK_AVAILABLE_MB="$(echo "$DISK_LINE" | awk '{print $4}')"
DISK_USEP="$(echo "$DISK_LINE" | awk '{print $5}' | tr -d '%')"
DISK_STATUS="$(status_for_percent "$DISK_USEP")"

OVERALL_STATUS="healthy"
if [[ "$MEM_STATUS" == "critical" || "$DISK_STATUS" == "critical" ]]; then
  OVERALL_STATUS="critical"
elif [[ "$MEM_STATUS" == "warning" || "$DISK_STATUS" == "warning" ]]; then
  OVERALL_STATUS="warning"
fi

# ----------------------------------------------------------------------
# Write Nginx configuration
# ----------------------------------------------------------------------
mkdir -p /var/www/html

cat > /etc/nginx/sites-available/default <<'NGINX'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;
    root /var/www/html;
    index index.html;

    location = /healthz {
        default_type text/plain;
        return 200 "ok\n";
    }

    location = /metadata {
        default_type application/json;
        try_files /metadata.json =404;
    }

    location = /api/dashboard {
        default_type application/json;
        try_files /metadata.json =404;
    }

    location = /api/dashboard/summary {
        default_type application/json;
        try_files /metadata.json =404;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
NGINX

ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# ----------------------------------------------------------------------
# Write metadata.json with live data
# ----------------------------------------------------------------------
cat > /var/www/html/metadata.json <<EOF
{
  "service": "vm-dashboard",
  "variant": "devsecops",
  "student_name": $(json_string "$STUDENT_NAME"),
  "app_name": $(json_string "$APP_NAME"),
  "tagline": $(json_string "$TAGLINE"),
  "project_id": $(json_string "$PROJECT_ID"),
  "instance_id": $(json_string "$INSTANCE_ID"),
  "instance_name": $(json_string "$INSTANCE_NAME"),
  "hostname": $(json_string "$HOSTNAME_VALUE"),
  "machine_type": $(json_string "$MACHINE_TYPE"),
  "service_account": $(json_string "$SERVICE_ACCOUNT"),
  "os": $(json_string "$OS_PRETTY"),
  "region": $(json_string "$REGION"),
  "zone": $(json_string "$ZONE"),
  "network": {
    "vpc": $(json_string "$VPC"),
    "subnet": $(json_string "$SUBNET"),
    "internal_ip": $(json_string "$INTERNAL_IP"),
    "external_ip": $(json_string "$EXTERNAL_IP")
  },
  "health": {
    "status": $(json_string "$OVERALL_STATUS"),
    "uptime": $(json_string "$UPTIME_HUMAN"),
    "load_avg": $(json_string "$LOADAVG"),
    "load_1m": $(json_string "$LOAD_1M"),
    "cpu_cores": $CPU_CORES,
    "ram_mb": {
      "used": $MEM_USED_MB,
      "available": $MEM_AVAILABLE_MB,
      "total": $MEM_TOTAL_MB,
      "use_pct": $MEM_USEP,
      "status": $(json_string "$MEM_STATUS")
    },
    "disk_root_mb": {
      "used": $DISK_USED_MB,
      "available": $DISK_AVAILABLE_MB,
      "total": $DISK_TOTAL_MB,
      "use_pct": $DISK_USEP,
      "status": $(json_string "$DISK_STATUS")
    }
  },
  "services": [
    {"name": "nginx", "status": "healthy", "detail": "serving static dashboard on port 80"},
    {"name": "metadata", "status": "healthy", "detail": "read from GCE metadata server"},
    {"name": "healthz", "status": "healthy", "detail": "plain text readiness endpoint"}
  ],
  "endpoints": [
    {"name": "Health", "path": "/healthz"},
    {"name": "Metadata", "path": "/metadata"},
    {"name": "Dashboard API", "path": "/api/dashboard"}
  ],
  "startup_utc": $(json_string "$START_TIME_UTC")
}
EOF

# ----------------------------------------------------------------------
# Write index.html – glossy reflection removed, only shimmer line remains
# ----------------------------------------------------------------------
cat > /var/www/html/index.html <<'HTML_EOF'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta http-equiv="refresh" content="30">
  <title>VM Dashboard</title>
  <style>
    :root {
      color-scheme: dark;
      --slate-950: #020617;
      --slate-900: #0f172a;
      --slate-800: #1e293b;
      --slate-700: #334155;
      --slate-500: #64748b;
      --slate-400: #94a3b8;
      --slate-300: #cbd5e1;
      --slate-100: #f1f5f9;
      --cyan: #22d3ee;
      --purple: #a855f7;
      --pink: #ec4899;
      --emerald: #34d399;
      --amber: #f59e0b;
      --red: #ef4444;
      --border: rgba(255, 255, 255, 0.10);
      --radius: 16px;
    }

    * { box-sizing: border-box; }

    html {
      scroll-behavior: auto;
      scrollbar-gutter: stable;
    }

    body {
      margin: 0;
      min-height: 100vh;
      overflow-x: hidden;
      background:
        radial-gradient(circle at 16% 0%, rgba(34, 211, 238, 0.18), transparent 27rem),
        radial-gradient(circle at 85% 8%, rgba(168, 85, 247, 0.16), transparent 30rem),
        linear-gradient(135deg, var(--slate-950) 0%, var(--slate-900) 52%, #11103a 100%);
      color: var(--slate-100);
      font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      -webkit-font-smoothing: antialiased;
      letter-spacing: 0;
    }

    a { color: inherit; text-decoration: none; }
    button { border: 0; color: inherit; font: inherit; cursor: pointer; }
    ::selection { background: rgba(34, 211, 238, 0.30); color: white; }

    @keyframes slideIn {
      from { opacity: 0; transform: translateY(18px); }
      to { opacity: 1; transform: translateY(0); }
    }

    @keyframes shimmer {
      from { transform: translateX(-100%); }
      to { transform: translateX(100%); }
    }

    @keyframes pulseRing {
      from { transform: scale(0.82); opacity: 0.8; }
      to { transform: scale(1.75); opacity: 0; }
    }

    .app-shell {
      min-height: 100vh;
      padding-left: 0;
    }

    /* Student name - blue left, then purple, then cyan */
    .student-name {
      margin: 0;
      font-size: 1.5rem;
      font-weight: 800;
      letter-spacing: 0.20em;
      text-transform: uppercase;
      background: linear-gradient(90deg, #3b82f6, #a855f7, #22d3ee);
      -webkit-background-clip: text;
      background-clip: text;
      color: transparent;
      overflow-wrap: anywhere;
    }

    /* App name - cyan → purple */
    .app-name {
      margin: 0.25rem 0 0;
      font-size: 0.9rem;
      font-weight: 800;
      letter-spacing: 0.20em;
      text-transform: uppercase;
      background: linear-gradient(90deg, var(--cyan), var(--purple));
      -webkit-background-clip: text;
      background-clip: text;
      color: transparent;
      opacity: 0.9;
    }

    .icon {
      display: inline-grid;
      place-items: center;
      width: 1.25rem;
      height: 1.25rem;
      flex: 0 0 1.25rem;
      color: currentColor;
    }

    .icon svg {
      width: 1.1rem;
      height: 1.1rem;
      stroke: currentColor;
      stroke-width: 2;
      fill: none;
      stroke-linecap: round;
      stroke-linejoin: round;
    }

    .main {
      min-width: 0;
    }

    .topbar {
      position: sticky;
      top: 0;
      z-index: 20;
      overflow: hidden;
      border-bottom: 1px solid var(--border);
      background: rgba(2, 6, 23, 0.95);
      box-shadow: 0 14px 30px rgba(0, 0, 0, 0.22);
      backdrop-filter: blur(14px);
    }

    .topbar::before {
      content: "";
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 2px;
      background: linear-gradient(90deg, transparent, var(--cyan), var(--purple), var(--pink), transparent);
      transform: translateX(-100%);
    }

    .topbar.shimmer::before {
      animation: shimmer 1.25s linear forwards;
    }

    .topbar-inner {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 1rem;
      padding: 0.85rem 1.25rem;
    }

    .header-copy {
      min-width: 0;
    }

    .header-copy p {
      margin: 0;
    }

    .tagline {
      margin-top: 0.28rem;
      color: var(--slate-400);
      font-size: 0.78rem;
    }

    .top-actions {
      display: flex;
      align-items: center;
      justify-content: flex-end;
      flex-wrap: wrap;
      gap: 0.6rem;
    }

    .pill {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 0.45rem;
      min-height: 2.1rem;
      padding: 0 0.75rem;
      border: 1px solid var(--border);
      border-radius: 999px;
      background: rgba(255, 255, 255, 0.055);
      color: var(--slate-300);
      font-size: 0.78rem;
      font-weight: 700;
      white-space: nowrap;
      transition: transform 160ms ease, border-color 160ms ease, background 160ms ease, color 160ms ease;
    }

    .pill:hover {
      transform: translateY(-1px);
      border-color: rgba(34, 211, 238, 0.46);
      background: rgba(34, 211, 238, 0.12);
      color: #e0faff;
    }

    .pill.uptime {
      border-color: rgba(52, 211, 153, 0.32);
      background: linear-gradient(90deg, rgba(52, 211, 153, 0.10), rgba(34, 211, 238, 0.10));
    }

    .content {
      display: grid;
      gap: 1rem;
      padding: 1rem 1.25rem;
    }

    .summary {
      display: grid;
      grid-template-columns: repeat(4, minmax(0, 1fr));
      gap: 0.85rem;
    }

    .stat-card,
    .panel {
      position: relative;
      overflow: hidden;
      border: 1px solid var(--border);
      border-radius: var(--radius);
      background: linear-gradient(135deg, rgba(15, 23, 42, 0.86), rgba(2, 6, 23, 0.84));
      box-shadow: 0 25px 60px rgba(0, 0, 0, 0.22);
      animation: slideIn 420ms ease both;
    }

    .stat-card::before,
    .panel::before {
      content: "";
      position: absolute;
      inset: 0;
      opacity: 0;
      background: linear-gradient(90deg, transparent, rgba(34, 211, 238, 0.08), rgba(168, 85, 247, 0.06), transparent);
      transition: opacity 220ms ease;
      pointer-events: none;
    }

    .stat-card:hover,
    .panel:hover {
      transform: translateY(-2px);
      border-color: rgba(34, 211, 238, 0.22);
      transition: transform 200ms ease, border-color 200ms ease;
    }

    .stat-card:hover::before,
    .panel:hover::before {
      opacity: 1;
    }

    .stat-card {
      min-height: 7.25rem;
      padding: 0.95rem;
    }

    .stat-top {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 1rem;
      min-width: 0;
    }

    .stat-icon {
      display: grid;
      place-items: center;
      width: 2.5rem;
      height: 2.5rem;
      flex: 0 0 2.5rem;
      border-radius: 14px;
      border: 1px solid rgba(255, 255, 255, 0.09);
      background: linear-gradient(135deg, rgba(52, 211, 153, 0.16), rgba(34, 211, 238, 0.16));
      color: var(--emerald);
    }

    .stat-card.warning .stat-icon {
      background: linear-gradient(135deg, rgba(245, 158, 11, 0.18), rgba(251, 146, 60, 0.16));
      color: var(--amber);
    }

    .stat-card.critical .stat-icon {
      background: linear-gradient(135deg, rgba(239, 68, 68, 0.20), rgba(244, 63, 94, 0.16));
      color: var(--red);
    }

    .status-pill {
      padding: 0.28rem 0.55rem;
      border-radius: 999px;
      background: rgba(52, 211, 153, 0.10);
      color: var(--emerald);
      font-size: 0.68rem;
      font-weight: 900;
      letter-spacing: 0.06em;
      text-transform: uppercase;
    }

    .warning .status-pill { background: rgba(245, 158, 11, 0.18); color: #fbbf24; }
    .critical .status-pill { background: rgba(239, 68, 68, 0.18); color: #fca5a5; }

    .stat-label {
      margin: 0.72rem 0 0;
      color: var(--slate-400);
      font-size: 0.84rem;
      font-weight: 700;
    }

    .stat-value {
      margin-top: 0.35rem;
      color: white;
      font-size: 1.55rem;
      font-weight: 850;
      line-height: 1;
      overflow-wrap: anywhere;
    }

    .stat-detail {
      margin-top: 0.55rem;
      color: var(--slate-400);
      font-size: 0.78rem;
      line-height: 1.45;
      overflow-wrap: anywhere;
    }

    .section-grid {
      display: grid;
      grid-template-columns: repeat(3, minmax(0, 1fr));
      gap: 1rem;
    }

    .panel-header {
      position: relative;
      padding: 0.85rem 1rem;
      border-bottom: 1px solid var(--border);
    }

    .panel-title {
      margin: 0;
      font-size: 0.92rem;
      font-weight: 800;
      background: linear-gradient(90deg, var(--slate-100), var(--slate-300));
      -webkit-background-clip: text;
      background-clip: text;
      color: transparent;
    }

    .panel-subtitle {
      margin: 0.2rem 0 0;
      color: var(--slate-400);
      font-size: 0.76rem;
      line-height: 1.4;
    }

    .panel-body {
      position: relative;
      padding: 1rem;
    }

    .kv {
      display: grid;
      gap: 0.65rem;
    }

    .row {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 1rem;
      min-width: 0;
      padding-bottom: 0.65rem;
      border-bottom: 1px solid rgba(255, 255, 255, 0.08);
    }

    .row:last-child {
      padding-bottom: 0;
      border-bottom: 0;
    }

    .key {
      min-width: max-content;
      color: var(--slate-400);
      font-size: 0.82rem;
    }

    .value {
      min-width: 0;
      color: var(--slate-100);
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace;
      font-size: 0.82rem;
      text-align: right;
      overflow-wrap: anywhere;
    }

    .endpoint-grid {
      display: grid;
      grid-template-columns: repeat(3, minmax(0, 1fr));
      gap: 0.75rem;
    }

    .endpoint {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 1rem;
      min-height: 2.85rem;
      padding: 0.75rem;
      border: 1px solid rgba(255, 255, 255, 0.09);
      border-radius: 12px;
      background: rgba(255, 255, 255, 0.035);
      transition: border-color 160ms ease, background 160ms ease;
    }

    .endpoint:hover {
      border-color: rgba(34, 211, 238, 0.28);
      background: rgba(34, 211, 238, 0.07);
    }

    .endpoint strong {
      display: inline-flex;
      align-items: center;
      gap: 0.48rem;
      min-width: max-content;
      color: var(--slate-200);
      font-size: 0.86rem;
    }

    .endpoint span {
      min-width: 0;
      color: var(--slate-400);
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace;
      font-size: 0.78rem;
      text-align: right;
      overflow-wrap: anywhere;
    }

    .dot-wrap {
      position: relative;
      display: inline-grid;
      place-items: center;
      width: 0.75rem;
      height: 0.75rem;
      flex: 0 0 0.75rem;
    }

    .dot-wrap::before {
      content: "";
      position: absolute;
      inset: 0;
      border-radius: 999px;
      background: rgba(52, 211, 153, 0.28);
      animation: pulseRing 1.8s ease-out infinite;
    }

    .dot {
      position: relative;
      width: 0.55rem;
      height: 0.55rem;
      border-radius: 999px;
      background: var(--emerald);
    }

    .warning .dot { background: var(--amber); }
    .warning .dot-wrap::before { background: rgba(245, 158, 11, 0.24); }
    .critical .dot { background: var(--red); }
    .critical .dot-wrap::before { background: rgba(239, 68, 68, 0.24); }

    .toast {
      position: fixed;
      left: 50%;
      bottom: 1.2rem;
      z-index: 60;
      transform: translateX(-50%) translateY(150%);
      padding: 0.78rem 1rem;
      border: 1px solid rgba(34, 211, 238, 0.34);
      border-radius: 12px;
      background: rgba(2, 6, 23, 0.96);
      color: #e0faff;
      font-size: 0.85rem;
      transition: transform 180ms ease;
      box-shadow: 0 25px 60px rgba(0, 0, 0, 0.34);
    }

    .toast.show {
      transform: translateX(-50%) translateY(0);
    }

    @media (max-width: 1180px) {
      .summary { grid-template-columns: repeat(2, minmax(0, 1fr)); }
      .section-grid { grid-template-columns: 1fr; }
      .endpoint-grid { grid-template-columns: 1fr; }
    }

    @media (max-width: 720px) {
      .topbar-inner { align-items: flex-start; flex-direction: column; padding: 0.9rem; }
      .top-actions { justify-content: flex-start; }
      .content { padding: 0.9rem; gap: 0.9rem; }
      .summary { grid-template-columns: 1fr; }
      .row,
      .endpoint { align-items: flex-start; flex-direction: column; }
      .value,
      .endpoint span { text-align: left; }
    }
  </style>
</head>
<body>
  <svg width="0" height="0" style="position:absolute" aria-hidden="true" focusable="false">
    <symbol id="i-dashboard" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="8" rx="1"/><rect x="14" y="3" width="7" height="5" rx="1"/><rect x="14" y="12" width="7" height="9" rx="1"/><rect x="3" y="15" width="7" height="6" rx="1"/></symbol>
    <symbol id="i-server" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="7" rx="2"/><rect x="3" y="13" width="18" height="7" rx="2"/><path d="M7 8h.01M7 17h.01"/></symbol>
    <symbol id="i-network" viewBox="0 0 24 24"><circle cx="12" cy="5" r="2"/><circle cx="5" cy="19" r="2"/><circle cx="19" cy="19" r="2"/><path d="M12 7v4M12 11l-6 6M12 11l6 6"/></symbol>
    <symbol id="i-location" viewBox="0 0 24 24"><path d="M12 21s7-5.2 7-12a7 7 0 1 0-14 0c0 6.8 7 12 7 12Z"/><circle cx="12" cy="9" r="2.5"/></symbol>
    <symbol id="i-cpu" viewBox="0 0 24 24"><rect x="7" y="7" width="10" height="10" rx="2"/><path d="M9 1v4M15 1v4M9 19v4M15 19v4M1 9h4M1 15h4M19 9h4M19 15h4"/></symbol>
    <symbol id="i-link" viewBox="0 0 24 24"><path d="M10 13a5 5 0 0 0 7.1 0l2-2a5 5 0 0 0-7.1-7.1l-1.1 1.1"/><path d="M14 11a5 5 0 0 0-7.1 0l-2 2A5 5 0 0 0 12 20.1l1.1-1.1"/></symbol>
    <symbol id="i-activity" viewBox="0 0 24 24"><path d="M22 12h-4l-3 8L9 4l-3 8H2"/></symbol>
    <symbol id="i-copy" viewBox="0 0 24 24"><rect x="9" y="9" width="12" height="12" rx="2"/><rect x="3" y="3" width="12" height="12" rx="2"/></symbol>
    <symbol id="i-clock" viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></symbol>
  </svg>

  <div class="app-shell">
    <main class="main">
      <header class="topbar" id="topbar">
        <div class="topbar-inner">
          <div class="header-copy">
            <p class="student-name" id="studentNameDisplay"></p>
            <p class="app-name" id="appNameDisplay"></p>
            <p class="tagline" id="taglineText"></p>
          </div>
          <div class="top-actions">
            <span class="pill uptime" id="uptimePill"><span class="icon"><svg><use href="#i-clock"></use></svg></span>Uptime</span>
            <button class="pill" id="copySnapshot" type="button"><span class="icon"><svg><use href="#i-copy"></use></svg></span>Snapshot</button>
            <button class="pill" id="copyJson" type="button"><span class="icon"><svg><use href="#i-copy"></use></svg></span>JSON</button>
          </div>
        </div>
      </header>

      <section class="content">
        <section class="summary" id="overview" aria-label="Overview cards"></section>

        <section class="section-grid" id="vm-information">
          <article class="panel">
            <div class="panel-header">
              <h2 class="panel-title">Identity</h2>
              <p class="panel-subtitle">Project, instance, and host details</p>
            </div>
            <div class="panel-body kv" id="identityRows"></div>
          </article>

          <article class="panel" id="network">
            <div class="panel-header">
              <h2 class="panel-title">Network</h2>
              <p class="panel-subtitle">VPC, subnet, and assigned addresses</p>
            </div>
            <div class="panel-body kv" id="networkRows"></div>
          </article>

          <article class="panel" id="location">
            <div class="panel-header">
              <h2 class="panel-title">Location</h2>
              <p class="panel-subtitle">Region, zone, startup, and load</p>
            </div>
            <div class="panel-body kv" id="locationRows"></div>
          </article>
        </section>

        <section class="panel" id="monitoring-endpoints">
          <div class="panel-header">
            <h2 class="panel-title">Monitoring Endpoints</h2>
            <p class="panel-subtitle">Basic checks for humans and scripts</p>
          </div>
          <div class="panel-body endpoint-grid" id="endpointRows"></div>
        </section>
      </section>
    </main>
  </div>
  <div class="toast" id="toast" role="status" aria-live="polite">Copied</div>

  <script>
    const fallback = {
      service: "vm-dashboard",
      variant: "devsecops",
      student_name: "Anonymous Padawan",
      app_name: "VM Dashboard",
      tagline: "GCP deployment",
      project_id: "unknown",
      instance_id: "unknown",
      instance_name: "unknown",
      hostname: "unknown",
      machine_type: "unknown",
      service_account: "unknown",
      os: "unknown",
      region: "unknown",
      zone: "unknown",
      network: { vpc: "unknown", subnet: "unknown", internal_ip: "unknown", external_ip: "unknown" },
      health: {
        status: "warning",
        uptime: "unknown",
        load_avg: "unknown",
        load_1m: "0",
        cpu_cores: 1,
        ram_mb: { used: 0, available: 0, total: 0, use_pct: 0, status: "warning" },
        disk_root_mb: { used: 0, available: 0, total: 0, use_pct: 0, status: "warning" }
      },
      services: [],
      endpoints: [],
      startup_utc: "unknown"
    };

    let dashboard = fallback;

    const byId = (id) => document.getElementById(id);
    const text = (value) => value === undefined || value === null || value === "" ? "unknown" : String(value);
    const esc = (value) => text(value).replace(/[&<>"']/g, (char) => ({
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;",
      '"': "&quot;",
      "'": "&#39;"
    })[char]);

    const icon = (id) => `<span class="icon"><svg><use href="#${id}"></use></svg></span>`;

    function statusClass(status) {
      return ["healthy", "warning", "critical"].includes(status) ? status : "warning";
    }

    function resourceStateText(status) {
      const cls = statusClass(status);
      if (cls === "critical") return "Critical";
      if (cls === "warning") return "Elevated";
      return "Normal";
    }

    function row(label, value) {
      return `<div class="row"><div class="key">${esc(label)}</div><div class="value">${esc(value)}</div></div>`;
    }

    function stat(label, value, detail, status, iconId) {
      const cls = statusClass(status);
      return `
        <article class="stat-card ${cls}">
          <div class="stat-top">
            <div class="stat-icon">${icon(iconId)}</div>
            <span class="status-pill">${esc(cls)}</span>
          </div>
          <div class="stat-label">${esc(label)}</div>
          <div class="stat-value">${esc(value)}</div>
          <div class="stat-detail">${esc(detail)}</div>
        </article>
      `;
    }

    function render(data) {
      dashboard = { ...fallback, ...data, network: { ...fallback.network, ...(data.network || {}) }, health: { ...fallback.health, ...(data.health || {}) } };
      dashboard.health.ram_mb = { ...fallback.health.ram_mb, ...(dashboard.health.ram_mb || {}) };
      dashboard.health.disk_root_mb = { ...fallback.health.disk_root_mb, ...(dashboard.health.disk_root_mb || {}) };

      // Update page title and header elements
      document.title = `${dashboard.student_name} - ${dashboard.app_name}`;
      const studentElem = byId("studentNameDisplay");
      if (studentElem) studentElem.textContent = dashboard.student_name;
      const appElem = byId("appNameDisplay");
      if (appElem) appElem.textContent = dashboard.app_name;
      const taglineElem = byId("taglineText");
      if (taglineElem) taglineElem.textContent = `${dashboard.tagline} | refreshed ${new Date().toLocaleTimeString()}`;
      byId("uptimePill").innerHTML = `${icon("i-clock")}Uptime: ${esc(dashboard.health.uptime)}`;

      byId("overview").innerHTML = [
        stat("Resource State", resourceStateText(dashboard.health.status), "Status summary: Memory and Disk", dashboard.health.status, "i-activity"),
        stat("Load", dashboard.health.load_1m, `${dashboard.health.cpu_cores} CPU cores`, "healthy", "i-cpu"),
        stat("Memory", `${dashboard.health.ram_mb.use_pct}%`, `${dashboard.health.ram_mb.available} MB available`, dashboard.health.ram_mb.status, "i-cpu"),
        stat("Disk", `${dashboard.health.disk_root_mb.use_pct}%`, `${dashboard.health.disk_root_mb.available} MB available`, dashboard.health.disk_root_mb.status, "i-server")
      ].join("");

      byId("identityRows").innerHTML = [
        row("Project", dashboard.project_id),
        row("Instance ID", dashboard.instance_id),
        row("Instance Name", dashboard.instance_name),
        row("Hostname", dashboard.hostname),
        row("Machine Type", dashboard.machine_type),
        row("Service Account", dashboard.service_account),
        row("OS", dashboard.os)
      ].join("");

      byId("networkRows").innerHTML = [
        row("VPC", dashboard.network.vpc),
        row("Subnet", dashboard.network.subnet),
        row("Internal IP", dashboard.network.internal_ip),
        row("External IP", dashboard.network.external_ip)
      ].join("");

      byId("locationRows").innerHTML = [
        row("Region", dashboard.region),
        row("Zone", dashboard.zone),
        row("Startup UTC", dashboard.startup_utc),
        row("Uptime", dashboard.health.uptime),
        row("Load Avg", dashboard.health.load_avg)
      ].join("");

      byId("endpointRows").innerHTML = (dashboard.endpoints || [])
        .filter((endpoint) => ["Health", "Metadata", "Dashboard API"].includes(endpoint.name))
        .map((endpoint) => `
        <a class="endpoint" href="${esc(endpoint.path)}">
          <strong>${icon("i-link")}${esc(endpoint.name)}</strong>
          <span>${esc(endpoint.path)}</span>
        </a>
      `).join("");
    }

    function showToast(message) {
      const toast = byId("toast");
      toast.textContent = message;
      toast.classList.add("show");
      window.setTimeout(() => toast.classList.remove("show"), 1800);
    }

    async function copyText(value, message) {
      try {
        if (navigator.clipboard && window.isSecureContext) {
          await navigator.clipboard.writeText(value);
        } else {
          const textarea = document.createElement("textarea");
          textarea.value = value;
          textarea.setAttribute("readonly", "");
          textarea.style.position = "fixed";
          textarea.style.opacity = "0";
          document.body.appendChild(textarea);
          textarea.select();
          document.execCommand("copy");
          document.body.removeChild(textarea);
        }
        showToast(message);
      } catch {
        showToast("Copy unavailable");
      }
    }

    function formatTextSnapshot() {
      const data = dashboard;
      return [
        "VM DASHBOARD SNAPSHOT",
        "",
        `Service:       ${text(data.service)} (${text(data.health.status)})`,
        `Student:       ${text(data.student_name)}`,
        `App Name:      ${text(data.app_name)}`,
        `Tagline:       ${text(data.tagline)}`,
        `Project:       ${text(data.project_id)}`,
        `Instance:      ${text(data.instance_name)}`,
        `Machine:       ${text(data.machine_type)}`,
        `Zone:          ${text(data.zone)}`,
        `Region:        ${text(data.region)}`,
        `Startup UTC:   ${text(data.startup_utc)}`,
        "",
        "NETWORK",
        `VPC:           ${text(data.network.vpc)}`,
        `Subnet:        ${text(data.network.subnet)}`,
        `Internal IP:   ${text(data.network.internal_ip)}`,
        `External IP:   ${text(data.network.external_ip)}`,
        "",
        "SYSTEM",
        `Uptime:        ${text(data.health.uptime)}`,
        `Load Avg:      ${text(data.health.load_avg)}`,
        `CPU Cores:     ${text(data.health.cpu_cores)}`,
        `Memory:        ${text(data.health.ram_mb.used)} / ${text(data.health.ram_mb.total)} MB (${text(data.health.ram_mb.use_pct)}%)`,
        `Root Disk:     ${text(data.health.disk_root_mb.used)} / ${text(data.health.disk_root_mb.total)} MB (${text(data.health.disk_root_mb.use_pct)}%)`,
        "",
        "ENDPOINTS",
        ...(data.endpoints || []).map((endpoint) => `${endpoint.name}: ${endpoint.path}`)
      ].join("\n");
    }

    byId("copySnapshot").addEventListener("click", () => copyText(formatTextSnapshot(), "Snapshot copied"));
    byId("copyJson").addEventListener("click", () => copyText(JSON.stringify(dashboard, null, 2), "JSON copied"));

    async function load() {
      try {
        const response = await fetch("/metadata", { cache: "no-store" });
        if (!response.ok) throw new Error(`metadata ${response.status}`);
        render(await response.json());
      } catch {
        render(fallback);
      }
    }

    // Shimmer effect: full‑width line runs for 1.25s every 20 seconds
    let shimmerInterval = null;
    function triggerShimmer() {
      const topbar = document.getElementById('topbar');
      if (!topbar) return;
      topbar.classList.add('shimmer');
      topbar.addEventListener('animationend', () => {
        topbar.classList.remove('shimmer');
      }, { once: true });
    }

    function startShimmerTimer() {
      if (shimmerInterval) clearInterval(shimmerInterval);
      triggerShimmer(); // run once immediately
      shimmerInterval = setInterval(triggerShimmer, 20000);
    }

    // Start after page loads
    window.addEventListener('DOMContentLoaded', () => {
      startShimmerTimer();
    });

    load();
  </script>
</body>
</html>
HTML_EOF

# ----------------------------------------------------------------------
# Enable, test, and restart Nginx
# ----------------------------------------------------------------------
systemctl enable nginx
nginx -t
systemctl restart nginx

echo "OK: VM Dashboard deployed."
echo "Try:"
echo "  curl -s localhost/healthz"
echo "  curl -s localhost/metadata | jq ."
echo "Then open your browser to the external IP of this VM."