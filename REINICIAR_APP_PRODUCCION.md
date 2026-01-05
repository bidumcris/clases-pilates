# Cómo Reiniciar la App en Producción

## 1. Reiniciar la App (Depende de cómo la estés corriendo)

### Opción A: Si usas systemd

```bash
# Ver estado
sudo systemctl status pilates

# Reiniciar
sudo systemctl restart pilates

# Ver logs
sudo journalctl -u pilates -f
```

### Opción B: Si usas supervisor

```bash
# Ver estado
sudo supervisorctl status pilates

# Reiniciar
sudo supervisorctl restart pilates

# Ver logs
sudo supervisorctl tail -f pilates
```

### Opción C: Si corres manualmente con Puma

```bash
# Encontrar el proceso
ps aux | grep puma

# Matar el proceso (reemplaza PID con el número del proceso)
kill -9 PID

# O si usas tmux/screen, simplemente:
# Ctrl+C para detener
# Luego vuelve a iniciar:
cd ~/apps/pilates
RAILS_ENV=production bundle exec puma -C config/puma.rb
```

### Opción D: Si usas Kamal

```bash
kamal app restart
```

## 2. Verificar que la App Funciona

```bash
# Verificar que el proceso está corriendo
ps aux | grep puma

# Verificar que responde
curl http://localhost:3000/up

# Ver logs en tiempo real
tail -f ~/apps/pilates/log/production.log
```

## 3. Verificar Cambios en el Navegador

1. Abre tu navegador
2. Ve a la URL de tu app
3. Verifica que los cambios se reflejen

## 4. Si Hay Problemas

### Ver logs de errores:
```bash
tail -f ~/apps/pilates/log/production.log
```

### Verificar variables de entorno:
```bash
cd ~/apps/pilates
cat .env | grep -E "(RAILS_ENV|DATABASE|RAILS_MASTER_KEY)"
```

### Verificar conexión a la BD:
```bash
RAILS_ENV=production bundle exec rails runner "puts ActiveRecord::Base.connection_config"
```

### Verificar migraciones:
```bash
RAILS_ENV=production bundle exec rails db:migrate:status
```

