# Configuración de Grafana - CloudNova

## Dashboards Incluidos

### 1. CloudNova System Monitoring (Dashboard personalizado)
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

### 2. Node Exporter Full (Dashboard preconfigurado)
- **ID**: 1860
- **Descripción**: Dashboard oficial completo de Node Exporter
- **Incluye**: Métricas detalladas de CPU, memoria, disco, red, sistema de archivos

## Importar Dashboard Preconfigurado

### Opción 1: Desde la interfaz de Grafana
1. Accede a Grafana: http://localhost:3000
2. Inicia sesión (admin/admin)
3. Click en "+" → "Import"
4. Ingresa el ID: **1860** (Node Exporter Full)
5. Selecciona "Prometheus" como datasource
6. Click en "Import"

### Opción 2: Mediante script (automatizado)
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

## Configuración Automática

El provisioning de Grafana está configurado para:
- Cargar automáticamente Prometheus como datasource
- Importar dashboards desde `/var/lib/grafana/dashboards`
- Actualizar dashboards cada 10 segundos
- Permitir ediciones desde la UI

## Credenciales por Defecto
- **Usuario**: admin
- **Contraseña**: admin
- **Puerto**: 3000

## Estructura de Archivos
```
grafana/
├── provisioning/
│   ├── datasources/
│   │   └── prometheus.yml       # Configuración de Prometheus
│   └── dashboards/
│       └── dashboards.yml        # Configuración de dashboards
└── dashboards/
    └── cloudnova-system.json     # Dashboard personalizado
```

## Dashboards Recomendados Adicionales

| ID   | Nombre | Descripción |
|------|--------|-------------|
| 1860 | Node Exporter Full | Dashboard completo de métricas del sistema |
| 893  | Docker & System Monitoring | Monitoreo de contenedores Docker |
| 11074 | Node Exporter for Prometheus Dashboard | Dashboard alternativo optimizado |
| 13978 | Docker Container & Host Metrics | Métricas de containers y host |

## Verificación

Para verificar que Grafana está funcionando correctamente:

```bash
# Verificar que el contenedor está corriendo
docker-compose ps grafana

# Ver logs de Grafana
docker-compose logs -f grafana

# Probar la API
curl http://localhost:3000/api/health
```

## Solución de Problemas

### Dashboard no muestra datos
1. Verificar que Prometheus está corriendo: `http://localhost:9090/targets`
2. Verificar datasource en Grafana: Configuration → Data Sources → Prometheus
3. Probar query directamente en Prometheus

### No se puede acceder a Grafana
1. Verificar que el puerto 3000 no esté ocupado
2. Revisar logs: `docker-compose logs grafana`
3. Verificar firewall/puertos

### Dashboard no se carga automáticamente
1. Verificar archivos en `grafana/dashboards/`
2. Revisar configuración en `grafana/provisioning/dashboards/dashboards.yml`
3. Reiniciar contenedor: `docker-compose restart grafana`
