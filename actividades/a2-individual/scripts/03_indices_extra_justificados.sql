-- ===========================================================
-- 03 — Índices extra justificados (con consulta ejemplo)
-- Incluye: parciales, BRIN, trigramas.
-- ===========================================================

-- A) Índice parcial: estaciones activas (si la mayoría son activas/inactivas según dataset)
-- Útil cuando la consulta SIEMPRE filtra por activa=true.
CREATE INDEX IF NOT EXISTS idx_estacion_activa_true
ON estacion(id_municipio, id_empresa)
WHERE activa = true;

-- Ejemplo:
-- EXPLAIN (ANALYZE, BUFFERS)
-- SELECT e.id_estacion, e.direccion
-- FROM estacion e
-- WHERE e.activa = true AND e.id_municipio = 10;

-- B) BRIN para series temporales grandes (histórico masivo de precios)
-- BRIN es muy compacto y acelera rangos temporales sobre tablas enormes.
CREATE INDEX IF NOT EXISTS idx_precio_fecha_brin
ON precio USING brin (fecha_reporte);

-- Ejemplo:
-- EXPLAIN (ANALYZE, BUFFERS)
-- SELECT count(*)
-- FROM precio
-- WHERE fecha_reporte >= now() - interval '7 days';

-- C) Trigramas para búsquedas por texto (rótulo/empresa, municipio, dirección)
-- Requiere extensión pg_trgm.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX IF NOT EXISTS idx_empresa_nombre_trgm
ON empresa USING gin (nombre_comercial gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_estacion_direccion_trgm
ON estacion USING gin (direccion gin_trgm_ops);

-- Ejemplos:
-- EXPLAIN (ANALYZE, BUFFERS)
-- SELECT * FROM empresa WHERE nombre_comercial ILIKE '%reps%';
--
-- EXPLAIN (ANALYZE, BUFFERS)
-- SELECT * FROM estacion WHERE direccion ILIKE '%avenida%';

-- D) Índice compuesto para ranking de precios por municipio y carburante (consulta típica “más barata”)
-- Se asume uso de v_precio_ultimo (precio actual).
CREATE INDEX IF NOT EXISTS idx_precio_ultimo_lookup
ON precio (id_tipo, importe, id_estacion);

-- Ejemplo (tras crear v_precio_ultimo):
-- EXPLAIN (ANALYZE, BUFFERS)
-- SELECT e.id_estacion, e.direccion, p.importe
-- FROM v_precio_ultimo p
-- JOIN estacion e ON e.id_estacion = p.id_estacion
-- WHERE p.id_tipo = (SELECT id_tipo FROM tipo_carburante WHERE codigo='G95E5')
-- ORDER BY p.importe
-- LIMIT 10;
