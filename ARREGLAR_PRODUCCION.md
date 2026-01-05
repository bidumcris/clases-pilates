# Arreglar Problemas en Producción

## Problemas Detectados:
1. ✅ Puma del bot está corriendo en puerto 3002
2. ❌ App de pilates NO está corriendo
3. ❌ Nginx tiene error de configuración (servidor duplicado)
4. ❌ No hay nada escuchando en puerto 3000

## Solución Paso a Paso:

### 1. Verificar Configuración de Puma

```bash
cd ~/apps/pilates
cat .env | grep PORT
cat config/puma.rb | grep -E "(port|bind)"
```

### 2. Arreglar Configuración de Nginx

El error dice que hay un servidor duplicado. Necesitas:

```bash
# Ver la configuración problemática
sudo cat /etc/nginx/sites-enabled/pilates

# Ver todas las configuraciones
sudo ls -la /etc/nginx/sites-enabled/
```

**Solución:** Eliminar el `default_server` de una de las configuraciones.

```bash
# Opción 1: Deshabilitar el default
sudo rm /etc/nginx/sites-enabled/default

# Opción 2: O editar /etc/nginx/sites-enabled/pilates y quitar "default_server"
sudo nano /etc/nginx/sites-enabled/pilates
```

La configuración correcta debería ser:

```nginx
server {
    listen 80;
    # NO poner default_server aquí si ya está en default
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

### 3. Iniciar la App de Pilates

```bash
cd ~/apps/pilates

# Verificar que el .env tiene PORT=3000
cat .env | grep PORT

# Si no está, agregarlo:
echo "PORT=3000" >> .env

# Iniciar Puma
RAILS_ENV=production bundle exec puma -C config/puma.rb -d

# Verificar que está corriendo
ps aux | grep puma | grep -v grep
```

### 4. Verificar que Puma está Escuchando

```bash
# Probar conexión
curl http://localhost:3000/up

# Debería responder: {"status":"ok"}
```

### 5. Reiniciar Nginx

```bash
# Probar configuración
sudo nginx -t

# Si está bien, reiniciar
sudo systemctl restart nginx

# Verificar estado
sudo systemctl status nginx
```

### 6. Verificar Logs

```bash
# Logs de Nginx
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log

# Logs de la app (si los crea)
cd ~/apps/pilates
tail -f log/production.log
```

### 7. Probar desde el Navegador

Abre: http://165.1.121.75/

## Si Usas systemd o supervisor:

Si tienes un servicio configurado:

```bash
# Ver si existe
sudo systemctl status pilates
# O
sudo supervisorctl status pilates

# Si existe, reiniciar:
sudo systemctl restart pilates
# O
sudo supervisorctl restart pilates
```

## Comandos Rápidos (Todo en Uno):

```bash
# 1. Ir a la app
cd ~/apps/pilates

# 2. Verificar PORT en .env
grep PORT .env || echo "PORT=3000" >> .env

# 3. Iniciar Puma
RAILS_ENV=production bundle exec puma -C config/puma.rb -d

# 4. Verificar que está corriendo
sleep 2 && curl http://localhost:3000/up

# 5. Arreglar Nginx (quitar default_server duplicado)
sudo nano /etc/nginx/sites-enabled/pilates
# Quitar "default_server" de la línea "listen 80"

# 6. Probar y reiniciar Nginx
sudo nginx -t && sudo systemctl restart nginx

# 7. Verificar
sudo systemctl status nginx
```

