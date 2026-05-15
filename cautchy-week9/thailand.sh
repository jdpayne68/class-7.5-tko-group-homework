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
ZONE_FULL="$(md instance/zone)"
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
STUDENT_NAME="$(md instance/attributes/student_name)"
[[ -z "$STUDENT_NAME" || "$STUDENT_NAME" == "Cautchy Bailly" ]] && STUDENT_NAME="Cautchy Bailly"
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
cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    index index.html;
    location = / { try_files /index.html =404; }
    location = /healthz { default_type text/plain; return 200 "ok\n"; }
    location = /metadata { default_type application/json; try_files /metadata.json =404; }
}
EOF
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
  "network": { "vpc": "$VPC", "subnet": "$SUBNET", "internal_ip": "$INTERNAL_IP", "external_ip": "$EXTERNAL_IP" },
  "health": {
    "uptime": "$UPTIME",
    "load_avg": "$LOADAVG",
    "ram_mb": {"used": $MEM_USED_MB, "free": $MEM_FREE_MB, "total": $MEM_TOTAL_MB},
    "disk_root": {"size": "$DISK_SIZE", "used": "$DISK_USED", "avail": "$DISK_AVAIL", "use_pct": "$DISK_USEP"}
  },
  "startup_utc": "$START_TIME_UTC"
}
EOF
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8"/>
  <title>Warm cloud job hello from 🇹🇭</title>
  <meta http-equiv="refresh" content="10">
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,700;0,900;1,700&family=Inter:wght@400;600&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      /* Thailand flag: red top/bottom, white middle, navy blue center band */
      background-color: #0d1b3e;
      background-image:
        radial-gradient(ellipse 55% 38% at 15% 10%, rgba(165,10,40,0.22) 0%, transparent 65%),
        radial-gradient(ellipse 45% 30% at 85% 90%, rgba(165,10,40,0.18) 0%, transparent 65%),
        radial-gradient(ellipse 60% 50% at 50% 50%, rgba(13,27,62,0.6) 0%, transparent 80%);
      color: #e8eaf2;
      font-family: 'Inter', ui-monospace, monospace;
      min-height: 100vh;
    }

    /* ── Tri-color top stripe ── */
    .flag-stripe {
      height: 6px;
      background: linear-gradient(90deg, #a50a28 33.3%, #ffffff 33.3%, #ffffff 66.6%, #0d1b3e 66.6%);
      position: fixed;
      top: 0; left: 0; right: 0;
      z-index: 100;
    }
    .flag-stripe-bottom {
      height: 6px;
      background: linear-gradient(90deg, #0d1b3e 33.3%, #ffffff 33.3%, #ffffff 66.6%, #a50a28 66.6%);
      position: fixed;
      bottom: 0; left: 0; right: 0;
      z-index: 100;
    }

    .wrap { max-width: 1100px; margin: 0 auto; padding: 60px 28px 72px; }

    /* ── Corner accents ── */
    .corner {
      position: fixed;
      font-size: 3rem;
      opacity: 0.12;
      pointer-events: none;
    }
    .corner-tl { top: 24px; left: 22px; transform: rotate(-15deg); }
    .corner-tr { top: 24px; right: 22px; transform: rotate(15deg); }
    .corner-bl { bottom: 24px; left: 22px; transform: rotate(10deg); }
    .corner-br { bottom: 24px; right: 22px; transform: rotate(-10deg); }

    /* ── Hero ── */
    .hero { text-align: center; margin-bottom: 52px; }
    .hero-eyebrow {
      font-size: 0.72rem;
      letter-spacing: 0.32em;
      text-transform: uppercase;
      color: #6b7aaa;
      margin-bottom: 16px;
    }
    .hero-title {
      font-family: 'Playfair Display', Georgia, serif;
      font-size: clamp(2.4rem, 6.5vw, 5rem);
      font-weight: 900;
      font-style: italic;
      line-height: 1.05;
      background: linear-gradient(135deg, #a50a28 0%, #d4183c 30%, #ffffff 55%, #1a3a8f 80%, #0d1b3e 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
      margin-bottom: 12px;
    }
    .hero-sub {
      font-size: 0.78rem;
      letter-spacing: 0.22em;
      text-transform: uppercase;
      color: #3a4f8a;
    }

    /* ── Divider ── */
    .divider {
      display: flex;
      align-items: center;
      gap: 12px;
      margin: 0 auto 38px;
      max-width: 480px;
    }
    .divider-line { flex: 1; height: 1px; background: linear-gradient(90deg, transparent, #1a3a8f, transparent); }
    .divider-icon { font-size: 1rem; opacity: 0.75; }

    /* ── Banner ── */
    .banner {
      display: flex;
      flex-wrap: wrap;
      gap: 10px 24px;
      align-items: center;
      border: 1px solid #1a2b5a;
      border-left: 3px solid #a50a28;
      border-radius: 10px;
      padding: 12px 18px;
      margin-bottom: 32px;
      background: rgba(165,10,40,0.07);
      font-size: 0.82rem;
    }
    .banner .k { color: #a50a28; font-weight: 600; margin-right: 4px; }
    .banner .v { color: #e8eaf2; }

    /* ── Grid ── */
    .grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; margin-bottom: 36px; }
    .card {
      border: 1px solid #1a2b5a;
      border-radius: 14px;
      padding: 18px 20px;
      background: #0a1530;
      transition: border-color 0.3s, box-shadow 0.3s;
    }
    .card:hover {
      border-color: #a50a28;
      box-shadow: 0 0 18px rgba(165,10,40,0.2);
    }
    .card-label {
      font-size: 0.68rem;
      font-weight: 600;
      letter-spacing: 0.15em;
      text-transform: uppercase;
      color: #a50a28;
      margin-bottom: 12px;
      padding-bottom: 8px;
      border-bottom: 1px solid #1a2b5a;
    }
    .row { display: flex; justify-content: space-between; align-items: baseline; padding: 4px 0; font-size: 0.82rem; }
    .row .k { color: #3a4f8a; }
    .row .v { color: #e8eaf2; font-weight: 600; font-variant-numeric: tabular-nums; }
    a { color: #d4183c; text-decoration: none; }
    a:hover { text-decoration: underline; }

    /* ── Image boxes ── */
    .img-section { margin-bottom: 36px; }
    .img-section-title {
      font-family: 'Playfair Display', Georgia, serif;
      font-size: 1rem;
      font-style: italic;
      color: #6b7aaa;
      margin-bottom: 16px;
      text-align: center;
      letter-spacing: 0.06em;
    }
    .img-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
    .img-box {
      border: 1px solid #1a2b5a;
      border-radius: 14px;
      overflow: hidden;
      background: #0a1530;
      aspect-ratio: 3 / 4;
      position: relative;
      transition: border-color 0.3s, box-shadow 0.3s;
    }
    .img-box:hover {
      border-color: #a50a28;
      box-shadow: 0 0 22px rgba(165,10,40,0.22);
    }
    .img-box img { width: 100%; height: 100%; object-fit: cover; display: block; }
    .img-box-label {
      position: absolute;
      bottom: 0; left: 0; right: 0;
      padding: 10px 14px;
      font-size: 0.7rem;
      font-weight: 600;
      letter-spacing: 0.12em;
      text-transform: uppercase;
      background: rgba(10,21,48,0.88);
      color: #a50a28;
      backdrop-filter: blur(6px);
    }

    /* ── Footer ── */
    .footer { margin-top: 24px; text-align: center; color: #1a2b5a; font-size: 0.74rem; letter-spacing: 0.06em; }

    @media (max-width: 640px) {
      .grid { grid-template-columns: 1fr; }
      .img-grid { grid-template-columns: 1fr; }
      .corner { display: none; }
    }
  </style>
</head>
<body>
  <div class="flag-stripe"></div>
  <div class="flag-stripe-bottom"></div>
  <div class="corner corner-tl">🇹🇭</div>
  <div class="corner corner-tr">🇹🇭</div>
  <div class="corner corner-bl">🇹🇭</div>
  <div class="corner corner-br">🇹🇭</div>
  <div class="wrap">

    <div class="hero">
      <div class="hero-eyebrow">SEIR-I Ops Panel &nbsp;·&nbsp; Node Online</div>
      <div class="hero-title">Warm cloud job hello from 🇹🇭</div>
      <div class="hero-sub">Auto-refresh: 10s</div>
    </div>

    <div class="divider">
      <div class="divider-line"></div>
      <div class="divider-icon">🇹🇭</div>
      <div class="divider-line"></div>
    </div>

    <div class="banner">
      <span><span class="k">Deploy Banner:</span><span class="v">${STUDENT_NAME}</span></span>
      <span><span class="k">Startup UTC:</span><span class="v">${START_TIME_UTC}</span></span>
      <span><span class="k">Auto-refresh:</span><span class="v">10s</span></span>
    </div>

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
        <div style="margin-top:14px; padding-top:10px; border-top:1px solid #1a2b5a;">
          <div class="card-label" style="margin-bottom:8px; border-bottom:none; padding-bottom:0;">Endpoints</div>
          <div style="font-size:0.82rem; margin-bottom:4px;"><a href="/healthz">/healthz</a> <span style="color:#1a2b5a;">(plain text)</span></div>
          <div style="font-size:0.82rem;"><a href="/metadata">/metadata</a> <span style="color:#1a2b5a;">(JSON)</span></div>
        </div>
      </div>
    </div>

    <div class="img-section">
      <div class="img-section-title">🇹🇭 &nbsp; Vol. 1 &nbsp; 🇹🇭</div>
      <div class="img-grid">
        <div class="img-box">
          <img src="https://womanate.com/wp-content/uploads/2023/07/wate_thai4.jpg" alt="Monday through Tuesday">
          <div class="img-box-label">Image 01</div>
        </div>
        <div class="img-box">
          <img src="https://womanate.com/wp-content/uploads/2023/07/wate_thai13-820x1024.jpg" alt="Wednesday through Thursday">
          <div class="img-box-label">Image 02</div>
        </div>
        <div class="img-box">
          <img src="https://womanate.com/wp-content/uploads/2023/07/wate_thai11-824x1024.jpg" alt="Friday through Saturday">
          <div class="img-box-label">Image 03</div>
        </div>
      </div>
    </div>

    <div class="footer">
      #Chewbacca: Humans celebrate the dashboard from Thailand. With a busy schedule apparently. Machines trust /healthz. Engineers curl /metadata.
    </div>

  </div>
</body>
</html>
EOF
systemctl enable nginx >/dev/null 2>&1 || true
systemctl restart nginx
echo "OK: SEIR-I node deployed."
echo "Try:"
echo "  curl -s localhost/healthz"
echo "  curl -s localhost/metadata | jq ."