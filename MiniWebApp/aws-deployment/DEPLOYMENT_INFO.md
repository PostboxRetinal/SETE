# Guía de Despliegue en AWS EC2 - MiniWebApp

## 📋 Requisitos Previos
- Instancia EC2 Ubuntu 22.04 en AWS
- Archivo `deployssh.pem` con permisos configurados
- Security Group con puertos abiertos

---

## 🔓 PASO 0: Configurar Security Group en AWS

Ve a la consola de AWS EC2 > Security Groups y abre estos puertos:

| Puerto | Protocolo | Descripción |
|--------|-----------|-------------|
| 22 | TCP | SSH |
| 80 | TCP | HTTP (Webapp) |
| 443 | TCP | HTTPS (Webapp) |
| 3000 | TCP | Grafana |
| 9090 | TCP | Prometheus |
| 9100 | TCP | Node Exporter |

Source: `0.0.0.0/0` (o tu IP específica para mayor seguridad)

---

## 🚀 PASO 1: Instalar Docker y Docker Compose en EC2

```powershell
ssh -i "deployssh.pem" ubuntu@TU-INSTANCIA-EC2.compute-1.amazonaws.com "curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && sudo usermod -aG docker ubuntu && sudo apt-get update && sudo apt-get install -y docker-compose-plugin && docker --version && docker compose version"
```

**Resultado esperado**: Debe mostrar las versiones de Docker y Docker Compose instaladas.

---

## 📁 PASO 2: Crear Estructura de Directorios en EC2

```powershell
ssh -i "deployssh.pem" ubuntu@TU-INSTANCIA-EC2.compute-1.amazonaws.com "mkdir -p ~/miniwebapp/docker ~/miniwebapp/webapp ~/miniwebapp/prometheus ~/miniwebapp/grafana"
```

---

## 📤 PASO 3: Copiar Archivos de la Aplicación

```powershell
scp -i "deployssh.pem" -r docker webapp init.sql ubuntu@TU-INSTANCIA-EC2.compute-1.amazonaws.com:~/miniwebapp/
```

**Archivos copiados**:
- `docker/` - Dockerfile, nginx.conf, entrypoint.sh
- `webapp/` - Código fuente de la aplicación Flask
- `init.sql` - Script de inicialización de base de datos

---

## 📤 PASO 4: Copiar Docker Compose

```powershell
scp -i "deployssh.pem" docker-compose.yml ubuntu@TU-INSTANCIA-EC2.compute-1.amazonaws.com:~/miniwebapp/
```

---

## 📤 PASO 5: Copiar Configuraciones de Monitoreo

```powershell
scp -i "deployssh.pem" -r prometheus grafana ubuntu@TU-INSTANCIA-EC2.compute-1.amazonaws.com:~/miniwebapp/
```

**Archivos copiados**:
- `prometheus/` - prometheus.yml, alerts.yml
- `grafana/` - dashboards, provisioning configs

---

## ⚙️ PASO 6: Dar Permisos de Ejecución

```powershell
ssh -i "deployssh.pem" ubuntu@TU-INSTANCIA-EC2.compute-1.amazonaws.com "cd ~/miniwebapp && chmod +x docker/entrypoint.sh"
```

---

## 🐳 PASO 7: Construir y Levantar Contenedores

```powershell
ssh -i "deployssh.pem" ubuntu@TU-INSTANCIA-EC2.compute-1.amazonaws.com "cd ~/miniwebapp && docker compose up -d --build"
```

**Contenedores que se crean**:
1. `miniwebapp-db` - MySQL 8.0
2. `miniwebapp-web` - Flask + Nginx + SSL
3. `miniwebapp-prometheus` - Prometheus
4. `miniwebapp-grafana` - Grafana
5. `miniwebapp-node-exporter` - Node Exporter

⏱️ **Tiempo estimado**: 3-5 minutos para build y start

---

## 📊 PASO 8: Ver Logs (Opcional)

### Ver logs de todos los servicios:
```powershell
ssh -i "deployssh.pem" ubuntu@TU-INSTANCIA-EC2.compute-1.amazonaws.com "cd ~/miniwebapp && docker compose logs --tail=50"
```

### Ver logs solo de la webapp:
```powershell
ssh -i "deployssh.pem" ubuntu@TU-INSTANCIA-EC2.compute-1.amazonaws.com "cd ~/miniwebapp && docker compose logs -f webapp"
```

---

## 🌐 PASO 9: Acceder a los Servicios

Reemplaza `TU-INSTANCIA-EC2` con tu DNS público de AWS:

### Aplicación Web:
- **HTTP**: `http://TU-INSTANCIA-EC2.compute-1.amazonaws.com`
- **HTTPS**: `https://TU-INSTANCIA-EC2.compute-1.amazonaws.com`

### Grafana (Monitoreo):
- **URL**: `http://TU-INSTANCIA-EC2.compute-1.amazonaws.com:3000`
- **Usuario**: `admin`
- **Password**: `admin`

### Prometheus (Métricas):
- **URL**: `http://TU-INSTANCIA-EC2.compute-1.amazonaws.com:9090`

### Node Exporter (Métricas del Sistema):
- **URL**: `http://TU-INSTANCIA-EC2.compute-1.amazonaws.com:9100/metrics`

---

## 🔧 Comandos Útiles para Administración

### Detener todos los servicios:
```powershell
ssh -i "deployssh.pem" ubuntu@TU-INSTANCIA-EC2.compute-1.amazonaws.com "cd ~/miniwebapp && docker compose down"
```

### Reiniciar todos los servicios:
```powershell
ssh -i "deployssh.pem" ubuntu@TU-INSTANCIA-EC2.compute-1.amazonaws.com "cd ~/miniwebapp && docker compose restart"
```

### Reiniciar solo la webapp:
```powershell
ssh -i "deployssh.pem" ubuntu@TU-INSTANCIA-EC2.compute-1.amazonaws.com "cd ~/miniwebapp && docker compose restart webapp"
```

### Ver uso de recursos:
```powershell
ssh -i "deployssh.pem" ubuntu@TU-INSTANCIA-EC2.compute-1.amazonaws.com "docker stats"
```

### Limpiar contenedores y volúmenes:
```powershell
ssh -i "deployssh.pem" ubuntu@TU-INSTANCIA-EC2.compute-1.amazonaws.com "cd ~/miniwebapp && docker compose down -v"
```

---

## 🗄️ Base de Datos MySQL

| Parámetro | Valor |
|-----------|-------|
| Motor | MySQL 8.0 |
| Base de datos | miniwebapp |
| Usuario | root |
| Password | root |
| Puerto | 3306 |

**Tablas**:
- `users` - Usuarios con datos de prueba (juan, maria)

---

## 🏗️ Arquitectura Desplegada

```
Internet
    ↓
AWS Security Group (22, 80, 443, 3000, 9090, 9100)
    ↓
EC2 Instance (Ubuntu 22.04)
    ↓
Docker Compose
    ├── miniwebapp-web (Nginx + Flask + Gunicorn)
    ├── miniwebapp-db (MySQL 8.0)
    ├── miniwebapp-prometheus (Prometheus)
    ├── miniwebapp-grafana (Grafana)
    └── miniwebapp-node-exporter (Node Exporter)
```

---

## ⚠️ Notas Importantes

1. **Certificado SSL**: Es autofirmado, el navegador mostrará advertencia (normal en desarrollo)
2. **Contraseñas**: Cambiar passwords de producción en `docker-compose.yml`
3. **Grafana**: Primera vez pedirá cambiar password de admin
4. **Firewall**: Solo abrir puertos necesarios en Security Group
5. **Backups**: Los datos de MySQL están en un volumen Docker persistente

---

## 🐛 Solución de Problemas

### Los contenedores no inician:
```powershell
ssh -i "deployssh.pem" ubuntu@TU-INSTANCIA-EC2.compute-1.amazonaws.com "cd ~/miniwebapp && docker compose logs"
```

### No puedo acceder a la webapp:
1. Verificar Security Group (puertos 80, 443 abiertos)
2. Verificar que contenedor webapp esté "Up"
3. Verificar logs: `docker compose logs webapp`

### Error de conexión a base de datos:
1. Esperar que MySQL esté "healthy": `docker compose ps`
2. Ver logs de MySQL: `docker compose logs db`

---

**Fecha de Creación**: 14 de Noviembre de 2025
