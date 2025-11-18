#!/bin/bash
set -e

# Genera certificados SSL autofirmados con nuestra configuración custom para CloudNova
if [ ! -f /etc/nginx/ssl/server.crt ]; then
    openssl req -x509 -nodes -days 90 -newkey rsa:4096 \
        -keyout /etc/nginx/ssl/server.key \
        -out /etc/nginx/ssl/server.crt \
        -subj "/C=CO/ST=VAC/L=Cali/O=CloudNova/OU=ServiciosTelematicos/CN=cloudnova.local"
fi

# Iniciar Nginx
service nginx start

# Iniciar aplicación Flask con Gunicorn
cd /app
gunicorn --bind 127.0.0.1:5000 --workers 4 --timeout 120 run:app
