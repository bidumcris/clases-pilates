# Diagnóstico de Problemas en Producción

## Problema: No se ve nada al acceder a http://165.1.121.75/

### 1. Verificar que la App está Corriendo

```bash
# Ver procesos de Rails/Puma
ps aux | grep -E "(rails|puma)" | grep -v grep

# Ver procesos en el puerto 3000
sudo netstat -tlnp | grep 3000
# O con ss:
sudo ss -tlnp | grep 3000
```

### 2. Verificar Logs de la App

```bash
cd ~/apps/pilates
tail -50 log/production.log
```

### 3. Verificar que Nginx está Configurado

```bash
# Ver configuración de Nginx
sudo cat /etc/nginx/sites-available/pilates
# O
sudo cat /etc/nginx/sites-enabled/pilates

# Verificar que Nginx está corriendo
sudo systemctl status nginx

# Ver logs de Nginx
sudo tail -50 /var/log/nginx/error.log
sudo tail -50 /var/log/nginx/access.log
```

### 4. Verificar que Nginx está Escuchando en el Puerto 80

```bash
sudo netstat -tlnp | grep :80
# O
sudo ss -tlnp | grep :80
```

### 5. Probar Conexión Directa a Puma

```bash
# Desde el servidor, probar:
curl http://localhost:3000/up

# Si funciona, deberías ver: {"status":"ok"}
```

### 6. Verificar Configuración de Nginx

La configuración debería ser algo así:

```nginx
server {
    listen 80;
    server_name 165.1.121.75;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 7. Reiniciar Servicios

```bash
# Reiniciar Nginx
sudo systemctl restart nginx

# Reiniciar la app (según cómo la corras)
sudo systemctl restart pilates
# O
sudo supervisorctl restart pilates
```

### 8. Verificar Firewall

```bash
# Ver reglas de firewall
sudo ufw status
# O
sudo iptables -L -n

# Si está bloqueado, permitir puerto 80:
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### 9. Verificar Variables de Entorno

```bash
cd ~/apps/pilates
cat .env | grep -E "(RAILS_ENV|PORT|BIND)"
```

### 10. Iniciar la App Manualmente (para debug)

```bash
cd ~/apps/pilates
RAILS_ENV=production bundle exec rails server -b 0.0.0.0 -p 3000
```

Si funciona manualmente, el problema es con systemd/supervisor.

