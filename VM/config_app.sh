#!/bin/bash

# Update the package list
apt-get update

# Install Nginx
apt-get install -y nginx
# Ensure Nginx service is started and enabled
sudo systemctl start nginx
sudo systemctl enable nginx

echo "<html><body><h1 style='color:purple;'>Hello world</h1></body></html>" > /var/www/html/index.html

sudo nginx -t
sudo systemctl reload nginx

