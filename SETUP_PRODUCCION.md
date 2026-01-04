# Setup de Producción - Guía Rápida

## 🎯 Resumen: Una Sola Base de Datos

**Para Clases Pilates + Bot futuro:** Usa **UNA sola base de datos**. Ambas apps comparten las mismas tablas.

## Pasos para Configurar Producción

### 1. Crear Usuario y Base de Datos (UNA SOLA VEZ)

```bash
sudo -u postgres psql
```

```sql
-- Crear usuario
CREATE USER clases_pilates WITH PASSWORD 'tu_password_seguro_aqui';

-- Crear base de datos (ÚNICA para todas las apps)
CREATE DATABASE clases_pilates_production OWNER clases_pilates;

-- Dar permisos
GRANT ALL PRIVILEGES ON DATABASE clases_pilates_production TO clases_pilates;

-- Salir
\q
```

### 2. Configurar `.env` en el Servidor

```bash
cd ~/apps/pilates
nano .env
```

**Contenido del `.env`:**

```bash
# =============================================================================
# CONFIGURACIÓN COMPARTIDA (Rails)
# =============================================================================
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=1
RAILS_SERVE_STATIC_FILES=1
RAILS_MAX_THREADS=5
FORCE_SSL=0

# =============================================================================
# PUMA (Servidor Web)
# =============================================================================
BIND=127.0.0.1
PORT=3000

# =============================================================================
# BASE DE DATOS (COMPARTIDA - UNA SOLA)
# =============================================================================
DATABASE_URL=postgres://clases_pilates:tu_password_seguro@127.0.0.1:5432/clases_pilates_production

# =============================================================================
# RAILS CREDENTIALS
# =============================================================================
RAILS_MASTER_KEY=tu_master_key_aqui
```

### 3. Ejecutar Migraciones y Seeds

```bash
# Hacer pull de los cambios
cd ~/apps/pilates
git pull origin main
bundle install

# Ejecutar migraciones
RAILS_ENV=production bundle exec rails db:migrate

# Cargar seeds (si es necesario)
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=production bundle exec rails db:seed
```

### 4. Verificar que Funciona

```bash
# Probar conexión
RAILS_ENV=production bundle exec rails db:version

# Ver configuración
RAILS_ENV=production bundle exec rails runner "puts ActiveRecord::Base.connection_config"
```

## Cuando Agregues el Bot

El bot usará la **misma base de datos**. Solo necesitas:

1. **En el proyecto del bot**, usar la misma `DATABASE_URL` en su `.env`:
```bash
DATABASE_URL=postgres://clases_pilates:tu_password_seguro@127.0.0.1:5432/clases_pilates_production
```

2. **Agregar variables específicas del bot** (si las necesitas):
```bash
BOT_TOKEN=tu_token_de_telegram
BOT_PORT=3001
```

3. **Listo**: El bot puede acceder a todas las tablas (users, pilates_classes, reservations, etc.)

## ¿Por qué una sola base de datos?

✅ **Más simple**: Una sola configuración
✅ **Compartir datos**: El bot accede directamente a usuarios, clases, reservas
✅ **Menos recursos**: Menos conexiones, menos memoria
✅ **Backups fáciles**: Un solo comando para respaldar todo
✅ **Transacciones**: Si el bot modifica datos, todo está en el mismo lugar

## Backup

```bash
# Backup de la base de datos (incluye todo: app + bot)
pg_dump -U clases_pilates -h localhost clases_pilates_production > backup_$(date +%Y%m%d).sql

# Restaurar
psql -U clases_pilates -h localhost clases_pilates_production < backup_20260101.sql
```

## Troubleshooting

### Error: "permission denied to create database"
```bash
# Crear la BD manualmente como superusuario:
sudo -u postgres createdb -O clases_pilates clases_pilates_production
```

### Error: "database does not exist"
```bash
# Verificar que existe:
sudo -u postgres psql -c "\l" | grep clases_pilates_production

# Si no existe, crearla:
sudo -u postgres createdb -O clases_pilates clases_pilates_production
```

### Error: "password authentication failed"
```bash
# Verificar password en .env
# Cambiar password en PostgreSQL:
sudo -u postgres psql -c "ALTER USER clases_pilates WITH PASSWORD 'nuevo_password';"
```

