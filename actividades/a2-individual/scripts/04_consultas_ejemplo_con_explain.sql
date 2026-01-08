-- ===========================================================
-- 04 — Consultas de ejemplo (usar antes y después de índices)
-- Recomendación: ejecutar siempre con EXPLAIN (ANALYZE, BUFFERS).
-- ===========================================================

-- Q0) Estado del planner (útil para demo)
SHOW random_page_cost;
SHOW effective_cache_size;

-- Q1) Top-10 estaciones más baratas por tipo de carburante (precio "actual")
EXPLAIN (ANALYZE, BUFFERS)
SELECT
  e.id_estacion,
  e.direccion,
  m.nombre AS municipio,
  pr.nombre AS provincia,
  p.importe,
  p.fecha_reporte
FROM v_precio_ultimo p
JOIN estacion e   ON e.id_estacion = p.id_estacion
JOIN municipio m  ON m.id_municipio = e.id_municipio
JOIN provincia pr ON pr.id_provincia = m.id_provincia
WHERE p.id_tipo = (SELECT id_tipo FROM tipo_carburante WHERE codigo = 'G95E5')
ORDER BY p.importe ASC
LIMIT 10;

-- Q2) Empresa con más estaciones activas por provincia
EXPLAIN (ANALYZE, BUFFERS)
SELECT
  pr.nombre AS provincia,
  em.nombre_comercial AS empresa,
  count(*) AS total_estaciones
FROM estacion e
JOIN empresa em  ON em.id_empresa = e.id_empresa
JOIN municipio m ON m.id_municipio = e.id_municipio
JOIN provincia pr ON pr.id_provincia = m.id_provincia
WHERE e.activa = true
GROUP BY pr.nombre, em.nombre_comercial
ORDER BY pr.nombre, total_estaciones DESC;

-- Q3) Histórico: evolución semanal de precios (rango temporal)
EXPLAIN (ANALYZE, BUFFERS)
SELECT
  date_trunc('week', fecha_reporte) AS semana,
  avg(importe) AS precio_medio
FROM precio
WHERE id_tipo = (SELECT id_tipo FROM tipo_carburante WHERE codigo='GOA')
  AND fecha_reporte >= now() - interval '90 days'
GROUP BY 1
ORDER BY 1;

-- Q4) Búsqueda textual por rótulo (trigramas)
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM empresa
WHERE nombre_comercial ILIKE '%reps%';

-- Q5) Búsqueda textual por dirección
EXPLAIN (ANALYZE, BUFFERS)
SELECT id_estacion, direccion
FROM estacion
WHERE direccion ILIKE '%avenida%';
