# Mejores Prácticas para Producción en Oracle Cloud

## Tu Infraestructura
- **VM**: Oracle Cloud VM.Standard.A1.Flex
- **CPU**: 4 OCPU
- **RAM**: 24 GB
- **Red**: 4 Gbps
- **Apps**: Bot (puerto 3002) + Pilates (puerto 3000) - **Pilates es crítica**

## 🎯 Mejores Prácticas Recomendadas

### 1. **Systemd para Gestionar las Apps (RECOMENDADO)**

Systemd es la mejor opción porque:
- ✅ Se inicia automáticamente al reiniciar el servidor
- ✅ Reinicia automáticamente si la app crashea
- ✅ Gestiona logs centralizados
- ✅ Fácil de monitorear y gestionar

#### Crear servicio para Pilates:

```bash
sudo nano /etc/systemd/system/pilates.service
```

Contenido:

```ini
[Unit]
Description=Pilates App (Rails)
After=network.target postgresql.service

[Service]
Type=simple
User=deploy
WorkingDirectory=/home/deploy/apps/pilates
Environment="RAILS_ENV=production"
EnvironmentFile=/home/deploy/apps/pilates/.env
ExecStart=/home/deploy/.rbenv/shims/bundle exec puma -C /home/deploy/apps/pilates/config/puma.rb
Restart=always
RestartSec=10
StandardOutput=append:/home/deploy/apps/pilates/log/puma.stdout.log
StandardError=append:/home/deploy/apps/pilates/log/puma.stderr.log

[Install]
WantedBy=multi-user.target
```

**Importante**: Ajusta la ruta de bundle según tu instalación:
```bash
# Verificar ruta de bundle
which bundle
# Ejemplo: /home/deploy/.rbenv/shims/bundle
```

#### Activar y iniciar:

```bash
# Recargar systemd
sudo systemctl daemon-reload

# Habilitar para que inicie al boot
sudo systemctl enable pilates

# Iniciar servicio
sudo systemctl start pilates

# Ver estado
sudo systemctl status pilates

# Ver logs
sudo journalctl -u pilates -f
```

#### Comandos útiles:

```bash
# Reiniciar
sudo systemctl restart pilates

# Detener
sudo systemctl stop pilates

# Ver logs
sudo journalctl -u pilates -n 50
sudo journalctl -u pilates -f
```

### 2. **Configuración de Caddy (Reverse Proxy)**

#### Configuración recomendada para Pilates:

```bash
sudo nano /etc/caddy/Caddyfile
```

```caddyfile
# Caddy reverse proxy para Pilates (Puma en 127.0.0.1:3000)
# Si todavía no tenés dominio, podés usar la IP pública:
:80 {
	encode gzip zstd

	# Logs
	log {
		output file /var/log/caddy/pilates_access.log
	}

	# Assets estáticos (opcional: útil si querés que Caddy los sirva directo)
	@assets path /assets/*
	handle @assets {
		root * /home/deploy/apps/pilates/public
		file_server
		header Cache-Control "public, max-age=31536000, immutable"
	}

	# Health check
	@up path /up
	handle @up {
		reverse_proxy 127.0.0.1:3000
	}

	# App Rails
	handle {
		reverse_proxy 127.0.0.1:3000 {
			header_up Host {host}
			header_up X-Real-IP {remote_host}
			header_up X-Forwarded-For {remote_host}
			header_up X-Forwarded-Proto {scheme}
		}
	}
}
```

#### Activar configuración:

```bash
# Validar config
sudo caddy validate --config /etc/caddy/Caddyfile

# Recargar sin cortar conexiones (recomendado)
sudo systemctl reload caddy

# O reiniciar si hace falta
sudo systemctl restart caddy
```

### 3. **Configuración de Puma (Optimizada)**

Tu `config/puma.rb` ya está bien, pero asegúrate de que `.env` tenga:

```bash
# En ~/apps/pilates/.env
RAILS_ENV=production
RAILS_MAX_THREADS=5
BIND=127.0.0.1
PORT=3000
```

**Recomendación para tu hardware (4 CPU, 24GB RAM):**

```ruby
# En config/puma.rb puedes agregar:
workers ENV.fetch("WEB_CONCURRENCY", 2)  # 2 workers para 4 CPUs
```

Y en `.env`:
```bash
WEB_CONCURRENCY=2
```

### 4. **Monitoreo y Logs**

#### Ver logs en tiempo real:

```bash
# Logs de systemd
sudo journalctl -u pilates -f

# Logs de Caddy
sudo journalctl -u caddy -f
sudo tail -f /var/log/caddy/pilates_access.log

# Logs de Rails (si los crea)
tail -f ~/apps/pilates/log/production.log
```

#### Monitoreo básico:

```bash
# Ver uso de recursos
htop

# Ver procesos de Rails
ps aux | grep -E "(rails|puma)" | grep -v grep

# Ver conexiones
sudo ss -tlnp | grep -E "(3000|3002)"
```

### 5. **Seguridad**

#### Firewall (UFW):

```bash
# Instalar si no está
sudo apt install ufw

# Configurar
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp     # HTTP
sudo ufw allow 443/tcp    # HTTPS (si usas SSL)

# Activar
sudo ufw enable
sudo ufw status
```

#### Actualizar sistema:

```bash
sudo apt update && sudo apt upgrade -y
```

### 6. **Backup Automático**

#### Script de backup de base de datos:

```bash
# Crear directorio de backups
mkdir -p ~/backups

# Crear script
nano ~/backup_pilates.sh
```

Contenido del script:

```bash
#!/bin/bash
BACKUP_DIR=~/backups
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME=clases_pilates_production
DB_USER=clases_pilates

# Backup de base de datos
pg_dump -U $DB_USER -h localhost $DB_NAME | gzip > $BACKUP_DIR/pilates_$DATE.sql.gz

# Mantener solo los últimos 7 días
find $BACKUP_DIR -name "pilates_*.sql.gz" -mtime +7 -delete

echo "Backup completado: pilates_$DATE.sql.gz"
```

Hacer ejecutable:

```bash
chmod +x ~/backup_pilates.sh
```

#### Agregar a crontab (backup diario a las 2 AM):

```bash
crontab -e
```

Agregar:
```
0 2 * * * /home/deploy/backup_pilates.sh >> /home/deploy/backups/backup.log 2>&1
```

### 7. **Optimización de PostgreSQL**

Para tu hardware (4 CPU, 24GB RAM):

```bash
sudo nano /etc/postgresql/*/main/postgresql.conf
```

Ajustes recomendados:

```conf
# Memoria (usar ~25% de RAM = 6GB)
shared_buffers = 6GB
effective_cache_size = 18GB
maintenance_work_mem = 1GB
work_mem = 64MB

# Conexiones
max_connections = 100

# Logs
log_min_duration_statement = 1000  # Log queries > 1 segundo
```

Reiniciar PostgreSQL:
```bash
sudo systemctl restart postgresql
```

### 8. **Estructura de Directorios Recomendada**

```
/home/deploy/
├── apps/
│   ├── pilates/          # App principal (CRÍTICA)
│   │   ├── .env
│   │   ├── log/
│   │   └── ...
│   └── bot/              # Bot (secundaria)
│       └── ...
├── backups/              # Backups de BD
│   └── pilates_*.sql.gz
└── scripts/              # Scripts útiles
    └── backup_pilates.sh
```

### 9. **Checklist de Producción**

- [ ] Systemd configurado para pilates
- [ ] Caddy configurado como reverse proxy
- [ ] Firewall (UFW) activado
- [ ] Backups automáticos configurados
- [ ] Logs centralizados
- [ ] PostgreSQL optimizado
- [ ] Variables de entorno en `.env`
- [ ] SSL/HTTPS configurado (recomendado)
- [ ] Monitoreo básico funcionando

### 10. **Comandos de Emergencia**

```bash
# Reiniciar todo
sudo systemctl restart pilates caddy postgresql

# Ver qué está fallando
sudo systemctl status pilates caddy postgresql

# Ver logs de errores
sudo journalctl -u pilates -n 100 --no-pager
sudo journalctl -u caddy -n 200 --no-pager

# Reiniciar servidor completo
sudo reboot
```

## 🚀 Prioridades

1. **CRÍTICO**: Systemd para pilates (auto-inicio y auto-restart)
2. **IMPORTANTE**: Caddy bien configurado
3. **IMPORTANTE**: Backups automáticos
4. **RECOMENDADO**: SSL/HTTPS
5. **OPCIONAL**: Monitoreo avanzado

## 📊 Recursos Recomendados

Con tu hardware (4 CPU, 24GB):
- **Pilates**: 2 workers, 5 threads = ~10 conexiones concurrentes
- **Bot**: 1 worker, 3 threads = ~3 conexiones concurrentes
- **PostgreSQL**: 6GB shared_buffers
- **Caddy**: Muy ligero, no consume mucho

Tienes recursos de sobra para ambas apps.

