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
# HTML file updated to show tiled background and iframe with embedded GCS static website
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>

<head>
  <title>GCP VM Metadata</title>

  <style>

    body {
      margin: 0;
      padding: 2rem;

      /* BACKGROUND IMAGE */
      background-image: url("https://storage.googleapis.com/kirkdevsecops-website/assets/images/misc/beach-collage.jpg");

      /* TILE THE COLLAGE */
      background-size: 500px;
      background-repeat: repeat;
      background-attachment: fixed;

      color: white;
      font-family: Arial, sans-serif;
    }

    .panel {
      background: rgba(0, 0, 0, 0.72);
      padding: 1.5rem;
      border-radius: 12px;

      max-width: 1400px;
      margin: auto;
    }

    iframe {
      width: 100%;
      height: 800px;

      border: 1px solid #ccc;
      border-radius: 12px;

      background: white;
    }

    h1, h2 {
      text-shadow: 2px 2px 6px rgba(0,0,0,0.7);
    }

  </style>
</head>

<body>

  <div class="panel">

    <h1>VM Metadata</h1>

    <h2>Instance Name: $NAME</h2>
    <h2>Internal IP: $IP</h2>

    <h2>Beaches on Beaches!</h2>

    <iframe
      src="https://storage.googleapis.com/kirkdevsecops-website/index.html">
    </iframe>

  </div>

</body>
</html>
EOF

# turn on apache2 service and make it turn on after the VM reboots too
systemctl enable --now httpd