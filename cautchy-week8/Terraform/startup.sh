#!/bin/bash

# this just is to keep those next two commands readable. $META and $HEADER get replaced with these lines
META="http://metadata.google.internal/computeMetadata/v1/instance"
HEADER="Metadata-Flavor: Google"

# makes variables $NAME and $IP. Their values are from the curl command that hits the metadata service for VMs 
NAME=$(curl -H "$HEADER" "$META/name")
IP=$(curl -H "$HEADER" "$META/network-interfaces/0/ip")

# have the package manager grab the apache2 webserver 
dnf install -y httpd

# write our html file to the default location apache2 looks for
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<body>
  <h1>VM Metadata</h1>
  <h2>Instance Name: $NAME</h2>
  <h2>Internal IP: $IP</h2>
  <h2>BUNDA! BUNDA! BUNDA!...</h2>
  <figure>
    <img src="https://i.pinimg.com/736x/6e/47/a2/6e47a2778e3ffe02ade527f09de0244c.jpg" alt="Round where it counts" style="max-width:600px; width:100%; display:block; margin:1rem 0;">
    <figcaption>Round where it counts</figcaption>
  </figure>
</body>
</html>
EOF

# turn on apache2 service and make it turn on after the VM reboots too
systemctl enable --now httpd