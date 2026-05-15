#!/bin/bash
set -euo pipefail
#Chewbacca: The node awakens. And it will speak in HTML, plain text, and JSON.
#Thanks for Aaron!
sleep 5
apt update -y
apt install -y nginx curl jq
METADATA="http://metadata.google.internal/computeMetadata/v1"
HDR="Metadata-Flavor: Google"
md() { curl -fsS -H "$HDR" "${METADATA}/$1" || echo "unknown"; }
INSTANCE_NAME="$(md instance/name)"
HOSTNAME="$(hostname)"
PROJECT_ID="$(md project/project-id)"
ZONE_FULL="$(md instance/zone)"                  # projects/<id>/zones/us-central1-a
ZONE="${ZONE_FULL##*/}"
REGION="${ZONE%-*}"
MACHINE_TYPE_FULL="$(md instance/machine-type)"
MACHINE_TYPE="${MACHINE_TYPE_FULL##*/}"
INTERNAL_IP="$(md instance/network-interfaces/0/ip)"
EXTERNAL_IP="$(md instance/network-interfaces/0/access-configs/0/external-ip)"
VPC_FULL="$(md instance/network-interfaces/0/network)"
SUBNET_FULL="$(md instance/network-interfaces/0/subnetwork)"
VPC="${VPC_FULL##*/}"
SUBNET="${SUBNET_FULL##*/}"
START_TIME_UTC="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
# --- Student banner ---
# Students set this when creating the VM by adding a metadata key:
#   student_name = Darth Malgus Jr
STUDENT_NAME="$(md instance/attributes/student_name)"
[[ -z "$STUDENT_NAME" || "$STUDENT_NAME" == "Cautchy" ]] && STUDENT_NAME="Cautchy Bailly"
# --- Basic system stats ---
UPTIME="$(uptime -p || true)"
LOADAVG="$(awk '{print $1" "$2" "$3}' /proc/loadavg 2>/dev/null || echo "unknown")"
MEM_TOTAL_MB="$(free -m | awk '/Mem:/ {print $2}')"
MEM_USED_MB="$(free -m | awk '/Mem:/ {print $3}')"
MEM_FREE_MB="$(free -m | awk '/Mem:/ {print $4}')"
DISK_LINE="$(df -h / | tail -n 1)"
DISK_SIZE="$(echo "$DISK_LINE" | awk '{print $2}')"
DISK_USED="$(echo "$DISK_LINE" | awk '{print $3}')"
DISK_AVAIL="$(echo "$DISK_LINE" | awk '{print $4}')"
DISK_USEP="$(echo "$DISK_LINE" | awk '{print $5}')"
# --- Nginx config: add endpoints /healthz and /metadata ---
cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    index index.html;
    #Chewbacca: The homepage is for humans.
    location = / {
        try_files /index.html =404;
    }
    #Chewbacca: Health checks are for machines. Keep it boring.
    location = /healthz {
        default_type text/plain;
        return 200 "ok\n";
    }
    #Chewbacca: Metadata is for engineers and scripts.
    location = /metadata {
        default_type application/json;
        try_files /metadata.json =404;
    }
}
EOF
# --- Write JSON endpoint file ---
cat > /var/www/html/metadata.json <<EOF
{
  "service": "seir-i-node",
  "student_name": "$(echo "$STUDENT_NAME" | sed 's/"/\\"/g')",
  "project_id": "$PROJECT_ID",
  "instance_name": "$INSTANCE_NAME",
  "hostname": "$HOSTNAME",
  "region": "$REGION",
  "zone": "$ZONE",
  "machine_type": "$MACHINE_TYPE",
  "network": {
    "vpc": "$VPC",
    "subnet": "$SUBNET",
    "internal_ip": "$INTERNAL_IP",
    "external_ip": "$EXTERNAL_IP"
  },
  "health": {
    "uptime": "$UPTIME",
    "load_avg": "$LOADAVG",
    "ram_mb": {"used": $MEM_USED_MB, "free": $MEM_FREE_MB, "total": $MEM_TOTAL_MB},
    "disk_root": {"size": "$DISK_SIZE", "used": "$DISK_USED", "avail": "$DISK_AVAIL", "use_pct": "$DISK_USEP"}
  },
  "startup_utc": "$START_TIME_UTC"
}
EOF
# --- Write the main HTML dashboard ---
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8"/>
  <title>Top of the Class</title>
  <meta http-equiv="refresh" content="10">
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,700;0,900;1,700&family=Inter:wght@400;600&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    /* ── Rose petal SVG background ── */
    body {
      background-color: #080508;
      background-image:
        radial-gradient(ellipse 60% 40% at 10% 15%, rgba(120,10,30,0.18) 0%, transparent 70%),
        radial-gradient(ellipse 50% 35% at 90% 80%, rgba(120,10,30,0.15) 0%, transparent 70%),
        radial-gradient(ellipse 30% 20% at 50% 50%, rgba(80,5,20,0.08) 0%, transparent 80%);
      color: #eddde4;
      font-family: 'Inter', ui-monospace, monospace;
      min-height: 100vh;
    }
    .wrap { max-width: 1100px; margin: 0 auto; padding: 52px 28px 72px; }

    /* ── Decorative rose corner accents ── */
    .rose-corner {
      position: fixed;
      font-size: 3.5rem;
      opacity: 0.13;
      pointer-events: none;
      line-height: 1;
    }
    .rose-tl { top: 18px; left: 22px; transform: rotate(-20deg); }
    .rose-tr { top: 18px; right: 22px; transform: rotate(20deg) scaleX(-1); }
    .rose-bl { bottom: 18px; left: 22px; transform: rotate(15deg); }
    .rose-br { bottom: 18px; right: 22px; transform: rotate(-15deg) scaleX(-1); }

    /* ── Hero title ── */
    .hero { text-align: center; margin-bottom: 52px; }
    .hero-eyebrow {
      font-size: 0.72rem;
      letter-spacing: 0.32em;
      text-transform: uppercase;
      color: #7a2030;
      margin-bottom: 16px;
    }
    .hero-title {
      font-family: 'Playfair Display', Georgia, serif;
      font-size: clamp(2.6rem, 7vw, 5.4rem);
      font-weight: 900;
      font-style: italic;
      letter-spacing: -0.01em;
      line-height: 1.05;
      background: linear-gradient(135deg, #ff2d55 0%, #c0143c 35%, #8b0000 65%, #ff2d55 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
      margin-bottom: 12px;
    }
    .hero-sub {
      font-size: 0.78rem;
      letter-spacing: 0.22em;
      text-transform: uppercase;
      color: #5a1525;
    }

    /* ── Divider ── */
    .divider {
      display: flex;
      align-items: center;
      gap: 12px;
      margin: 0 auto 38px;
      max-width: 480px;
    }
    .divider-line { flex: 1; height: 1px; background: linear-gradient(90deg, transparent, #6b0020, transparent); }
    .divider-rose { font-size: 1rem; opacity: 0.7; }

    /* ── Banner ── */
    .banner {
      display: flex;
      flex-wrap: wrap;
      gap: 10px 24px;
      align-items: center;
      border: 1px solid #2a0610;
      border-left: 3px solid #c0143c;
      border-radius: 10px;
      padding: 12px 18px;
      margin-bottom: 32px;
      background: rgba(120, 10, 30, 0.08);
      font-size: 0.82rem;
    }
    .banner .k { color: #c0143c; font-weight: 600; margin-right: 4px; }
    .banner .v { color: #eddde4; }

    /* ── Metric grid ── */
    .grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 16px;
      margin-bottom: 36px;
    }
    .card {
      border: 1px solid #1e0409;
      border-radius: 14px;
      padding: 18px 20px;
      background: #0e0207;
      transition: border-color 0.3s, box-shadow 0.3s;
    }
    .card:hover {
      border-color: #8b0000;
      box-shadow: 0 0 18px rgba(139,0,0,0.18);
    }
    .card-label {
      font-size: 0.68rem;
      font-weight: 600;
      letter-spacing: 0.15em;
      text-transform: uppercase;
      color: #c0143c;
      margin-bottom: 12px;
      padding-bottom: 8px;
      border-bottom: 1px solid #1e0409;
    }
    .row { display: flex; justify-content: space-between; align-items: baseline; padding: 4px 0; font-size: 0.82rem; }
    .row .k { color: #5a1525; }
    .row .v { color: #eddde4; font-weight: 600; font-variant-numeric: tabular-nums; }
    a { color: #ff2d55; text-decoration: none; }
    a:hover { text-decoration: underline; }

    /* ── Image boxes ── */
    .img-section { margin-bottom: 36px; }
    .img-section-title {
      font-family: 'Playfair Display', Georgia, serif;
      font-size: 1rem;
      font-style: italic;
      color: #7a2030;
      letter-spacing: 0.06em;
      margin-bottom: 16px;
      text-align: center;
    }
    .img-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 16px;
    }
    .img-box {
      border: 1px solid #1e0409;
      border-radius: 14px;
      overflow: hidden;
      background: #0e0207;
      aspect-ratio: 3 / 4;
      position: relative;
      transition: border-color 0.3s, box-shadow 0.3s;
    }
    .img-box:hover {
      border-color: #c0143c;
      box-shadow: 0 0 22px rgba(192,20,60,0.22);
    }
    .img-box img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
    }
    .img-box-label {
      position: absolute;
      bottom: 0; left: 0; right: 0;
      padding: 10px 14px;
      font-size: 0.7rem;
      font-weight: 600;
      letter-spacing: 0.12em;
      text-transform: uppercase;
      background: rgba(8, 5, 8, 0.85);
      color: #c0143c;
      backdrop-filter: blur(6px);
    }

    /* ── Footer ── */
    .footer {
      margin-top: 24px;
      text-align: center;
      color: #2a0610;
      font-size: 0.74rem;
      letter-spacing: 0.06em;
    }

    @media (max-width: 640px) {
      .grid { grid-template-columns: 1fr; }
      .img-grid { grid-template-columns: 1fr; }
      .rose-corner { display: none; }
    }
  </style>
</head>
<body>
  <div class="rose-corner rose-tl">🌹</div>
  <div class="rose-corner rose-tr">🌹</div>
  <div class="rose-corner rose-bl">🌹</div>
  <div class="rose-corner rose-br">🌹</div>
  <div class="wrap">

    <!-- Hero -->
    <div class="hero">
      <div class="hero-eyebrow">SEIR-I Ops Panel &nbsp;·&nbsp; Node Online</div>
      <div class="hero-title">Top of the Class</div>
      <div class="hero-sub">Auto-refresh: 10s</div>
    </div>

    <div class="divider">
      <div class="divider-line"></div>
      <div class="divider-rose">🌹</div>
      <div class="divider-line"></div>
    </div>

    <!-- Banner -->
    <div class="banner">
      <span><span class="k">Deploy Banner:</span><span class="v">${STUDENT_NAME}</span></span>
      <span><span class="k">Startup UTC:</span><span class="v">${START_TIME_UTC}</span></span>
      <span><span class="k">Auto-refresh:</span><span class="v">10s</span></span>
    </div>

    <!-- Metric cards (all original data preserved) -->
    <div class="grid">
      <div class="card">
        <div class="card-label">Identity</div>
        <div class="row"><span class="k">Project</span><span class="v">${PROJECT_ID}</span></div>
        <div class="row"><span class="k">Instance</span><span class="v">${INSTANCE_NAME}</span></div>
        <div class="row"><span class="k">Hostname</span><span class="v">${HOSTNAME}</span></div>
        <div class="row"><span class="k">Machine</span><span class="v">${MACHINE_TYPE}</span></div>
      </div>
      <div class="card">
        <div class="card-label">Location</div>
        <div class="row"><span class="k">Region</span><span class="v">${REGION}</span></div>
        <div class="row"><span class="k">Zone</span><span class="v">${ZONE}</span></div>
        <div class="row"><span class="k">Uptime</span><span class="v">${UPTIME}</span></div>
        <div class="row"><span class="k">Load Avg</span><span class="v">${LOADAVG}</span></div>
      </div>
      <div class="card">
        <div class="card-label">Network</div>
        <div class="row"><span class="k">VPC</span><span class="v">${VPC}</span></div>
        <div class="row"><span class="k">Subnet</span><span class="v">${SUBNET}</span></div>
        <div class="row"><span class="k">Internal IP</span><span class="v">${INTERNAL_IP}</span></div>
        <div class="row"><span class="k">External IP</span><span class="v">${EXTERNAL_IP}</span></div>
      </div>
      <div class="card">
        <div class="card-label">System</div>
        <div class="row"><span class="k">RAM</span><span class="v">${MEM_USED_MB} used / ${MEM_FREE_MB} free / ${MEM_TOTAL_MB} total (MB)</span></div>
        <div class="row"><span class="k">Disk (/)</span><span class="v">${DISK_USED} used / ${DISK_AVAIL} avail / ${DISK_SIZE} total (${DISK_USEP})</span></div>
        <div style="margin-top: 14px; padding-top: 10px; border-top: 1px solid #1e0409;">
          <div class="card-label" style="margin-bottom: 8px; border-bottom: none; padding-bottom: 0;">Endpoints</div>
          <div style="font-size: 0.82rem; margin-bottom: 4px;"><a href="/healthz">/healthz</a> <span style="color:#2a0610;">(plain text)</span></div>
          <div style="font-size: 0.82rem;"><a href="/metadata">/metadata</a> <span style="color:#2a0610;">(JSON)</span></div>
        </div>
      </div>
    </div>

    <!-- Image boxes — swap src URLs with your own images -->
    <div class="img-section">
      <div class="img-section-title">🌹 &nbsp; Vol. 1 &nbsp; 🌹</div>
      <div class="img-grid">
        <div class="img-box">
          <img src="https://64.media.tumblr.com/668c85dfc2e8d2bc82e749bde52c3f3d/tumblr_p4zvw2kHXb1qb7z9no5_1280.jpg" alt="Image 01">
          <div class="img-box-label">Image 01</div>
        </div>
        <div class="img-box">
          <img src="https://64.media.tumblr.com/74e8654d5bc7183af387cafc80ab90fa/tumblr_p4zvw2kHXb1qb7z9no1_1280.jpg" alt="Image 02">
          <div class="img-box-label">Image 02</div>
        </div>
        <div class="img-box">
          <img src="https://64.media.tumblr.com/cb8d2ab8c26221f265dc5b6ed30b928c/tumblr_o2tygrhXMc1qb7z9no2_1280.jpg" alt="Image 03">
          <div class="img-box-label">Image 03</div>
        </div>
      </div>
    </div>

    <!-- Footer -->
    <div class="footer">
      #Chewbacca: Humans celebrate the dashboard. Machines trust /healthz. Engineers curl /metadata.
    </div>

  </div>
</body>
</html>
EOF
systemctl enable nginx >/dev/null 2>&1 || true
systemctl restart nginx
#Chewbacca: Proof in terminal too.
echo "OK: SEIR-I node deployed."
echo "Try:"
echo "  curl -s localhost/healthz"
echo "  curl -s localhost/metadata | jq ."