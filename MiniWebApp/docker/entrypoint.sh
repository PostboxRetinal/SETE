#!/bin/bash
set -e

# Generar certificados SSL autofirmados si no existen
if [ ! -f /etc/nginx/ssl/server.crt ]; then
    echo "Generando certificados SSL autofirmados..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/server.key \
        -out /etc/nginx/ssl/server.crt \
        -subj "/C=CO/ST=Cundinamarca/L=Bogota/O=CloudNova/CN=localhost"
    echo "Certificados SSL generados exitosamente"
fi

# Iniciar Nginx
echo "Iniciando Nginx..."
service nginx start

# Iniciar aplicación Flask con Gunicorn
echo "Iniciando aplicación Flask..."
cd /app
gunicorn --bind 127.0.0.1:5000 --workers 4 --timeout 120 run:app
