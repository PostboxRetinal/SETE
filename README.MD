# Servicios Telemáticos

Repositorio académico del curso **Servicios Telemáticos**. En la rama `examenFinal` se aloja una mini aplicación web instrumentada y lista para desplegar con contenedores, monitoreo y scripts de automatización.

## Estructura principal

```text
MiniWebApp/
├── aws-deployment/           # README con el paso a paso para desplegar en AWS
├── docker/                   # Imagen de la aplicación (Flask + Nginx)
├── grafana/                  # Dashboards y provisioning
├── prometheus/               # Configuración y reglas de alertas
├── webapp/                   # Código fuente de la aplicación Flask
├── docker-compose.yml        # Orquestación local de toda la solución
├── init.sql                  # Semillas y esquema base para MySQL
└── Vagrantfile               # Alternativa para laboratorio en VM
```

## Componentes

| Servicio / Recurso | Ubicación | Descripción |
| --- | --- | --- |
| **Automatización AWS** | `aws-deployment/` | `README.MD` para levantar la misma arquitectura en una instancia remota de AWS. |
| **Aplicación web** | `webapp/` | Flask + Blueprints para CRUD de usuarios, templates en `web/templates` y assets en `web/static`. Configuración en `config.py` con SQLAlchemy apuntando a MySQL. |
| **Base de datos** | `docker-compose.yml` (`db`) | Contenedor `mysql:8.0` inicializado con `init.sql`. Expone el puerto `3306` y usa un volumen persistente. |
| **Grafana** | `grafana/` | Provisioning automático de datasources y dashboard (`cloudnova-system.json`). |
| **Reverse proxy** | `docker/Dockerfile`, `docker/nginx.conf` | nginx sirviendo HTTP/HTTPS (puertos 80/443). |
| **Node Exporter** | `docker-compose.yml` (`node-exporter`) | Exporta métricas del host para Prometheus. |
| **Prometheus** | `prometheus/` | Scrapea la aplicación y `node-exporter`, incluye `alerts.yml` para reglas básicas. |

## Puesta en marcha local

1. Contar con Docker y Docker Compose previamente instalados.
1. Desde la raíz del repositorio ejecutar:

```bash
cd MiniWebApp
vagrant up
```

1. Todos los servicios expuestos con redirección a HTTPS y único punto de acceso mediante el proxy nginx _(buena práctica DevSecOps para microservicios)_
   - MiniWebApp: [https://192.168.60.10](https://192.168.60.10).
   - Prometheus: [https://192.168.60.10/prometheus](https://192.168.60.10/prometheus).
   - Grafana: [https://192.168.60.10/grafana](https://192.168.60.10/grafana).
   - Node Exporter: [https://192.168.60.10/node-exporter](https://192.168.60.10/node-exporter).

2. Para detener y borrar la VM:

```bash
vagrant halt
vagrant destroy
```

## Observabilidad

- **Prometheus**: Configurado en `prometheus/prometheus.yml` para levantar `node-exporter`, la app Flask y generar alertas básicas (CPU, uso de memoria, disponibilidad del contenedor web).
- **Grafana**: Provisiona automáticamente el datasource Prometheus (`grafana/provisioning/datasources/prometheus.yml`) y carga el dashboard `cloudnova-system.json`. Personaliza paneles adicionales guardándolos en `grafana/dashboards/`.

## Despliegue en AWS

En `aws-deployment/` se incluye un `README.md` con pasos detallados para desplegar esta instancia local en el provider sugerido (AWS).

---

## Reflexiones y aprendizajes

### ¿Qué aprendimos al integrar Docker, AWS y Prometheus?

La integración de estas tecnologías nos permitió reforzar cómo construir una arquitectura moderna de microservicios con DevOps integrada desde su arranque. Reforzamos conocimeintos en orquestración de múltiples contenedores con docker/podman compose, configurar reverse proxies con SSL, y establecer un stack completo de monitoreo con Prometheus y Grafana. La experiencia en AWS nos mostró las diferencias entre desarrollo local y despliegue en la nube, especialmente en temas de networking, seguridad y gestión de recursos.

### ¿Qué fue lo más desafiante y cómo lo resolverían en un entorno real?

Creemos que lo más desafiante fue configurar correctamente el routing de las aplicaciones detrás del reverse proxy nginx, especialmente cuando servicios como Prometheus y Grafana requieren configuraciones específicas para funcionar bajo subpaths y poder ser redirigios. En un entorno real, esto se resolvería utilizando un API Gateway (similar al implementado) que maneje automáticamente el routing, junto con algo como RabbitMQ para manejar colas de peticiones entre servicios de forma más robusta y finalmente un load balancer que garantice disponibilidad y uptime constantes (idealmente, cabe aclarar).

### ¿Qué beneficios aporta la observabilidad en el ciclo DevOps?

La observabilidad permite detectar problemas antes de que afecten a los usuarios finales, reduciendo el MTTR (Mean Time To Recovery). Con métricas en tiempo real, logs centralizados y dashboards automatizados, los equipos pueden tomar decisiones basadas en datos reales del sistema. Además, facilita la cultura de CI/CD al proporcionar visibilidad sobre el rendimiento de las aplicaciones, permitiendo optimizaciones y una mejor planificación de capacidad.

---

## Desarrollado por

- Juan Eduardo Jaramillo | [@JuanJaramillo12004](https://github.com/JuanJaramillo12004)
- Sebastián Balanta | [@PostboxRetinal](https://github.com/PostboxRetinal)
