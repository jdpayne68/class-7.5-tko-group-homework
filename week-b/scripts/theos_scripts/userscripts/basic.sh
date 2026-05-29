#!/bin/bash

#Chewbacca: A node awakens in the cloud.

apt update -y
apt install -y nginx

HOSTNAME=$(hostname)
DATE=$(date)
OS=$(lsb_release -d | cut -f2)
UPTIME=$(uptime -p)

cat <<EOF > /var/www/html/index.html
<html>
<head>
<title>SEIR-I Cloud Node</title>
<style>
body {
    background-color:#0b0c10;
    color:#66fcf1;
    font-family: monospace;
    text-align:center;
    padding-top:50px;
}
.box {
    border:2px solid #45a29e;
    width:600px;
    margin:auto;
    padding:20px;
}
</style>
</head>

<body>

<h1>⚡ SEIR-I Cloud Node Online ⚡</h1>

<div class="box">

<p><b>Hostname:</b> $HOSTNAME</p>
<p><b>OS:</b> $OS</p>
<p><b>Uptime:</b> $UPTIME</p>
<p><b>Startup Time:</b> $DATE</p>

<br>

<p>If you see this page, you have successfully deployed infrastructure.</p>

<p><b>Welcome to Cloud Engineering.</b></p>

</div>

</body>
</html>
EOF

systemctl restart nginx
