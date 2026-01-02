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

## Convenciones de Nomenclatura

### Para Base de Datos
- `[APP_NAME]_DATABASE_NAME`: Nombre de la base de datos
- `[APP_NAME]_DATABASE_HOST`: Host de PostgreSQL
- `[APP_NAME]_DATABASE_PORT`: Puerto de PostgreSQL
- `[APP_NAME]_DATABASE_USERNAME`: Usuario de PostgreSQL
- `[APP_NAME]_DATABASE_PASSWORD`: Password de PostgreSQL

### Para Rails
- `[APP_NAME]_RAILS_MASTER_KEY`: Master key de Rails credentials

### Para Aplicaciones Específicas
- `[APP_NAME]_PORT`: Puerto donde corre la app
- `[APP_NAME]_TOKEN`: Tokens específicos (ej: bot token)

## Ejemplo: Agregar Bot

### 1. Crear Base de Datos para Bot

```bash
sudo -u postgres psql
```

```sql
CREATE USER bot_user WITH PASSWORD 'password_seguro_bot';
CREATE DATABASE bot_production OWNER bot_user;
GRANT ALL PRIVILEGES ON DATABASE bot_production TO bot_user;
\q
```

### 2. Agregar Variables al `.env`

```bash
# =============================================================================
# APLICACIÓN: BOT
# =============================================================================
BOT_DATABASE_NAME=bot_production
BOT_DATABASE_HOST=127.0.0.1
BOT_DATABASE_PORT=5432
BOT_DATABASE_USERNAME=bot_user
BOT_DATABASE_PASSWORD=password_seguro_bot
BOT_TOKEN=tu_bot_token_de_telegram
BOT_PORT=3001
```

### 3. Configurar `database.yml` del Bot

En el proyecto del bot, usar las mismas convenciones:

```yaml
production:
  <<: *default
  database: <%= ENV.fetch("BOT_DATABASE_NAME", "bot_production") %>
  host: <%= ENV.fetch("BOT_DATABASE_HOST", "127.0.0.1") %>
  port: <%= ENV.fetch("BOT_DATABASE_PORT", "5432") %>
  username: <%= ENV.fetch("BOT_DATABASE_USERNAME", "bot_user") %>
  password: <%= ENV.fetch("BOT_DATABASE_PASSWORD", "") %>
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

## Ventajas de Esta Estructura

✅ **Escalable**: Fácil agregar nuevas apps
✅ **Organizado**: Cada app tiene su sección clara
✅ **Seguro**: Variables separadas por app
✅ **Mantenible**: Fácil encontrar y actualizar configuraciones
✅ **Flexible**: Cada app puede tener su propio puerto, BD, etc.

## Mejores Prácticas

1. **Usar prefijos consistentes**: `[APP_NAME]_` para todas las variables
2. **Documentar cada sección**: Comentarios claros en el `.env`
3. **Separar por app**: Cada app en su propia sección
4. **Variables compartidas al inicio**: Rails, Puma, etc.
5. **Comentar apps futuras**: Dejar plantillas comentadas para futuras apps

## Estructura de Directorios Recomendada

```
/home/deploy/
├── apps/
│   ├── pilates/          # Clases Pilates
│   │   ├── .env
│   │   └── ...
│   ├── bot/              # Bot
│   │   ├── .env
│   │   └── ...
│   └── otra_app/         # Otra app
│       ├── .env
│       └── ...
```

Cada app puede tener su propio `.env` o compartir uno centralizado (recomendado para facilitar mantenimiento).

