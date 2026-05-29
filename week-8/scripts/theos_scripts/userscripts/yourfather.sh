#!/bin/bash

apt update -y
apt install -y apache2

cat <<'EOF' > /var/www/html/index.html
<html>
<head>
<title>SEIR Lab Node</title>
<style>
body {
  background-color:black;
  color:lime;
  font-family:monospace;
}
pre {
  font-size:12px;
  line-height:1.2;
}
</style>
</head>
<body>

<h1>SEIR Infrastructure Node Online</h1>

<pre>
   _________________________________
  |:::::::::::::;;::::::::::::::::::|
  |:::::::::::'~||~~~``:::::::::::::|
  |::::::::'   .':     o`:::::::::::|
  |:::::::' oo | |o  o    ::::::::::|
  |::::::: 8  .'.'    8 o  :::::::::|
  |::::::: 8  | |     8    :::::::::|
  |::::::: _._| |_,...8    :::::::::|
  |::::::'~--.   .--. `.   `::::::::|
  |:::::'     =8     ~  \ o ::::::::|
  |::::'       8._ 88.   \ o::::::::|
  |:::'   __. ,.ooo~~.    \ o`::::::|
  |:::   . -. 88`78o/:     \  `:::::|
  |::'     /. o o \ ::      \88`::::|   "No. I am your father."
  |:;     o|| 8 8 |d.        `8 `:::|
  |:.       - ^ ^ -'           `-`::|
  |::.                          .:::|
  |:::::.....           ::'     ``::|
  |::::::::-'`-        88          `|
  |:::::-'.          -       ::     |
  |:-~. . .                   :     |
  | .. .   ..:   o:8      88o       |
  |. .     :::   8:P     d888. . .  |
  |.   .   :88   88      888'  . .  |
  |   o8  d88P . 88   ' d88P   ..   |
  |  88P  888   d8P   ' 888         |
  |   8  d88P.'d:8  .- dP~ o8       |
  |      888   888    d~ o888    LS |
  |_________________________________|
</pre>

<p>The infrastructure is operational.</p>
<p>Terraform is watching.</p>
<p>Do not anger the state file.</p>

</body>
</html>
EOF

systemctl enable apache2
systemctl restart apache2