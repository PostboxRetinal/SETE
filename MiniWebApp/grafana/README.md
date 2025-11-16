# Configuración de Grafana - CloudNova

## Dashboards incluidos

### 1. CloudNova System Monitoring (dashboard personalizado)

- **Archivo**: `cloudnova-system.json`
- **Descripción**: Dashboard personalizado con paneles de sistema
- **Paneles incluidos**:
  - **CPU Usage** (Gauge): Porcentaje de uso de CPU en tiempo real
  - **Memory Available** (Gauge): Porcentaje de memoria disponible
  - **Disk Space Available** (Gauge): Porcentaje de espacio en disco disponible
  - **CPU Usage Over Time** (Graph): Histórico de uso de CPU
  - **Memory Usage Over Time** (Graph): Histórico de uso de memoria
  - **Network Traffic** (Graph): Tráfico de red (recibido/transmitido)
  - **Disk Usage** (Graph): Uso de disco en el tiempo

### 2. Node Exporter Full (dashboard preconfigurado)

- **ID**: 1860
- **Descripción**: Dashboard oficial completo de Node Exporter
- **Incluye**: Métricas detalladas de CPU, memoria, disco, red, sistema de archivos

## Importar dashboards preconfigurados

### Opción 1: mediante la interfaz de Grafana

1. Acceder a Grafana: <http://localhost:3000>.
2. Iniciar sesión con las credenciales `admin`/`admin`.
3. Seleccionar el botón "+" y la opción **Import**.
4. Indicar el ID **1860** (Node Exporter Full).
5. Elegir "Prometheus" como origen de datos.
6. Confirmar la importación.

### Opción 2: mediante script (automatizado)

```bash
# El dashboard se puede importar automáticamente con la API de Grafana
curl -X POST http://admin:admin@localhost:3000/api/dashboards/import \
  -H "Content-Type: application/json" \
  -d '{
    "dashboard": {
      "id": 1860
    },
    "overwrite": true,
    "inputs": [{
      "name": "DS_PROMETHEUS",
      "type": "datasource",
      "pluginId": "prometheus",
      "value": "Prometheus"
    }]
  }'
```

## Configuración automática

El provisioning de Grafana está configurado para:

- Cargar automáticamente Prometheus como datasource
- Importar dashboards desde `/var/lib/grafana/dashboards`
- Actualizar dashboards cada 10 segundos
- Permitir ediciones desde la UI

## Credenciales predeterminadas

- **Usuario**: admin
- **Contraseña**: admin
- **Puerto**: 3000

## Estructura de archivos

```text
grafana/
├── provisioning/
│   ├── datasources/
│   │   └── prometheus.yml       # Configuración de Prometheus
│   └── dashboards/
│       └── dashboards.yml        # Configuración de dashboards
└── dashboards/
    └── cloudnova-system.json     # Dashboard personalizado
```

## Dashboards recomendados adicionales

| ID    | Nombre                                 | Descripción                                |
| ----- | -------------------------------------- | ------------------------------------------ |
| 1860  | Node Exporter Full                     | Dashboard completo de métricas del sistema |
| 893   | Docker & System Monitoring             | Monitoreo de contenedores Docker           |
| 11074 | Node Exporter for Prometheus Dashboard | Dashboard alternativo optimizado           |
| 13978 | Docker Container & Host Metrics        | Métricas de containers y host              |

## Procedimiento de verificación

Para confirmar que Grafana opera correctamente se pueden utilizar los siguientes comandos:

```bash
# Verificar que el contenedor está corriendo
docker compose ps grafana

# Ver logs de Grafana
docker compose logs -f grafana

# Probar la API
curl http://localhost:3000/api/health
```

## Solución de problemas

### Dashboard sin datos

1. Verificar que Prometheus esté en ejecución: `http://localhost:9090/targets`.
2. Revisar el datasource en Grafana: Configuration → Data Sources → Prometheus.
3. Ejecutar la consulta directamente en Prometheus.

### Acceso a Grafana rechazado

1. Confirmar que el puerto 3000 no esté ocupado.
2. Revisar los registros con `docker compose logs grafana`.
3. Validar la configuración de firewall o reglas de red.

### Dashboard sin carga automática

1. Verificar la existencia de archivos en `grafana/dashboards/`.
2. Revisar la configuración en `grafana/provisioning/dashboards/dashboards.yml`.
3. Reiniciar el contenedor con `docker compose restart grafana`.
