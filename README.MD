# Servicios Telemáticos

Repositorio académico para la materia **Servicios Telemáticos**. Cada rama documenta las configuraciones, prácticas y parciales desarrollados durante el semestre.

## Segundo Parcial (`segundoCorte`)

### Objetivo del trabajo

Implementar firewall UFW que publica servicios DNS y FTP con alta disponibilidad y conexiones cifradas, reutilizando las direcciones de laboratorio `192.168.56.0/24`.

### Roles y responsabilidades

| Rol | IP recomendada | Función | Archivos relevantes |
| --- | --- | --- | --- |
| **Firewall / Borde** | `192.168.56.4` | Redirige tráfico externo, aplica DNAT/SNAT y reglas previas de UFW | `etc/ufw/before.rules`, `ufwOutput.txt`, `etc/default/ufw` |
| **DNS Maestro + FTP** | `192.168.56.2` | Aloja BIND maestro y vsftpd con TLS; responde a DNAT del firewall | `bind/named.conf.options`, `bind/named.conf.local`, `etc/vsftpd.conf`, `etc/vsftpd.chroot_list`, `etc/vsftpd.userlist`, `etc/ssl/private/vsftpd.pem` |
| **DNS Esclavo** | `192.168.56.3` | Replica zonas directa e inversa desde el maestro | `bind_esclavo/named.conf.local`, `bind_esclavo/named.conf.options` |

### DNS BIND9 (Maestro y Esclavo)

- Dominio principal: `empresa.local` con zona inversa `56.168.192.in-addr.arpa`.
- Transferencias AXFR permitidas únicamente hacia los esclavos (`192.168.56.3` y reserva `192.168.56.4`).
- Los archivos `bind/db.empresa.local` y `bind/db.192` contienen los registros A, PTR y CNAME requeridos por la guía del parcial.
- El esclavo en `bind_esclavo/` apunta al maestro (`192.168.56.2`) y almacena las zonas bajo `/var/cache/bind/`.

### FTP seguro (vsftpd)

- Acceso exclusivo a usuarios locales autorizados en `etc/vsftpd.userlist` y enjaulados mediante `chroot_local_user=YES` con excepciones definidas en `etc/vsftpd.chroot_list`.
- Cifrado TLS forzado (`force_local_logins_ssl=YES`, `force_local_data_ssl=YES`) usando el certificado empaquetado en `etc/ssl/private/vsftpd.pem`.
- Modo pasivo restringido a los puertos `40000-40010`, coherente con las reglas DNAT del firewall.
- Banner de servicio personalizado y auditoría de comandos (`log_ftp_protocol=YES`).

### Cortafuegos UFW

- Regla DNAT para publicar FTP y sus puertos pasivos desde el firewall hacia el maestro.
- Redirección de consultas DNS (UDP/TCP 53) hacia el esclavo, manteniendo alta disponibilidad si el maestro se cae.
- MASQUERADE post-routing para que las respuestas regresen al cliente original.
- El archivo `ufwOutput.txt` documenta el estado del firewall tras aplicar las reglas requeridas en el parcial.

### Guía de despliegue

1. **Firewall**: Copia `etc/ufw/before.rules` a `/etc/ufw/before.rules`, ajusta las IP si tu laboratorio difiere y reinicia UFW (`ufw reload`).
2. **DNS Maestro**: Coloca los archivos de `bind/` en `/etc/bind/`, verifica permisos y reinicia el servicio (`systemctl restart bind9`).
3. **DNS Esclavo**: Replica `bind_esclavo/` en el segundo nodo, asegurando conectividad TCP 53 hacia el maestro.
4. **FTP Seguro**: Sustituye `/etc/vsftpd.conf`, `vsftpd.chroot_list` y `vsftpd.userlist` por los provistos en `etc/` y despliega el certificado TLS en `/etc/ssl/private/` con permisos `600`.
5. **Validación**: Ejecuta `dig @192.168.56.3 empresa.local A`, realiza transferencias AXFR (`dig AXFR empresa.local @192.168.56.2`) y prueba el FTP en modo pasivo (`ftp -p 192.168.56.4`).

### Evidencias y documentación

- El archivo `2025-03 Segundo Parcial ServiciosTelematicos.pdf` resume los requerimientos originales del encargo.
- `ufwOutput.txt` y los archivos de configuración capturan la entrega final lista para calificación.

## Autores

Juan Eduardo Jaramillo y Sebastian Balanta 🔥
