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
  font-size:14px;
}
</style>
</head>
<body>

<h1>SEIR Infrastructure Node Online</h1>

<pre>

                ▄████████████████████████▄
             ▄████████████████████████████▄
           ▄████████████████████████████████▄
          ████████████████████████████████████
         ██████████████████████████████████████
        ████████████████████████████████████████
        ████████████████████████████████████████
        ████████████████████████████████████████
         ██████████████████████████████████████
          ████████████████████████████████████
           ██████████████████████████████████
            ████████████████████████████████
              ████████████████████████████
                ████████████████████████
                 ██████████████████████
                  ████████████████████
                    ████████████████
                      ████████████
                        ████████
                          ████

</pre>

<p>The infrastructure is operational.</p>
<p>Terraform is watching.</p>
<p>Do not anger the state file.</p>

</body>
</html>
EOF

systemctl enable apache2
systemctl restart apache2
