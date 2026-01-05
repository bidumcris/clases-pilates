# Debug de Systemd - Servicio Falla al Iniciar

## Ver Logs Detallados

```bash
# Ver los últimos logs con más detalle
sudo journalctl -u pilates -n 100 --no-pager

# Ver logs en tiempo real
sudo journalctl -u pilates -f

# Ver logs desde el inicio del problema
sudo journalctl -u pilates --since "10 minutes ago"
```

## Probar el Comando Manualmente

Ejecuta el mismo comando que systemd intenta ejecutar:

```bash
cd ~/apps/pilates

# Verificar que bundle existe
which bundle
/home/deploy/.rbenv/shims/bundle

# Probar el comando completo
RAILS_ENV=production /home/deploy/.rbenv/shims/bundle exec puma -C /home/deploy/apps/pilates/config/puma.rb
```

Esto te mostrará el error real.

## Problemas Comunes y Soluciones

### 1. Ruta de bundle incorrecta

```bash
# Verificar ruta real
which bundle

# Si es diferente, actualizar el servicio:
sudo nano /etc/systemd/system/pilates.service
# Cambiar ExecStart con la ruta correcta
```

### 2. Variables de entorno no cargadas

El `.env` puede no estar cargándose. Prueba:

```bash
cd ~/apps/pilates
source .env  # Esto no funciona, pero prueba:
cat .env

# Verificar que las variables están en el archivo
```

### 3. Permisos de archivos

```bash
# Verificar permisos
ls -la ~/apps/pilates/.env
ls -la ~/apps/pilates/config/puma.rb

# Dar permisos si es necesario
chmod 644 ~/apps/pilates/.env
```

### 4. Usar rbenv en systemd

Si usas rbenv, necesitas inicializarlo:

```bash
sudo nano /etc/systemd/system/pilates.service
```

Cambiar ExecStart a:

```ini
ExecStart=/bin/bash -lc 'cd /home/deploy/apps/pilates && bundle exec puma -C config/puma.rb'
```

Y agregar:

```ini
Environment="PATH=/home/deploy/.rbenv/shims:/home/deploy/.rbenv/bin:/usr/local/bin:/usr/bin:/bin"
```

### 5. Versión Simplificada del Servicio

Si sigue fallando, usa esta versión más simple:

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
ExecStart=/bin/bash -lc 'cd /home/deploy/apps/pilates && source ~/.bashrc && bundle exec puma -C config/puma.rb'
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Luego:

```bash
sudo systemctl daemon-reload
sudo systemctl restart pilates
sudo systemctl status pilates
```

## Verificar que Funciona Manualmente

Antes de usar systemd, asegúrate de que funciona manualmente:

```bash
cd ~/apps/pilates
RAILS_ENV=production bundle exec puma -C config/puma.rb
```

Si funciona manualmente, el problema es con systemd. Si no funciona, el problema es con la app.

