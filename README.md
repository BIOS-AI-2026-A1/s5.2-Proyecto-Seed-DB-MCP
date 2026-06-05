# Seed DB — S5.2 · Claude Code + MCPs + Warp

Una base Postgres mínima con **3 tablas relacionadas** para conectar el MCP de Postgres a Claude Code y pedirle una query con JOIN/agregación **sin pegar el schema**.

```
customers 1──< orders 1──< order_items
```

## Levantarla

Necesitás Docker. Desde esta carpeta:

```bash
docker compose up -d        # levanta Postgres 16 + carga init.sql
docker compose ps           # esperá a que diga "healthy"
```

La cadena de conexión (la que le pasás al MCP) es:

```
postgresql://app:app@localhost:5432/tienda
```

> Credenciales **de juguete** (`app:app`), datos de ejemplo sin información personal real. No uses esta DB para nada serio.

## Conectarla a Claude Code

Desde el repo de tu capstone (para que el `.mcp.json` quede ahí):

```bash
claude mcp add --scope project postgres \
  -- npx -y @modelcontextprotocol/server-postgres \
  "postgresql://app:app@localhost:5432/tienda"

claude mcp list             # postgres debería aparecer conectado
```

Después, en una sesión de Claude Code, **sin pegar el schema**:

```
> Mirá el schema de la base y dame los 5 clientes que más gastaron,
  con su país y el total, ordenado de mayor a menor.
```

Claude lee las tablas con la tool de Postgres y arma el JOIN solo. Si menciona
columnas que vos nunca escribiste (`customers.country`, `orders.total`), funcionó.

## Schema

| Tabla | Columnas | Relación |
|---|---|---|
| `customers` | `id, name, email, country, created_at` | — |
| `orders` | `id, customer_id, status, total, created_at` | `customer_id → customers.id` |
| `order_items` | `id, order_id, product, qty, unit_price` | `order_id → orders.id` |

Habilita JOIN `customers ↔ orders ↔ order_items` y agregaciones (`SUM`, `COUNT`,
`AVG`) — p. ej. gasto total por cliente, producto más vendido por país, ticket promedio.

## Apagar / reiniciar

```bash
docker compose down         # apaga, conserva los datos
docker compose down -v      # apaga y BORRA el volumen → init.sql corre de nuevo al subir
```

## Notas de seguridad (para la tarea)

- El MCP de Postgres de referencia (`@modelcontextprotocol/server-postgres`) es **read-only**: lee y consulta, no modifica. Perfecto para esta tarea.
- Si conectás **tu** DB real en vez de esta seed, hacé **backup antes** (`pg_dump`) y nunca uses producción ni datos personales.
- Las credenciales reales van por **variable de entorno**, nunca escritas en `.mcp.json`.
