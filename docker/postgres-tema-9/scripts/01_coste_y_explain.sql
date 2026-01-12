SET search_path TO demo9;

-- Ver parámetros relevantes del optimizador / ejecución
SHOW work_mem;
SHOW random_page_cost;
SHOW effective_cache_size;

-- EXPLAIN sin ejecución
EXPLAIN
SELECT * FROM orders
WHERE status = 'SHIPPED' AND order_ts >= now() - interval '30 days';

-- EXPLAIN con ejecución real + buffers
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM orders
WHERE status = 'SHIPPED' AND order_ts >= now() - interval '30 days';
