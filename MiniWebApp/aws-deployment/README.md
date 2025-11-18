# Guía de despliegue en AWS EC2 - MiniWebApp

## Requisitos previos

- Instancia EC2 Ubuntu 22.04 en AWS
- Archivo de clave denominado `deployssh.pem` con permisos configurados (0400)
- Security Group con puertos abiertos (22,80,443,3000,5000,9090,9100)

---

## PASO 0: Configurar el Security Group en AWS

Es necesario acceder a la consola de AWS EC2, sección **Security Groups**, y habilitar los siguientes puertos:

| Puerto | Protocolo | Descripción |
|--------|-----------|-------------|
| 22 | TCP | SSH |
| 80 | TCP | HTTP (Webapp) |
| 443 | TCP | HTTPS (Webapp) |
| 3000 | TCP | Grafana |
| 5000 | TCP | nginx Proxy |
| 9090 | TCP | Prometheus |
| 9100 | TCP | Node Exporter |

Source: `0.0.0.0/0` (o una dirección IP específica para mayor seguridad).

---

## PASO 1: Instalar Docker y Docker Compose en EC2

```powershell
# Exportamos la variable remoteHost como principio DRY (en Linux se usa export, en windows bajo powershell se define la variable)
# Copia según plataforma
#
# WINDOWS
# $remoteHost="TU-INSTANCIA-EC2.compute-1.amazonaws.com"
# 
# LINUX
# export remoteHost="TU-INSTANCIA-EC2.compute-1.amazonaws.com"
ssh -i "deployssh.pem" ubuntu@${remoteHost} "curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && sudo usermod -aG docker ubuntu && docker --version && docker compose version && echo 'Reiniciando para aplicar cambios de usermod...' && sudo reboot 0"
```

**Resultado esperado**: Visualizar las versiones instaladas de Docker y Docker Compose.

---

## PASO 2: Crear la estructura de directorios en EC2

```powershell
ssh -i "deployssh.pem" ubuntu@$remoteHost "mkdir -p ~/MiniWebApp/{docker,webapp,prometheus,grafana}"
```

---

## PASO 3: Copiar archivos de la aplicación

```powershell
scp -i "deployssh.pem" -r prometheus grafana docker webapp init.sql docker-compose.yml ubuntu@${remoteHost}:~/MiniWebApp/
```

**Archivos copiados**:

- `docker/` - Dockerfile, nginx.conf, entrypoint.sh
- `webapp/` - Código fuente de la aplicación Flask
- `prometheus/` - prometheus.yml, alerts.yml
- `grafana/` - dashboards, provisioning configs
- `init.sql` - Script de inicialización de base de datos
- `docker-compose.yml` - Archivo de configuración para docker compose

---

## PASO 4: Asignar permisos de ejecución y ejecutar compose

```powershell
ssh -i "deployssh.pem" ubuntu@${remoteHost} "cd ~/MiniWebApp && chmod +x docker/entrypoint.sh && docker compose up -d --build"
```

---

**Contenedores que se crean**:

1. `miniwebapp-db` - MySQL 8.0
2. `miniwebapp-web` - Flask + Nginx + SSL
3. `miniwebapp-prometheus` - Prometheus
4. `miniwebapp-grafana` - Grafana
5. `miniwebapp-node-exporter` - Node Exporter

**Tiempo estimado**: entre 3 y 5 minutos para construir y levantar los servicios.

---

## PASO 5: Revisar logs (opcional)

### Logs de todos los servicios

```powershell
ssh -i "deployssh.pem" ubuntu@${remoteHost} "cd ~/MiniWebApp && docker compose logs --tail=50"
```

### Logs únicamente de la webapp

```powershell
ssh -i "deployssh.pem" ubuntu@${remoteHost} "cd ~/MiniWebApp && docker compose logs -f webapp"
```

---

## PASO 6: Acceso a los servicios

Asegúrate de exportar `remoteHost` con el DNS público asignado por AWS antes de ejecutar los comandos.

### Aplicación web

- **HTTP**: `http://$remoteHost`
- **HTTPS**: `https://$remoteHost`

### Grafana (monitoreo)

- **URL**: `http://$remoteHost:3000`
- **Usuario**: `admin`
- **Password**: `admin`

### Prometheus (métricas)

- **URL**: `http://$remoteHost:9090`

### Node Exporter (métricas del sistema)

- **URL**: `http://$remoteHost:9100/metrics`

---

## Comandos útiles para administración

### Detener todos los servicios

```powershell
ssh -i "deployssh.pem" ubuntu@${remoteHost} "cd ~/MiniWebApp && docker compose down"
```

### Reiniciar todos los servicios

```powershell
ssh -i "deployssh.pem" ubuntu@${remoteHost} "cd ~/MiniWebApp && docker compose restart"
```

### Reiniciar únicamente la webapp

```powershell
ssh -i "deployssh.pem" ubuntu@${remoteHost} "cd ~/MiniWebApp && docker compose restart webapp"
```

### Consultar uso de recursos

```powershell
ssh -i "deployssh.pem" ubuntu@${remoteHost} "docker stats"
```

### Limpiar contenedores y volúmenes

```powershell
ssh -i "deployssh.pem" ubuntu@${remoteHost} "cd ~/MiniWebApp && docker compose down -v"
```

---

## Base de datos MySQL

| Parámetro | Valor |
|-----------|-------|
| Motor | MySQL 8.0 |
| Base de datos | miniwebapp |
| Usuario | root |
| Password | root |
| Puerto | 3306 |

**Tablas**:

- `users`: usuarios de prueba (juan, maria).

---

## Arquitectura desplegada

```text
Internet
    ↓
AWS Security Group (22, 80, 443, 3000, 5000, 9090, 9100)
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

## Notas importantes

1. **Certificado SSL**: es autofirmado, por lo que el navegador mostrará una advertencia (comportamiento esperado en entornos de desarrollo).
2. **Contraseñas**: se recomienda actualizar las credenciales definitivas en `docker-compose.yml` antes de un despliegue productivo.
3. **Grafana**: en el primer acceso se solicitará cambiar la contraseña del usuario administrador.
4. **Firewall**: únicamente deben abrirse los puertos estrictamente necesarios en el Security Group.
5. **Backups**: los datos de MySQL se alojan en un volumen persistente de Docker; considerar respaldos periódicos.

---

## Solución de problemas

### Contenedores que no inician

```powershell
ssh -i "deployssh.pem" ubuntu@${remoteHost} "cd ~/miniwebapp && docker compose logs"
```

### Imposible acceder a la webapp

1. Verificar el Security Group (puertos 80 y 443 abiertos).
2. Confirmar que el contenedor webapp esté en estado "Up".
3. Revisar los registros con `docker compose logs webapp`.

### Error de conexión a la base de datos

1. Esperar a que MySQL aparezca como "healthy" mediante `docker compose ps`.
2. Revisar los registros de MySQL con `docker compose logs db`.

---

**Fecha de Actualización**: 17 de Noviembre de 2025
