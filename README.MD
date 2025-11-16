# Servicios Telemáticos

Repositorio académico del curso **Servicios Telemáticos**. En la rama `examenFinal` se aloja una mini aplicación web instrumentada y lista para desplegar con contenedores, monitoreo y scripts de automatización.

## Estructura principal

```text
MiniWebApp/
├── docker-compose.yml        # Orquestación local de toda la solución
├── init.sql                  # Semillas y esquema base para MySQL
├── docker/                   # Imagen de la aplicación (Flask + Nginx)
├── webapp/                   # Código fuente de la aplicación Flask
├── prometheus/               # Configuración y reglas de alertas
├── grafana/                  # Dashboards y provisioning
├── aws-deployment/           # Scripts para despliegue remoto
└── Vagrantfile               # Alternativa para laboratorio en VM
```

## Componentes

| Servicio / Recurso | Ubicación | Descripción |
| --- | --- | --- |
| **Aplicación web** | `webapp/` | Flask + Blueprints para CRUD de usuarios, templates en `web/templates` y assets en `web/static`. Configuración en `config.py` con SQLAlchemy apuntando a MySQL. |
| **Base de datos** | `docker-compose.yml` (`db`) | Contenedor `mysql:8.0` inicializado con `init.sql`. Expone el puerto `3306` y usa un volumen persistente. |
| **Reverse proxy** | `docker/Dockerfile`, `docker/nginx.conf` | Imagen multi-stage con nginx sirviendo HTTP/HTTPS (puertos 80/443). |
| **Prometheus** | `prometheus/` | Scrapea la aplicación y `node-exporter`, incluye `alerts.yml` para reglas básicas. |
| **Node Exporter** | `docker-compose.yml` (`node-exporter`) | Exporta métricas del host para Prometheus. |
| **Grafana** | `grafana/` | Provisioning automático de datasources y dashboard (`cloudnova-system.json`). |
| **Automatización AWS** | `aws-deployment/` | `deploy.sh` y `docker-compose-aws.yml` para levantar la misma arquitectura en una instancia remota. |

## Puesta en marcha local

1. Contar con Docker y Docker Compose instalados.
1. Desde la raíz del repositorio ejecutar:

```bash
cd MiniWebApp
# Es necesario instalar el plugin para reiniciar durante el aprovisionamiento de la VM
vagrant plugin install vagrant-reload
vagrant up
```

1. Servicios expuestos:
   - Aplicación web: [https://localhost](https://localhost) con redirección a HTTPS mediante Nginx.
   - API Flask: expuesta detrás de Nginx en el mismo contenedor.
   - Prometheus: [http://localhost:9090](http://localhost:9090).
   - Node Exporter: [http://localhost:9100/metrics](http://localhost:9100/metrics).
   - Grafana: [http://localhost:3000](http://localhost:3000) con credenciales predeterminadas `admin`/`admin`.

1. Para detener y limpiar la VM:

```bash
vagrant halt
```

> El archivo `Vagrantfile` permite recrear una VM Ubuntu con todo el stack en caso de requerir un entorno aislado.

## Observabilidad

- **Prometheus**: Configurado en `prometheus/prometheus.yml` para levantar `node-exporter`, la app Flask y generar alertas básicas (CPU, uso de memoria, disponibilidad del contenedor web).
- **Grafana**: Provisiona automáticamente el datasource Prometheus (`grafana/provisioning/datasources/prometheus.yml`) y carga el dashboard `cloudnova-system.json`. Personaliza paneles adicionales guardándolos en `grafana/dashboards/`.

## Despliegue en AWS

En `aws-deployment/` se incluyen los siguientes recursos:

- `docker-compose-aws.yml`: plantilla preparada para EC2/VM con certificados gestionados externamente.
- `deploy.sh`: script que copia archivos al servidor remoto y ejecuta la pila mediante SSH.
- `README.md`: pasos detallados para preparar la instancia (seguridad, variables, certificados).

## Autores

- Juan Eduardo Jaramillo
- Sebastián Balanta
