# Setup de Producción - Guía Rápida

## 🎯 Estructura del Servidor

Cada aplicación tiene su propia carpeta y su propia base de datos:

```
/home/deploy/apps/
├── pilates/          # App Clases Pilates
│   └── .env          # Configuración de pilates
└── bot/              # App Bot
    └── .env          # Configuración del bot
```

**Cada app tiene su propia base de datos independiente.**

## Pasos para Configurar Producción

### 1. Crear Usuario y Base de Datos para PILATES

```bash
sudo -u postgres psql
```

```sql
-- Crear usuario para pilates
CREATE USER pilates_user WITH PASSWORD 'tu_password_seguro_pilates';

-- Crear base de datos para pilates
CREATE DATABASE pilates_production OWNER pilates_user;

-- Dar permisos
GRANT ALL PRIVILEGES ON DATABASE pilates_production TO pilates_user;

-- Salir
\q
```

**Nota:** El bot tendrá su propia base de datos (`bot_production`) configurada en su carpeta.

### 2. Configurar `.env` en la carpeta de PILATES

```bash
cd ~/apps/pilates
nano .env
```

**Contenido del `.env` para PILATES (versión limpia):**

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
# BASE DE DATOS (OPCIÓN 1: DATABASE_URL - RECOMENDADO)
# =============================================================================
DATABASE_URL=postgres://clases_pilates:tu_password@127.0.0.1:5432/clases_pilates_production

# =============================================================================
# BASE DE DATOS (OPCIÓN 2: Variables individuales - si prefieres más control)
# =============================================================================
# DATABASE_NAME=clases_pilates_production
# DATABASE_HOST=127.0.0.1
# DATABASE_PORT=5432
# DATABASE_USERNAME=clases_pilates
# DATABASE_PASSWORD=tu_password

# O usando prefijo (también funciona):
# CLASES_PILATES_DATABASE_NAME=clases_pilates_production
# CLASES_PILATES_DATABASE_HOST=127.0.0.1
# CLASES_PILATES_DATABASE_PORT=5432
# CLASES_PILATES_DATABASE_USERNAME=clases_pilates
# CLASES_PILATES_DATABASE_PASSWORD=tu_password

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

## Configuración del Bot (Separada)

El bot tiene su propia carpeta (`~/apps/bot`) y su propia base de datos:

1. **Crear base de datos para el bot:**
```bash
sudo -u postgres psql -c "CREATE USER bot_user WITH PASSWORD 'password_bot';"
sudo -u postgres psql -c "CREATE DATABASE bot_production OWNER bot_user;"
```

2. **Configurar `.env` en `~/apps/bot/.env`:**
```bash
DATABASE_URL=postgres://bot_user:password_bot@127.0.0.1:5432/bot_production
BOT_TOKEN=tu_token_de_telegram
BOT_PORT=3001
```

**Cada app es completamente independiente con su propia base de datos.**

## Backup

```bash
# Backup de la base de datos de PILATES
pg_dump -U clases_pilates -h localhost clases_pilates_production > ~/backups/pilates_$(date +%Y%m%d).sql

# Backup de la base de datos del BOT (si lo necesitas)
pg_dump -U bot_user -h localhost bot_production > ~/backups/bot_$(date +%Y%m%d).sql

# Restaurar pilates
psql -U clases_pilates -h localhost clases_pilates_production < ~/backups/pilates_20260101.sql
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

