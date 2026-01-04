# Configuración Multi-Aplicación

Esta guía explica cómo configurar múltiples aplicaciones Rails en el mismo servidor.

## Estructura del `.env` en Producción

### Template Organizado

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
# APLICACIÓN: CLASES PILATES
# =============================================================================
CLASES_PILATES_DATABASE_NAME=clases_pilates_production
CLASES_PILATES_DATABASE_HOST=127.0.0.1
CLASES_PILATES_DATABASE_PORT=5432
CLASES_PILATES_DATABASE_USERNAME=clases_pilates
CLASES_PILATES_DATABASE_PASSWORD=tu_password_aqui
CLASES_PILATES_RAILS_MASTER_KEY=tu_master_key_aqui

# =============================================================================
# APLICACIÓN: BOT
# =============================================================================
BOT_DATABASE_NAME=bot_production
BOT_DATABASE_HOST=127.0.0.1
BOT_DATABASE_PORT=5432
BOT_DATABASE_USERNAME=bot_user
BOT_DATABASE_PASSWORD=tu_password_bot_aqui
BOT_TOKEN=tu_bot_token_aqui
BOT_PORT=3001

# =============================================================================
# APLICACIÓN: [OTRA_APP]
# =============================================================================
# [OTRA_APP]_DATABASE_NAME=[otra_app]_production
# [OTRA_APP]_DATABASE_HOST=127.0.0.1
# [OTRA_APP]_DATABASE_PORT=5432
# [OTRA_APP]_DATABASE_USERNAME=[otra_app]_user
# [OTRA_APP]_DATABASE_PASSWORD=tu_password_aqui
# [OTRA_APP]_PORT=3002
```

## ¿Por qué bases de datos separadas?

✅ **Ventajas:**
- **Aislamiento**: Cada app es independiente
- **Seguridad**: Si una app tiene problemas, no afecta a la otra
- **Escalabilidad**: Puedes escalar cada app por separado
- **Backups independientes**: Backups separados por app
- **Mantenimiento**: Actualizar una app no afecta a la otra

## Ejemplo: Configurar el Bot (con su propia BD)

### 1. Crear Base de Datos para el Bot

```bash
sudo -u postgres psql
```

```sql
-- Crear usuario para el bot
CREATE USER bot_user WITH PASSWORD 'password_seguro_bot';

-- Crear base de datos para el bot
CREATE DATABASE bot_production OWNER bot_user;

-- Dar permisos
GRANT ALL PRIVILEGES ON DATABASE bot_production TO bot_user;

-- Salir
\q
```

### 2. Configurar `.env` en `~/apps/bot/.env`

```bash
# =============================================================================
# CONFIGURACIÓN DEL BOT
# =============================================================================
DATABASE_URL=postgres://bot_user:password_seguro_bot@127.0.0.1:5432/bot_production
BOT_TOKEN=tu_bot_token_de_telegram
BOT_PORT=3001
```

### 3. Configurar `database.yml` del Bot

En el proyecto del bot (`~/apps/bot/config/database.yml`):

```yaml
production:
  <<: *default
  url: <%= ENV.fetch("DATABASE_URL", "") %>
  # O si prefieres variables individuales:
  # database: <%= ENV.fetch("DATABASE_NAME", "bot_production") %>
  # host: <%= ENV.fetch("DATABASE_HOST", "127.0.0.1") %>
  # port: <%= ENV.fetch("DATABASE_PORT", "5432") %>
  # username: <%= ENV.fetch("DATABASE_USERNAME", "bot_user") %>
  # password: <%= ENV.fetch("DATABASE_PASSWORD", "") %>
```

### 4. Configurar Nginx (si usas reverse proxy)

```nginx
# Clases Pilates
upstream clases_pilates {
  server 127.0.0.1:3000;
}

# Bot (si tiene API web)
upstream bot {
  server 127.0.0.1:3001;
}

server {
  listen 80;
  server_name pilates.tudominio.com;

  location / {
    proxy_pass http://clases_pilates;
    # ... resto de configuración
  }
}

server {
  listen 80;
  server_name bot.tudominio.com;

  location / {
    proxy_pass http://bot;
    # ... resto de configuración
  }
}
```

## Configuración Final Recomendada

### Tu `.env` en producción debería ser así:

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
# BASE DE DATOS (COMPARTIDA PARA TODAS LAS APPS)
# =============================================================================
DATABASE_URL=postgres://clases_pilates:tu_password@127.0.0.1:5432/clases_pilates_production

# =============================================================================
# RAILS CREDENTIALS
# =============================================================================
RAILS_MASTER_KEY=tu_master_key_aqui

# =============================================================================
# BOT (Futuro - cuando lo agregues)
# =============================================================================
# BOT_TOKEN=tu_token_aqui
# BOT_PORT=3001
```

### Comandos para crear la base de datos (UNA SOLA VEZ):

```bash
# 1. Crear usuario y base de datos
sudo -u postgres psql -c "CREATE USER clases_pilates WITH PASSWORD 'tu_password_seguro';"
sudo -u postgres psql -c "CREATE DATABASE clases_pilates_production OWNER clases_pilates;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE clases_pilates_production TO clases_pilates;"
```

## Ventajas de Esta Estructura

✅ **Aislamiento**: Cada app es completamente independiente
✅ **Seguridad**: Problemas en una app no afectan a la otra
✅ **Escalabilidad**: Puedes escalar cada app por separado
✅ **Backups independientes**: Backups separados por app
✅ **Mantenible**: Actualizar una app no afecta a la otra
✅ **Claro**: Cada app tiene su propia configuración

## Estructura de Directorios

```
/home/deploy/apps/
├── pilates/              # App Clases Pilates
│   ├── .env              # DATABASE_URL → pilates_production
│   └── ...
└── bot/                  # App Bot
    ├── .env              # DATABASE_URL → bot_production
    └── ...
```

**Cada app tiene su propia base de datos y configuración independiente.**

