SET search_path TO demo9;

-- Fuerza un escenario de ordenación grande
-- 1) work_mem bajo (probable external sort si el dataset lo requiere)
SET work_mem = '1MB';

EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, total_amount
FROM orders
ORDER BY total_amount DESC
LIMIT 20000;

-- 2) work_mem más alto (más probable sort en memoria)
SET work_mem = '64MB';

EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, total_amount
FROM orders
ORDER BY total_amount DESC
LIMIT 20000;

-- Restablecer si quieres
RESET work_mem;
