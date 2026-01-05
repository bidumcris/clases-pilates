# Configuración Multi-Aplicación

Esta guía explica cómo configurar múltiples aplicaciones en el mismo servidor, **cada una con su propia base de datos**.

## 🎯 Estructura: Cada App con su Propia Base de Datos

**Estructura del servidor:**
```
/home/deploy/apps/
├── pilates/          # App Clases Pilates
│   └── .env          # Configuración de pilates
└── bot/              # App Bot
    └── .env          # Configuración del bot
```

**Cada app tiene su propia base de datos independiente:**
- `pilates` → `pilates_production`
- `bot` → `bot_production`

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

### 1. `.env` en `~/apps/pilates/.env`:

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
# BASE DE DATOS (SOLO PARA PILATES)
# =============================================================================
DATABASE_URL=postgres://pilates_user:tu_password_seguro@127.0.0.1:5432/pilates_production

# =============================================================================
# RAILS CREDENTIALS
# =============================================================================
RAILS_MASTER_KEY=tu_master_key_aqui
```

### 2. `.env` en `~/apps/bot/.env`:

```bash
# =============================================================================
# BASE DE DATOS (SOLO PARA BOT)
# =============================================================================
DATABASE_URL=postgres://bot_user:password_bot@127.0.0.1:5432/bot_production

# =============================================================================
# CONFIGURACIÓN DEL BOT
# =============================================================================
BOT_TOKEN=tu_token_aqui
BOT_PORT=3001
```

### Comandos para crear las bases de datos:

```bash
# Base de datos para PILATES
sudo -u postgres psql -c "CREATE USER pilates_user WITH PASSWORD 'tu_password_seguro';"
sudo -u postgres psql -c "CREATE DATABASE pilates_production OWNER pilates_user;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE pilates_production TO pilates_user;"

# Base de datos para BOT
sudo -u postgres psql -c "CREATE USER bot_user WITH PASSWORD 'password_bot';"
sudo -u postgres psql -c "CREATE DATABASE bot_production OWNER bot_user;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE bot_production TO bot_user;"
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

