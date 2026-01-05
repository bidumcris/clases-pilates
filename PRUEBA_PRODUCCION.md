# Guía Rápida para Probar en Producción

## Pasos para Probar en Producción

### 1. Verificar que la Base de Datos Existe

```bash
# Conectarse al servidor
ssh deploy@tu_servidor

# Verificar que la BD existe
sudo -u postgres psql -c "\l" | grep clases_pilates_production
```

Si no existe, crearla:
```bash
sudo -u postgres psql -c "CREATE USER clases_pilates WITH PASSWORD 'grinco';"
sudo -u postgres psql -c "CREATE DATABASE clases_pilates_production OWNER clases_pilates;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE clases_pilates_production TO clases_pilates;"
```

### 2. Verificar el `.env`

```bash
cd ~/apps/pilates
cat .env
```

Asegúrate de que tenga al menos:
```bash
RAILS_ENV=production
DATABASE_URL=postgres://clases_pilates:grinco@127.0.0.1:5432/clases_pilates_production
# O las variables individuales
RAILS_MASTER_KEY=85edfe7ac3f8388490c267d446b07eae
```

### 3. Hacer Pull de los Cambios

```bash
cd ~/apps/pilates
git pull origin main  # o development, según tu rama
bundle install
```

### 4. Verificar Conexión a la Base de Datos

```bash
RAILS_ENV=production bundle exec rails db:version
```

Si funciona, verás la versión del schema. Si no, verás un error.

### 5. Ejecutar Migraciones

```bash
RAILS_ENV=production bundle exec rails db:migrate
```

### 6. Cargar Seeds (si es necesario)

```bash
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=production bundle exec rails db:seed
```

### 7. Verificar que la App Funciona

```bash
# Verificar configuración
RAILS_ENV=production bundle exec rails runner "puts ActiveRecord::Base.connection_config"

# Probar consola
RAILS_ENV=production bundle exec rails console
# En la consola, prueba:
# > User.count
# > exit
```

### 8. Reiniciar el Servidor (si usas systemd/supervisor)

```bash
# Si usas systemd
sudo systemctl restart pilates

# Si usas supervisor
sudo supervisorctl restart pilates

# O si corres manualmente, reinicia el proceso de Puma
```

## Troubleshooting

### Error: "database does not exist"
```bash
# Crear la BD
sudo -u postgres createdb -O clases_pilates clases_pilates_production
```

### Error: "password authentication failed"
```bash
# Verificar password en .env
# Cambiar password si es necesario:
sudo -u postgres psql -c "ALTER USER clases_pilates WITH PASSWORD 'grinco';"
```

### Error: "permission denied for schema public"
```bash
# Dar permisos al usuario en el schema public
sudo -u postgres psql -d clases_pilates_production -c "GRANT ALL ON SCHEMA public TO clases_pilates;"
sudo -u postgres psql -d clases_pilates_production -c "GRANT CREATE ON SCHEMA public TO clases_pilates;"
sudo -u postgres psql -d clases_pilates_production -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO clases_pilates;"
sudo -u postgres psql -d clases_pilates_production -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO clases_pilates;"
```

### Error: "permission denied" (general)
```bash
# Verificar permisos
sudo -u postgres psql -c "\du" | grep clases_pilates
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE clases_pilates_production TO clases_pilates;"
```

### Error: "ActiveRecord::ProtectedEnvironmentError"
```bash
# Para comandos destructivos, usar:
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=production bundle exec rails db:seed
```

## Comandos Útiles

```bash
# Ver logs en tiempo real
tail -f ~/apps/pilates/log/production.log

# Verificar procesos de Rails
ps aux | grep rails

# Verificar conexiones a PostgreSQL
sudo -u postgres psql -c "SELECT * FROM pg_stat_activity WHERE datname='clases_pilates_production';"
```

