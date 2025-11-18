# Dockerfile para la aplicación Flask con Nginx y SSL
FROM python:3.10-slim

# Instalar dependencias del sistema
RUN apt update && apt install -y \
    nginx \
    default-libmysqlclient-dev \
    build-essential \
    pkg-config \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de la aplicación
WORKDIR /app

# Copiar archivos de la aplicación
COPY webapp/ /app/

# Instalar dependencias de Python
RUN pip install --no-cache-dir \
    Flask==2.3.3 \
    flask-cors \
    Flask-MySQLdb \
    Flask-SQLAlchemy \
    gunicorn

# Crear directorio para certificados SSL
RUN mkdir -p /etc/nginx/ssl

# Copiar configuración de Nginx
COPY docker/nginx.conf /etc/nginx/sites-available/default

# Exponer puertos HTTP y HTTPS
EXPOSE 80 443

# Script de inicio
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
