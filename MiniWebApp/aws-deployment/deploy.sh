#!/bin/bash

# Script de despliegue para AWS EC2
echo "🚀 Iniciando despliegue en AWS EC2..."

# Detener contenedores existentes
echo "🛑 Deteniendo contenedores existentes..."
docker-compose -f docker-compose-aws.yml down

# Construir y levantar contenedores
echo "🏗️ Construyendo y levantando contenedores..."
docker-compose -f docker-compose-aws.yml up -d --build

# Verificar estado
echo "✅ Verificando estado de los contenedores..."
docker-compose -f docker-compose-aws.yml ps

echo "✅ Despliegue completado!"
echo "📌 La aplicación está disponible en:"
echo "   HTTP:  http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo "   HTTPS: https://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
