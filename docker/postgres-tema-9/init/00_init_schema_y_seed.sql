BEGIN;

-- Extensiones para el Tema 9 (monitorización y análisis)
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Esquema de trabajo
CREATE SCHEMA IF NOT EXISTS demo9;
SET search_path TO demo9;

-- =========================
-- Tablas (modelo sencillo)
-- =========================

CREATE TABLE IF NOT EXISTS customers (
  customer_id  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  full_name    text NOT NULL,
  email        text NOT NULL UNIQUE,
  city         text NOT NULL,
  created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS orders (
  order_id     bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id  bigint NOT NULL REFERENCES customers(customer_id),
  order_ts     timestamptz NOT NULL,
  status       text NOT NULL CHECK (status IN ('CREATED','PAID','SHIPPED','CANCELLED')),
  total_amount numeric(12,2) NOT NULL CHECK (total_amount >= 0)
);

CREATE TABLE IF NOT EXISTS order_items (
  order_item_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id      bigint NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
  product_sku   text NOT NULL,
  qty           int NOT NULL CHECK (qty > 0),
  unit_price    numeric(10,2) NOT NULL CHECK (unit_price >= 0)
);

-- =========================
-- Datos de prueba
-- =========================
-- Ajusta el volumen si lo deseas:
-- - 20.000 clientes
-- - 200.000 pedidos
-- - 600.000 líneas (3 por pedido)

INSERT INTO customers (full_name, email, city, created_at)
SELECT
  'Cliente ' || g,
  'cliente' || g || '@demo.local',
  (ARRAY['Madrid','Barcelona','Valencia','Sevilla','Bilbao','Santander'])[ (g % 6) + 1 ],
  now() - ((g % 365) || ' days')::interval
FROM generate_series(1, 20000) AS g;

INSERT INTO orders (customer_id, order_ts, status, total_amount)
SELECT
  (1 + (random() * 19999))::bigint,
  now() - ((random() * 180)::int || ' days')::interval,
  (ARRAY['CREATED','PAID','SHIPPED','CANCELLED'])[ (g % 4) + 1 ],
  round((10 + random() * 490)::numeric, 2)
FROM generate_series(1, 200000) AS g;

-- 3 items por pedido (600k)
INSERT INTO order_items (order_id, product_sku, qty, unit_price)
SELECT
  o.order_id,
  'SKU-' || (1 + (random()*5000)::int),
  1 + (random()*4)::int,
  round((1 + random()*200)::numeric, 2)
FROM orders o
CROSS JOIN generate_series(1,3) AS it(n);

-- Estadísticas iniciales
ANALYZE;

COMMIT;
