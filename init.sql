-- ============================================================
-- Seed DB para S5.2 — Claude Code + MCPs + Warp
-- 3 tablas relacionadas que habilitan JOIN y agregación:
--   customers 1──< orders 1──< order_items
-- El MCP de Postgres lee este schema SOLO; el alumno nunca lo pega.
-- ============================================================

CREATE TABLE customers (
    id          SERIAL PRIMARY KEY,
    name        TEXT        NOT NULL,
    email       TEXT        NOT NULL UNIQUE,
    country     TEXT        NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE orders (
    id           SERIAL PRIMARY KEY,
    customer_id  INTEGER     NOT NULL REFERENCES customers(id),
    status       TEXT        NOT NULL DEFAULT 'paid',  -- paid | pending | cancelled
    total        NUMERIC(10,2) NOT NULL DEFAULT 0,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE order_items (
    id          SERIAL PRIMARY KEY,
    order_id    INTEGER     NOT NULL REFERENCES orders(id),
    product     TEXT        NOT NULL,
    qty         INTEGER     NOT NULL CHECK (qty > 0),
    unit_price  NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)
);

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);

-- ---------- datos de ejemplo (de juguete, sin datos personales reales) ----------
INSERT INTO customers (name, email, country) VALUES
    ('Ana Torres',     'ana@example.com',   'AR'),
    ('Bruno Díaz',     'bruno@example.com', 'CL'),
    ('Carla Méndez',   'carla@example.com', 'MX'),
    ('Diego Rivas',    'diego@example.com', 'CO'),
    ('Elena Soto',     'elena@example.com', 'ES');

INSERT INTO orders (customer_id, status, total) VALUES
    (1, 'paid',      120.00),
    (1, 'paid',       80.00),
    (2, 'paid',      300.00),
    (3, 'paid',       45.50),
    (3, 'pending',    99.00),
    (4, 'paid',      210.75),
    (5, 'paid',      540.00),
    (5, 'cancelled',  60.00);

INSERT INTO order_items (order_id, product, qty, unit_price) VALUES
    (1, 'Teclado mecánico', 1, 120.00),
    (2, 'Mouse inalámbrico', 2, 40.00),
    (3, 'Monitor 27"',      1, 300.00),
    (4, 'Cable USB-C',      5,  9.10),
    (5, 'Webcam HD',        1, 99.00),
    (6, 'Silla ergonómica', 1, 210.75),
    (7, 'Notebook',         1, 540.00),
    (8, 'Auriculares',      1, 60.00);
