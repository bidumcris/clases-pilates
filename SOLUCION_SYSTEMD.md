# Solución para Systemd - Cargar Variables de Entorno

## Problema
Systemd no está cargando el `.env` correctamente, causando que SolidCable no encuentre la configuración de base de datos.

## Solución: Actualizar el Servicio de Systemd

Edita el servicio para cargar explícitamente las variables del `.env`:

```bash
sudo nano /etc/systemd/system/pilates.service
```

Reemplaza con esta configuración (que carga el .env correctamente):

```ini
[Unit]
Description=Pilates App (Rails)
After=network.target postgresql.service

[Service]
Type=simple
User=deploy
WorkingDirectory=/home/deploy/apps/pilates
Environment="RAILS_ENV=production"
Environment="PATH=/home/deploy/.rbenv/shims:/home/deploy/.rbenv/bin:/usr/local/bin:/usr/bin:/bin"

# Cargar variables del .env manualmente
Environment="CLASES_PILATES_DATABASE_NAME=clases_pilates_production"
Environment="CLASES_PILATES_DATABASE_HOST=127.0.0.1"
Environment="CLASES_PILATES_DATABASE_PORT=5432"
Environment="CLASES_PILATES_DATABASE_USERNAME=clases_pilates"
Environment="CLASES_PILATES_DATABASE_PASSWORD=grinco"
Environment="RAILS_MASTER_KEY=85edfe7ac3f8388490c267d446b07eae"
Environment="RAILS_MAX_THREADS=5"
Environment="BIND=127.0.0.1"
Environment="PORT=3000"

# O mejor aún, usar DATABASE_URL (más simple)
# Environment="DATABASE_URL=postgres://clases_pilates:grinco@127.0.0.1:5432/clases_pilates_production"
# Environment="RAILS_MASTER_KEY=85edfe7ac3f8388490c267d446b07eae"
# Environment="RAILS_MAX_THREADS=5"
# Environment="BIND=127.0.0.1"
# Environment="PORT=3000"

ExecStart=/bin/bash -lc 'cd /home/deploy/apps/pilates && eval "$(rbenv init - bash)" && bundle exec puma -C config/puma.rb'
Restart=always
RestartSec=10
StandardOutput=append:/home/deploy/apps/pilates/log/puma.stdout.log
StandardError=append:/home/deploy/apps/pilates/log/puma.stderr.log

[Install]
WantedBy=multi-user.target
```

## Opción Más Simple: Usar DATABASE_URL

Si prefieres usar `DATABASE_URL` (recomendado), el servicio queda así:

```ini
[Unit]
Description=Pilates App (Rails)
After=network.target postgresql.service

[Service]
Type=simple
User=deploy
WorkingDirectory=/home/deploy/apps/pilates
Environment="RAILS_ENV=production"
Environment="PATH=/home/deploy/.rbenv/shims:/home/deploy/.rbenv/bin:/usr/local/bin:/usr/bin:/bin"
Environment="DATABASE_URL=postgres://clases_pilates:grinco@127.0.0.1:5432/clases_pilates_production"
Environment="RAILS_MASTER_KEY=85edfe7ac3f8388490c267d446b07eae"
Environment="RAILS_MAX_THREADS=5"
Environment="BIND=127.0.0.1"
Environment="PORT=3000"
ExecStart=/bin/bash -lc 'cd /home/deploy/apps/pilates && eval "$(rbenv init - bash)" && bundle exec puma -C config/puma.rb'
Restart=always
RestartSec=10
StandardOutput=append:/home/deploy/apps/pilates/log/puma.stdout.log
StandardError=append:/home/deploy/apps/pilates/log/puma.stderr.log

[Install]
WantedBy=multi-user.target
```

## Después de Editar

```bash
# Crear directorio de logs
mkdir -p ~/apps/pilates/log

# Recargar systemd
sudo systemctl daemon-reload

# Reiniciar servicio
sudo systemctl restart pilates

# Ver estado
sudo systemctl status pilates

# Ver logs
sudo journalctl -u pilates -f
tail -f ~/apps/pilates/log/puma.stderr.log
```

## Verificar que Funciona

```bash
# Verificar que está corriendo
ps aux | grep puma | grep -v grep

# Probar conexión
curl http://localhost:3000/up
```

