BEGIN;

-- =====================
-- Catálogos base
-- =====================

INSERT INTO provincia (nombre, codigo_ine) VALUES
('Madrid', '28'),
('Cantabria', '39'),
('Barcelona', '08'),
('Valencia', '46'),
('Sevilla', '41')
ON CONFLICT DO NOTHING;

-- 10 municipios por provincia (50 en total)
INSERT INTO municipio (nombre, id_provincia, codigo_ine)
SELECT
  'Municipio ' || p.codigo_ine || '-' || m.n,
  p.id_provincia,
  p.codigo_ine || lpad(m.n::text, 3, '0')
FROM provincia p
CROSS JOIN generate_series(1,10) AS m(n)
ON CONFLICT DO NOTHING;

INSERT INTO empresa (nombre_comercial, razon_social) VALUES
('REPSOL', 'REPSOL S.A.'),
('CEPSA', 'CEPSA S.A.'),
('BP', 'BP Oil España S.A.'),
('SHELL', 'SHELL España S.A.'),
('CARREFOUR', 'CARREFOUR Petróleo S.L.')
ON CONFLICT DO NOTHING;

INSERT INTO horario (descripcion) VALUES
('L-D 24H'),
('L-V 07:00-22:00; S 08:00-20:00'),
('L-S 06:00-23:00; D 08:00-22:00')
ON CONFLICT DO NOTHING;

INSERT INTO servicio (nombre) VALUES
('Tienda'), ('Lavado'), ('Aseos'), ('Aire/Agua'), ('Cafetería')
ON CONFLICT DO NOTHING;

-- Tipos de carburante típicos (puedes ampliar)
INSERT INTO tipo_carburante (codigo, nombre, unidad) VALUES
('G95E5', 'Gasolina 95 E5', '€/litro'),
('G98E5', 'Gasolina 98 E5', '€/litro'),
('GOA',   'Gasóleo A',      '€/litro'),
('GLP',   'GLP',            '€/litro')
ON CONFLICT DO NOTHING;

-- =====================
-- Estaciones (p.ej. 300)
-- =====================

-- Parámetros “didácticos”
-- - 300 estaciones
-- - coordenadas aproximadas dentro de España (no exactas)
WITH
mun AS (
  SELECT id_municipio FROM municipio ORDER BY id_municipio
),
emp AS (
  SELECT id_empresa FROM empresa ORDER BY id_empresa
),
hor AS (
  SELECT id_horario FROM horario ORDER BY id_horario
)
INSERT INTO estacion (
  id_empresa, id_municipio, id_horario,
  direccion, codigo_postal, margen,
  latitud, longitud, telefono, activa, fecha_actualizacion
)
SELECT
  (SELECT id_empresa FROM emp OFFSET (g % 5) LIMIT 1),
  (SELECT id_municipio FROM mun OFFSET (g % (SELECT count(*) FROM mun)) LIMIT 1),
  (SELECT id_horario FROM hor OFFSET (g % 3) LIMIT 1),
  'Calle ' || g || ', Nº ' || ((g % 50) + 1),
  lpad(((28000 + (g % 700))::text), 5, '0'),
  (ARRAY['D','I','N'])[ (g % 3) + 1 ],
  round((36.0 + random()*7.0)::numeric, 6),       -- lat ~ [36,43]
  round((-9.0 + random()*12.0)::numeric, 6),      -- lon ~ [-9,3]
  '+34' || lpad(((600000000 + (random()*99999999)::int)::text), 9, '0'),
  CASE WHEN (g % 20) = 0 THEN false ELSE true END, -- ~5% inactivas
  now() - (random()*30 || ' days')::interval
FROM generate_series(1, 300) AS g
ON CONFLICT DO NOTHING;

-- =====================
-- Servicios por estación (asignación aleatoria simple)
-- =====================
INSERT INTO estacion_servicio (id_estacion, id_servicio, observaciones)
SELECT
  e.id_estacion,
  s.id_servicio,
  NULL
FROM estacion e
JOIN servicio s ON ( (e.id_estacion + s.id_servicio) % 2 = 0 )
ON CONFLICT DO NOTHING;

-- =====================
-- Precios (histórico)
--  - 30 días
--  - 4 carburantes
--  - 300 estaciones
--  => 300 * 4 * 30 = 36.000 filas
-- =====================
WITH tipos AS (
  SELECT id_tipo, codigo FROM tipo_carburante
),
dias AS (
  SELECT (now() - (d || ' days')::interval) AS ts
  FROM generate_series(0, 29) AS d
)
INSERT INTO precio (id_estacion, id_tipo, importe, fecha_reporte, fuente)
SELECT
  e.id_estacion,
  t.id_tipo,
  CASE t.codigo
    WHEN 'G95E5' THEN round((1.45 + random()*0.25)::numeric, 3)
    WHEN 'G98E5' THEN round((1.55 + random()*0.25)::numeric, 3)
    WHEN 'GOA'   THEN round((1.35 + random()*0.25)::numeric, 3)
    WHEN 'GLP'   THEN round((0.85 + random()*0.20)::numeric, 3)
    ELSE round((1.50 + random()*0.30)::numeric, 3)
  END AS importe,
  d.ts,
  'seed_demo'
FROM estacion e
CROSS JOIN tipos t
CROSS JOIN dias d
ON CONFLICT DO NOTHING;

ANALYZE;

COMMIT;
