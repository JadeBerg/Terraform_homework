#!/bin/bash
apt update && apt install -y nginx
echo '<h1>Hello world from Crash course DevOps</h1>' > /var/www/html/index.html