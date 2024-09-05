#!/bin/bash
# Uppdatera paketlista och installera Nginx
sudo apt-get update
sudo apt-get install -y nginx
# Ensure Nginx service is started and enabled
sudo systemctl start nginx
sudo systemctl enable nginx

# Skapa Nginx-konfigurationsfil för Reverseproxy
NGINX_CONF="/etc/nginx/sites-available/default"
cat << 'EOF' > "$NGINX_CONF"
server {
    listen 80 default_server;
    location / {
        proxy_pass http://10.0.0.10:5000; # Change to the internal IP of the app server
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Testa Nginx-konfigurationen och starta om Nginx
sudo nginx -t
sudo systemctl restart nginx