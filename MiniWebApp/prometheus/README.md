# Documentación de Métricas - Prometheus & Node Exporter

## CloudNova - Servicios Telemáticos

### Métricas Clave del Sistema (Node Exporter)

#### 1. **node_cpu_seconds_total**

- **Descripción**: Tiempo total de CPU consumido por núcleo en diferentes modos (user, system, idle, etc.)
- **Tipo**: Counter
- **Utilidad en Monitoreo Linux**:
  - Permite calcular el porcentaje de uso de CPU en tiempo real
  - Identifica cuellos de botella de procesamiento
  - Útil para dimensionamiento de recursos y detección de procesos que consumen CPU excesiva
  - Fórmula común: `100 - (rate(node_cpu_seconds_total{mode="idle"}[5m]) * 100)` para obtener % de uso
- **Ejemplo de uso**:

  ```promql
  # CPU usage por instancia
  100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
  ```

#### 2. **node_memory_MemAvailable_bytes**

- **Descripción**: Cantidad de memoria RAM disponible para nuevas aplicaciones sin swap
- **Tipo**: Gauge
- **Utilidad en Monitoreo Linux**:
  - Monitorea la salud de memoria del sistema
  - Previene problemas de OOM (Out of Memory)
  - Ayuda a identificar memory leaks en aplicaciones
  - Esencial para planificación de capacidad y alertas proactivas
- **Métricas relacionadas**:
  - `node_memory_MemTotal_bytes`: Memoria total
  - `node_memory_MemFree_bytes`: Memoria libre
  - `node_memory_Cached_bytes`: Memoria en caché
- **Ejemplo de uso**:

  ```promql
  # Porcentaje de memoria disponible
  (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100
  ```

#### 3. **node_filesystem_avail_bytes**

- **Descripción**: Espacio disponible en el sistema de archivos en bytes
- **Tipo**: Gauge
- **Utilidad en Monitoreo Linux**:
  - Previene saturación de disco que causa caídas de servicio
  - Identifica particiones que requieren limpieza o expansión
  - Crítico para logs, bases de datos y aplicaciones que escriben en disco
  - Permite planificar backups y migraciones antes de problemas críticos
- **Labels importantes**:
  - `mountpoint`: punto de montaje (/, /home, /var, etc.)
  - `fstype`: tipo de sistema de archivos (ext4, xfs, etc.)
- **Ejemplo de uso**:

  ```promql
  # Porcentaje de espacio disponible en disco raíz
  (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100
  ```

### Otras Métricas Importantes

#### 4. **node_network_receive_bytes_total /

node_network_transmit_bytes_total**

- **Descripción**: Total de bytes recibidos/transmitidos por interfaz de red
- **Utilidad**: Monitoreo de ancho de banda, detección de ataques DDoS, análisis de tráfico

#### 5. **node_disk_io_time_seconds_total**

- **Descripción**: Tiempo total que el disco ha estado ocupado procesando I/O
- **Utilidad**: Identificar cuellos de botella de I/O, optimizar rendimiento de disco

#### 6. **node_load1 / node_load5 / node_load15**

- **Descripción**: Promedio de carga del sistema (1, 5 y 15 minutos)
- **Utilidad**: Indicador general de salud del sistema, incluye procesos en espera

### Configuración de Alertas

Las alertas configuradas en `alerts.yml` incluyen:

- CPU > 80% (warning) y > 90% (critical)
- Memoria disponible < 20% (warning) y < 10% (critical)
- Espacio en disco < 20% (warning) y < 10% (critical)

### Recursos Adicionales

- [Prometheus Query Examples](https://prometheus.io/docs/prometheus/latest/querying/examples/)
- [Node Exporter Full Metric List](https://github.com/prometheus/node_exporter)
- [PromQL Cheat Sheet](https://promlabs.com/promql-cheat-sheet/)
