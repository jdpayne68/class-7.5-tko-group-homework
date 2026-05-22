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
[[ -z "$STUDENT_NAME" || "$STUDENT_NAME" == "Joe Tolliver" ]] && STUDENT_NAME="Valkyrie Engine"

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
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <title>SEIR-I Ops Panel</title>
  <meta http-equiv="refresh" content="10">
  <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Share+Tech+Mono&display=swap" rel="stylesheet">
  <style>
    :root {
      --cyan:    #66fcf1;
      --teal:    #45a29e;
      --magenta: #ff2d78;
      --orange:  #ff8c00;
      --yellow:  #ffe900;
      --green:   #39ff14;
      --bg:      #060810;
      --surface: rgba(15,20,40,0.85);
    }

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    /* ── Starfield background ── */
    body {
      background: var(--bg);
      color: #c5c6c7;
      font-family: 'Share Tech Mono', monospace;
      min-height: 100vh;
      overflow-x: hidden;
    }

    /* SVG star canvas behind everything */
    #stars-svg {
      position: fixed;
      inset: 0;
      width: 100%; height: 100%;
      z-index: 0;
      pointer-events: none;
    }

    /* Animated nebula blobs */
    .nebula {
      position: fixed;
      border-radius: 50%;
      filter: blur(90px);
      opacity: 0.18;
      z-index: 0;
      animation: drift 18s ease-in-out infinite alternate;
    }
    .nebula-1 { width:600px;height:600px;top:-150px;left:-100px;background:radial-gradient(circle,#ff2d78,transparent 70%); animation-duration:20s; }
    .nebula-2 { width:500px;height:500px;bottom:-100px;right:-80px;background:radial-gradient(circle,#66fcf1,transparent 70%); animation-duration:25s; animation-delay:-8s; }
    .nebula-3 { width:400px;height:400px;top:40%;left:55%;background:radial-gradient(circle,#7b2fff,transparent 70%); animation-duration:22s; animation-delay:-4s; }

    @keyframes drift {
      from { transform: translate(0,0) scale(1); }
      to   { transform: translate(40px,30px) scale(1.12); }
    }

    /* Scanline overlay */
    body::after {
      content:'';
      position:fixed;inset:0;
      background: repeating-linear-gradient(
        0deg,
        rgba(0,0,0,0.08) 0px,
        rgba(0,0,0,0.08) 1px,
        transparent 1px,
        transparent 3px
      );
      pointer-events:none;
      z-index:1;
    }

    /* ── Layout ── */
    .wrap {
      position: relative;
      z-index: 2;
      max-width: 1020px;
      margin: 0 auto;
      padding: 36px 24px 48px;
    }

    /* ── Header ── */
    .header {
      display: flex;
      align-items: center;
      gap: 20px;
      margin-bottom: 10px;
    }

    /* Animated GCP-style node icon (pure SVG/CSS) */
    .node-icon {
      width: 64px; height: 64px;
      flex-shrink: 0;
      animation: spin-slow 12s linear infinite;
    }
    @keyframes spin-slow {
      to { transform: rotate(360deg); }
    }

    h1 {
      font-family: 'Orbitron', monospace;
      font-size: clamp(1.3rem, 4vw, 2.1rem);
      font-weight: 900;
      letter-spacing: 0.05em;
      background: linear-gradient(90deg, var(--cyan) 0%, var(--magenta) 60%, var(--orange) 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
      line-height: 1.15;
      text-shadow: none;
    }

    .sub {
      color: var(--teal);
      font-size: 0.82rem;
      margin-top: 4px;
      letter-spacing: 0.08em;
    }

    /* ── Pulse status dot ── */
    .status-row {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 20px;
      font-size: 0.78rem;
      letter-spacing: 0.1em;
      color: var(--green);
    }
    .pulse-dot {
      width: 10px; height: 10px;
      border-radius: 50%;
      background: var(--green);
      box-shadow: 0 0 0 0 rgba(57,255,20,0.6);
      animation: pulse 1.8s ease-out infinite;
    }
    @keyframes pulse {
      0%   { box-shadow: 0 0 0 0 rgba(57,255,20,0.6); }
      70%  { box-shadow: 0 0 0 10px rgba(57,255,20,0); }
      100% { box-shadow: 0 0 0 0 rgba(57,255,20,0); }
    }

    /* ── Banner ── */
    .banner {
      position: relative;
      border: 1px solid var(--cyan);
      border-radius: 12px;
      padding: 14px 18px;
      margin-bottom: 20px;
      background: var(--surface);
      overflow: hidden;
      backdrop-filter: blur(6px);
    }
    .banner::before {
      content: '';
      position: absolute;
      inset: 0;
      background: linear-gradient(120deg, rgba(102,252,241,0.08) 0%, rgba(255,45,120,0.06) 100%);
      pointer-events: none;
    }
    .banner-inner { position: relative; z-index: 1; display: flex; flex-wrap: wrap; gap: 8px 24px; align-items: center; }
    .banner .k { color: var(--cyan); font-family: 'Orbitron', monospace; font-size: 0.72rem; font-weight: 700; letter-spacing: 0.1em; }
    .banner .v { color: #fff; }

    /* ── Grid cards ── */
    .grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 16px;
    }
    @media(max-width:620px) { .grid { grid-template-columns: 1fr; } }

    .card {
      position: relative;
      border-radius: 14px;
      padding: 18px 20px;
      background: var(--surface);
      backdrop-filter: blur(8px);
      overflow: hidden;
      transition: transform 0.2s, box-shadow 0.2s;
    }
    .card:hover {
      transform: translateY(-3px);
      box-shadow: 0 0 28px rgba(102,252,241,0.18);
    }

    /* Coloured left-border accent per card */
    .card::before {
      content: '';
      position: absolute;
      left: 0; top: 0; bottom: 0;
      width: 4px;
      border-radius: 14px 0 0 14px;
    }
    .card-identity::before  { background: linear-gradient(180deg,var(--cyan),var(--teal)); }
    .card-location::before  { background: linear-gradient(180deg,var(--magenta),var(--orange)); }
    .card-network::before   { background: linear-gradient(180deg,var(--yellow),var(--green)); }
    .card-system::before    { background: linear-gradient(180deg,#7b2fff,var(--magenta)); }

    /* Watermark emoji icon per card */
    .card-watermark {
      position: absolute;
      right: 16px; top: 50%;
      transform: translateY(-50%);
      font-size: 56px;
      opacity: 0.07;
      pointer-events: none;
      user-select: none;
      line-height: 1;
    }

    .card-title {
      font-family: 'Orbitron', monospace;
      font-size: 0.68rem;
      font-weight: 700;
      letter-spacing: 0.15em;
      text-transform: uppercase;
      margin-bottom: 12px;
      padding-bottom: 8px;
      border-bottom: 1px solid rgba(255,255,255,0.08);
    }
    .card-identity .card-title  { color: var(--cyan); }
    .card-location .card-title  { color: var(--orange); }
    .card-network .card-title   { color: var(--yellow); }
    .card-system .card-title    { color: #bf7fff; }

    .row { display: flex; justify-content: space-between; align-items: baseline; margin: 5px 0; gap: 8px; }
    .k { color: var(--teal); font-size: 0.78rem; white-space: nowrap; }
    .v { color: #fff; font-size: 0.82rem; word-break: break-all; text-align: right; }

    /* ── Progress bars for RAM / Disk ── */
    .bar-wrap { margin: 8px 0 4px; }
    .bar-label { display: flex; justify-content: space-between; font-size: 0.75rem; margin-bottom: 4px; }
    .bar-bg {
      height: 7px;
      background: rgba(255,255,255,0.08);
      border-radius: 4px;
      overflow: hidden;
    }
    .bar-fill {
      height: 100%;
      border-radius: 4px;
      background: linear-gradient(90deg, var(--cyan), var(--magenta));
      transition: width 0.6s ease;
    }

    /* ── Endpoints ── */
    .endpoints {
      margin-top: 14px;
      padding-top: 10px;
      border-top: 1px solid rgba(255,255,255,0.08);
    }
    .ep-title {
      font-family: 'Orbitron', monospace;
      font-size: 0.65rem;
      letter-spacing: 0.15em;
      color: #bf7fff;
      margin-bottom: 6px;
    }
    .ep-links { display: flex; gap: 10px; flex-wrap: wrap; }
    .ep-link {
      display: inline-flex;
      align-items: center;
      gap: 5px;
      padding: 4px 10px;
      border-radius: 6px;
      font-size: 0.75rem;
      text-decoration: none;
      font-family: 'Share Tech Mono', monospace;
      transition: background 0.15s, box-shadow 0.15s;
    }
    .ep-healthz {
      background: rgba(57,255,20,0.12);
      color: var(--green);
      border: 1px solid rgba(57,255,20,0.3);
    }
    .ep-healthz:hover { background: rgba(57,255,20,0.25); box-shadow: 0 0 14px rgba(57,255,20,0.3); }
    .ep-metadata {
      background: rgba(102,252,241,0.10);
      color: var(--cyan);
      border: 1px solid rgba(102,252,241,0.3);
    }
    .ep-metadata:hover { background: rgba(102,252,241,0.22); box-shadow: 0 0 14px rgba(102,252,241,0.3); }

    /* ── Footer ── */
    .footer {
      margin-top: 22px;
      text-align: center;
      color: rgba(69,162,158,0.7);
      font-size: 0.75rem;
      letter-spacing: 0.05em;
    }
    .footer span { color: var(--magenta); }
  </style>
</head>
<body>

<!-- Animated star-field SVG -->
<svg id="stars-svg" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <radialGradient id="sg" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#fff" stop-opacity="1"/>
      <stop offset="100%" stop-color="#fff" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <!-- Stars are generated via JS below -->
</svg>

<!-- Nebula glows -->
<div class="nebula nebula-1"></div>
<div class="nebula nebula-2"></div>
<div class="nebula nebula-3"></div>

<div class="wrap">

  <!-- Header -->
  <div class="header">
    <!-- Animated hexagon node icon -->
    <svg class="node-icon" viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <polygon points="32,4 58,18 58,46 32,60 6,46 6,18" stroke="#66fcf1" stroke-width="2" fill="rgba(102,252,241,0.07)"/>
      <polygon points="32,13 50,23 50,41 32,51 14,41 14,23" stroke="#ff2d78" stroke-width="1.5" fill="rgba(255,45,120,0.06)"/>
      <circle cx="32" cy="32" r="7" fill="#66fcf1" opacity="0.9"/>
      <circle cx="32" cy="32" r="4" fill="#fff"/>
      <!-- corner nodes -->
      <circle cx="32" cy="4"  r="2.5" fill="#ff8c00"/>
      <circle cx="58" cy="18" r="2.5" fill="#ff2d78"/>
      <circle cx="58" cy="46" r="2.5" fill="#ffe900"/>
      <circle cx="32" cy="60" r="2.5" fill="#39ff14"/>
      <circle cx="6"  cy="46" r="2.5" fill="#66fcf1"/>
      <circle cx="6"  cy="18" r="2.5" fill="#7b2fff"/>
    </svg>

    <div>
      <h1>SEIR-I Ops Panel — Node Online</h1>
      <div class="sub">▸ PROOF-OF-LIFE · VM + STARTUP AUTOMATION + HTTP SERVICE</div>
    </div>
  </div>

  <!-- Live status -->
  <div class="status-row">
    <div class="pulse-dot"></div>
    SYSTEM NOMINAL · AUTO-REFRESH 5s
  </div>

  <!-- Banner -->
  <div class="banner">
    <div class="banner-inner">
      <span><span class="k">OPERATOR&nbsp;</span><span class="v">${STUDENT_NAME}</span></span>
      <span><span class="k">STARTUP UTC&nbsp;</span><span class="v">${START_TIME_UTC}</span></span>
    </div>
  </div>

  <!-- Grid -->
  <div class="grid">

    <!-- Identity -->
    <div class="card card-identity">
      <div class="card-watermark">🖥️</div>
      <div class="card-title">Identity</div>
      <div class="row"><span class="k">Project</span><span class="v">${PROJECT_ID}</span></div>
      <div class="row"><span class="k">Instance</span><span class="v">${INSTANCE_NAME}</span></div>
      <div class="row"><span class="k">Hostname</span><span class="v">${HOSTNAME}</span></div>
      <div class="row"><span class="k">Machine</span><span class="v">${MACHINE_TYPE}</span></div>
    </div>

    <!-- Location -->
    <div class="card card-location">
      <div class="card-watermark">🌐</div>
      <div class="card-title">Location</div>
      <div class="row"><span class="k">Region</span><span class="v">${REGION}</span></div>
      <div class="row"><span class="k">Zone</span><span class="v">${ZONE}</span></div>
      <div class="row"><span class="k">Uptime</span><span class="v">${UPTIME}</span></div>
      <div class="row"><span class="k">Load Avg</span><span class="v">${LOADAVG}</span></div>
    </div>

    <!-- Network -->
    <div class="card card-network">
      <div class="card-watermark">📡</div>
      <div class="card-title">Network</div>
      <div class="row"><span class="k">VPC</span><span class="v">${VPC}</span></div>
      <div class="row"><span class="k">Subnet</span><span class="v">${SUBNET}</span></div>
      <div class="row"><span class="k">Internal IP</span><span class="v">${INTERNAL_IP}</span></div>
      <div class="row"><span class="k">External IP</span><span class="v">${EXTERNAL_IP}</span></div>
    </div>

    <!-- System -->
    <div class="card card-system">
      <div class="card-watermark">⚙️</div>
      <div class="card-title">System</div>

      <div class="bar-wrap">
        <div class="bar-label">
          <span class="k">RAM</span>
          <span class="v" style="font-size:0.73rem;">${MEM_USED_MB} / ${MEM_TOTAL_MB} MB</span>
        </div>
        <div class="bar-bg">
          <div class="bar-fill" id="ram-bar" style="width:0%"></div>
        </div>
      </div>

      <div class="bar-wrap" style="margin-bottom:10px;">
        <div class="bar-label">
          <span class="k">Disk&nbsp;(/)</span>
          <span class="v" style="font-size:0.73rem;">${DISK_USED} / ${DISK_SIZE} (${DISK_USEP})</span>
        </div>
        <div class="bar-bg">
          <div class="bar-fill" id="disk-bar" style="width:0%;background:linear-gradient(90deg,var(--yellow),var(--green))"></div>
        </div>
      </div>

      <div class="endpoints">
        <div class="ep-title">Endpoints</div>
        <div class="ep-links">
          <a href="/healthz" class="ep-link ep-healthz">● /healthz</a>
          <a href="/metadata" class="ep-link ep-metadata">{ } /metadata</a>
        </div>
      </div>
    </div>

  </div><!-- /grid -->

  <div class="footer">
    <span>#Chewbacca:</span> Humans celebrate the dashboard. Machines trust /healthz. Engineers curl /metadata.
  </div>
</div><!-- /wrap -->

<script>
  /* ── Starfield ── */
  (function(){
    const svg = document.getElementById('stars-svg');
    const W = window.innerWidth, H = window.innerHeight;
    svg.setAttribute('viewBox', \`0 0 \${W} \${H}\`);
    svg.setAttribute('preserveAspectRatio','xMidYMid slice');
    const ns = 'http://www.w3.org/2000/svg';
    for(let i=0;i<220;i++){
      const c = document.createElementNS(ns,'circle');
      const r = Math.random()*1.5+0.3;
      c.setAttribute('cx', Math.random()*W);
      c.setAttribute('cy', Math.random()*H);
      c.setAttribute('r', r);
      const col = ['#fff','#66fcf1','#ff8c00','#ff2d78','#ffe900'][Math.floor(Math.random()*5)];
      c.setAttribute('fill', col);
      c.setAttribute('opacity', (Math.random()*0.6+0.2).toFixed(2));
      // twinkle
      const dur = (Math.random()*3+1.5).toFixed(1);
      c.style.animation = \`twinkle \${dur}s ease-in-out \${(Math.random()*3).toFixed(1)}s infinite alternate\`;
      svg.appendChild(c);
    }
    const style = document.createElementNS(ns,'style');
    style.textContent = '@keyframes twinkle{from{opacity:0.15}to{opacity:0.9}}';
    svg.appendChild(style);
  })();

  /* ── Animate RAM bar ── */
  (function(){
    const used = ${MEM_USED_MB}, total = ${MEM_TOTAL_MB};
    const pct = total > 0 ? Math.min(100,(used/total*100)).toFixed(1) : 0;
    setTimeout(()=>{ document.getElementById('ram-bar').style.width = pct+'%'; }, 200);
  })();

  /* ── Animate Disk bar (strip the % from shell var) ── */
  (function(){
    const raw = "${DISK_USEP}".replace('%','');
    const pct = parseFloat(raw) || 0;
    setTimeout(()=>{ document.getElementById('disk-bar').style.width = pct+'%'; }, 350);
  })();
</script>
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
