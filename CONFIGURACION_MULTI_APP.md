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

## ¿Por qué una sola base de datos?

✅ **Ventajas:**
- **Más simple**: Una sola configuración
- **Compartir datos**: El bot puede acceder a usuarios, clases, reservas
- **Menos recursos**: Menos conexiones, menos memoria
- **Backups más fáciles**: Un solo backup para todo
- **Transacciones**: Si el bot necesita modificar datos, todo está en el mismo lugar

❌ **Cuándo usar bases de datos separadas:**
- Apps completamente independientes
- Requisitos de seguridad diferentes
- Necesidad de escalar por separado
- Apps de diferentes empresas/clientes

## Ejemplo: Agregar Bot (usando la misma BD)

### 1. El bot usará la misma base de datos

No necesitas crear nada nuevo. El bot se conectará a la misma base de datos.

### 2. Agregar Variables al `.env` (solo para el bot)

```bash
# =============================================================================
# CONFIGURACIÓN DEL BOT
# =============================================================================
BOT_TOKEN=tu_bot_token_de_telegram
BOT_PORT=3001
# El bot usará la misma DATABASE_URL que ya tienes configurada
```

### 3. Configurar `database.yml` del Bot

En el proyecto del bot, usar la misma `DATABASE_URL`:

```yaml
production:
  <<: *default
  url: <%= ENV.fetch("DATABASE_URL", "") %>
  # O si prefieres variables individuales:
  # database: <%= ENV.fetch("DATABASE_NAME", "clases_pilates_production") %>
  # host: <%= ENV.fetch("DATABASE_HOST", "127.0.0.1") %>
  # port: <%= ENV.fetch("DATABASE_PORT", "5432") %>
  # username: <%= ENV.fetch("DATABASE_USERNAME", "clases_pilates") %>
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

✅ **Simple**: Una sola base de datos, una sola configuración
✅ **Eficiente**: Menos recursos, menos complejidad
✅ **Compartir datos**: El bot puede acceder directamente a las tablas
✅ **Backups fáciles**: Un solo comando para respaldar todo
✅ **Mantenible**: Menos cosas que configurar y mantener

## Estructura de Directorios Recomendada

```
/home/deploy/
├── apps/
│   ├── pilates/          # Clases Pilates (Rails)
│   │   ├── .env          # Comparte DATABASE_URL con el bot
│   │   └── ...
│   └── bot/              # Bot (Ruby/Python/etc)
│       ├── .env          # Misma DATABASE_URL
│       └── ...
```

**Ambas apps usan el mismo `.env` o copian las mismas variables de BD.**

