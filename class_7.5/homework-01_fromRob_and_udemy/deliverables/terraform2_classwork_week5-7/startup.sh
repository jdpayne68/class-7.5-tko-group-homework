#!/bin/bash

apt update -y
apt install -y git nginx

systemctl enable nginx
systemctl start nginx

cd /tmp
git clone https://github.com/BalericaAI/SEIR-1.git

chmod +x /tmp/SEIR-1/weekly_lessons/week8/userscripts/supera.sh
bash /tmp/SEIR-1/weekly_lessons/week8/userscripts/supera.sh