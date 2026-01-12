SET search_path TO demo9;

-- JOIN típico: pedidos + clientes + items
EXPLAIN (ANALYZE, BUFFERS)
SELECT
  c.city,
  count(*) AS num_items,
  round(sum(oi.qty * oi.unit_price)::numeric, 2) AS revenue
FROM customers c
JOIN orders o      ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status IN ('PAID','SHIPPED')
  AND o.order_ts >= now() - interval '60 days'
GROUP BY c.city
ORDER BY revenue DESC;

-- Forzar estrategia (solo para demo; no es “buena práctica” en producción)
-- 1) Probar sin hash join
SET enable_hashjoin = off;

EXPLAIN (ANALYZE, BUFFERS)
SELECT
  c.city,
  count(*) AS num_items,
  round(sum(oi.qty * oi.unit_price)::numeric, 2) AS revenue
FROM customers c
JOIN orders o      ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status IN ('PAID','SHIPPED')
  AND o.order_ts >= now() - interval '60 days'
GROUP BY c.city
ORDER BY revenue DESC;

RESET enable_hashjoin;

-- Índices que puedes crear EN CLASE para mejorar joins (no automáticos):
-- CREATE INDEX idx_orders_customer ON orders(customer_id);
-- CREATE INDEX idx_items_order ON order_items(order_id);
