#!/bin/bash

apt update -y
apt install -y nginx

cat <<EOF > /var/www/html/index.html
<html>

<head>
<title>Engineer Level Up</title>

<style>
body {
background:#1f2833;
color:#c5c6c7;
font-family:Arial;
text-align:center;
padding-top:80px;
}

h1{
color:#66fcf1;
}

</style>
</head>

<body>

<h1>LEVEL 1 COMPLETE</h1>

<p>You deployed infrastructure in Google Cloud.</p>

<p>Most people never get this far.</p>

<p>Next mission: <b>automation</b>.</p>

<br>

<p>SEIR-I Program</p>

</body>

</html>
EOF

systemctl restart nginx
