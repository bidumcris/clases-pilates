# Configuración de Base de Datos en Producción

## Mejores Prácticas

### 1. **Usar Variables de Entorno (RECOMENDADO)**

Nunca hardcodees credenciales en el código. Usa variables de entorno.

#### Opción A: DATABASE_URL (Mejor para servicios gestionados)

```bash
# En tu archivo .env o variables de entorno del servidor
DATABASE_URL=postgres://usuario:password@host:5432/clases_pilates_production
```

**Ventajas:**
- Estándar de la industria (Heroku, AWS, DigitalOcean, etc.)
- Una sola variable para toda la configuración
- Fácil de rotar credenciales

#### Opción B: Variables Individuales (Para servidores propios)

```bash
CLASES_PILATES_DATABASE_NAME=clases_pilates_production
CLASES_PILATES_DATABASE_HOST=127.0.0.1
CLASES_PILATES_DATABASE_PORT=5432
CLASES_PILATES_DATABASE_USERNAME=clases_pilates
CLASES_PILATES_DATABASE_PASSWORD=tu_password_seguro
```

### 2. **Crear Usuario y Base de Datos en PostgreSQL**

```bash
# Conectarse como superusuario
sudo -u postgres psql

# Crear usuario (si no existe)
CREATE USER clases_pilates WITH PASSWORD 'tu_password_seguro';

# Crear base de datos
CREATE DATABASE clases_pilates_production OWNER clases_pilates;

# Dar permisos
GRANT ALL PRIVILEGES ON DATABASE clases_pilates_production TO clases_pilates;

# Salir
\q
```

### 3. **Configurar Variables de Entorno en el Servidor**

#### Si usas archivo .env (con dotenv gem):

```bash
# En el servidor, crear archivo .env
cd ~/apps/pilates
nano .env

# Agregar las variables (ver .env.example)
```

#### Si usas systemd o supervisor:

```bash
# En el archivo de servicio (ej: /etc/systemd/system/pilates.service)
[Service]
Environment="DATABASE_URL=postgres://..."
Environment="RAILS_ENV=production"
```

#### Si usas Capistrano o similar:

```bash
# En config/deploy/production.rb
set :default_env, {
  'DATABASE_URL' => 'postgres://...',
  'RAILS_ENV' => 'production'
}
```

### 4. **Verificar Configuración**

```bash
# Ver qué variables están configuradas
RAILS_ENV=production bundle exec rails runner "puts ActiveRecord::Base.connection_config"

# Probar conexión
RAILS_ENV=production bundle exec rails db:version
```

### 5. **Seguridad**

✅ **HACER:**
- Usar contraseñas fuertes (mínimo 16 caracteres)
- Rotar contraseñas periódicamente
- Usar SSL/TLS para conexiones remotas
- Limitar acceso por IP si es posible
- Usar usuarios con permisos mínimos necesarios

❌ **NO HACER:**
- Commitear credenciales en el repositorio
- Usar el usuario `postgres` para la aplicación
- Compartir credenciales por email o chat
- Usar contraseñas débiles

### 6. **Backup y Recuperación**

```bash
# Backup manual
pg_dump -U clases_pilates -h localhost clases_pilates_production > backup_$(date +%Y%m%d).sql

# Restaurar backup
psql -U clases_pilates -h localhost clases_pilates_production < backup_20260101.sql
```

### 7. **Ejemplo de Configuración Completa**

```bash
# 1. Crear usuario y base de datos
sudo -u postgres psql -c "CREATE USER clases_pilates WITH PASSWORD 'password_seguro_123';"
sudo -u postgres psql -c "CREATE DATABASE clases_pilates_production OWNER clases_pilates;"

# 2. Configurar variables de entorno
cd ~/apps/pilates
cat > .env << EOF
DATABASE_URL=postgres://clases_pilates:password_seguro_123@localhost:5432/clases_pilates_production
RAILS_ENV=production
RAILS_MAX_THREADS=5
SECRET_KEY_BASE=$(bundle exec rails secret)
EOF

# 3. Ejecutar migraciones
RAILS_ENV=production bundle exec rails db:migrate

# 4. Cargar seeds
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=production bundle exec rails db:seed
```

### 8. **Servicios Gestionados (Recomendado para producción real)**

Si usas servicios como:
- **Heroku**: Configura automáticamente `DATABASE_URL`
- **AWS RDS**: Usa el endpoint proporcionado
- **DigitalOcean Managed Database**: Similar a RDS
- **Railway/Render**: Configuración automática

Solo necesitas copiar el `DATABASE_URL` que te proporcionan.

## Troubleshooting

### Error: "permission denied to create database"
```bash
# El usuario no tiene permisos. Crear la BD manualmente como superusuario:
sudo -u postgres createdb -O clases_pilates clases_pilates_production
```

### Error: "database does not exist"
```bash
# Crear la base de datos:
RAILS_ENV=production bundle exec rails db:create
# O manualmente:
sudo -u postgres createdb clases_pilates_production
```

### Error: "password authentication failed"
```bash
# Verificar que el password en .env coincida con el de PostgreSQL
# Cambiar password en PostgreSQL:
sudo -u postgres psql -c "ALTER USER clases_pilates WITH PASSWORD 'nuevo_password';"
```

