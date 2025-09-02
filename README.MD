
# SETE - Servicios Telemáticos 1C

Archivos de configuración para servicios de red Apache2 y BIND9 del primer parcial.

## Arquitectura

- **Dominio**: `empresa.local`
- **Red**: `192.168.51.0/24`
- **DNS Maestro**: `192.168.51.2`
- **DNS Esclavo**: `192.168.51.3`

## Estructura

### Apache2

Configuración del servidor web con autenticación PAM.

**Archivos principales:**

- `apache2.conf` - Configuración principal
- `apache_blacklist.conf` - Control de acceso (excepción user3)
- `sites-available/000-default.conf` - Sitio virtual con directorio protegido

### PAM (pam.d/)

Configuración de autenticación PAM para Apache2.

**Archivos principales:**

- `apache2` - Módulos PAM para autenticación
  - `pam_access.so` - Control de acceso usando apache_blacklist.conf
  - `pam_unix.so` - Autenticación de usuarios del sistema

### BIND9

Servidor DNS con resolución directa e inversa.

**Archivos principales:**

- `named.conf.local` - Zonas DNS locales
- `named.conf.options` - Configuración global
- `db.empresa.local` - Zona directa
- `db.192` - Zona inversa
  
#### Registros configurados

- Servidores:
  - maestro (192.168.51.2)
  - esclavo (192.168.51.3)

- Web: `www.empresa.local` (192.168.51.2)

- Testing:
  - smb-windows (192.168.51.10)
  - smb-alterno (192.168.51.11)
- CNAMEs:
  - web→www
  - ftp→maestro
  - mail→maestro
  - staging→smb-windows
  - production→smb-alterno
