SET search_path TO demo9;

-- 1) Baseline (probable seq scan)
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, customer_id, order_ts, total_amount
FROM orders
WHERE customer_id = 12345
ORDER BY order_ts DESC
LIMIT 20;

-- 2) Crear índice (NO lo crees hasta el momento didáctico)
-- Ejecuta esta parte cuando quieras mostrar el impacto:
-- CREATE INDEX idx_orders_customer_ts_desc ON orders(customer_id, order_ts DESC);

-- 3) Repetir la consulta y comparar plan
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, customer_id, order_ts, total_amount
FROM orders
WHERE customer_id = 12345
ORDER BY order_ts DESC
LIMIT 20;

-- 4) Variante por filtro + status
-- CREATE INDEX idx_orders_status_ts ON orders(status, order_ts DESC);

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM orders
WHERE status = 'CANCELLED'
  AND order_ts >= now() - interval '90 days';
