-- ===========================================================
-- 02 — Índices propuestos para mejorar consultas típicas
-- Objetivo: acelerar filtros/JOINs frecuentes y consultas de "último precio"
-- ===========================================================
BEGIN;

-- 1) Índices para FKs (JOINs y mantenimiento de integridad)
CREATE INDEX IF NOT EXISTS idx_municipio_id_provincia ON municipio(id_provincia);
CREATE INDEX IF NOT EXISTS idx_estacion_id_empresa   ON estacion(id_empresa);
CREATE INDEX IF NOT EXISTS idx_estacion_id_municipio ON estacion(id_municipio);
CREATE INDEX IF NOT EXISTS idx_precio_id_estacion    ON precio(id_estacion);
CREATE INDEX IF NOT EXISTS idx_precio_id_tipo        ON precio(id_tipo);

-- 2) Consulta típica: "último precio por estación y carburante"
-- El UNIQUE (id_estacion,id_tipo,fecha_reporte) ayuda, pero un índice DESC mejora ORDER BY/LIMIT.
CREATE INDEX IF NOT EXISTS idx_precio_est_tipo_fecha_desc
  ON precio(id_estacion, id_tipo, fecha_reporte DESC);

-- 3) Búsquedas por actividad/visibilidad de estación
CREATE INDEX IF NOT EXISTS idx_estacion_activa ON estacion(activa);

-- 4) Filtros por código postal (si se usa)
CREATE INDEX IF NOT EXISTS idx_estacion_codigo_postal ON estacion(codigo_postal);

COMMIT;

-- Vista de apoyo: último precio (muy útil para consultas "precio actual")
CREATE OR REPLACE VIEW v_precio_ultimo AS
SELECT p.*
FROM precio p
JOIN (
  SELECT id_estacion, id_tipo, max(fecha_reporte) AS max_ts
  FROM precio
  GROUP BY id_estacion, id_tipo
) u
ON u.id_estacion = p.id_estacion
AND u.id_tipo = p.id_tipo
AND u.max_ts = p.fecha_reporte;
