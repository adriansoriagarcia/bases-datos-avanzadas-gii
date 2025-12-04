-- ===================================================================
-- Esquema: Modelo Gasolineras / Precios de Carburante (PostgreSQL)
-- ===================================================================
BEGIN;

-- =========================
-- TABLAS MAESTRO / CATÁLOGO
-- =========================

-- PROVINCIA
CREATE TABLE IF NOT EXISTS provincia (
  id_provincia   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre         text    NOT NULL,
  codigo_ine     text    UNIQUE
);

-- MUNICIPIO
CREATE TABLE IF NOT EXISTS municipio (
  id_municipio   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre         text    NOT NULL,
  id_provincia   integer NOT NULL REFERENCES provincia(id_provincia) ON UPDATE CASCADE ON DELETE RESTRICT,
  codigo_ine     text,
  CONSTRAINT uq_municipio_prov_nombre UNIQUE (id_provincia, nombre)
);

-- EMPRESA (Rótulo)
CREATE TABLE IF NOT EXISTS empresa (
  id_empresa       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre_comercial text    NOT NULL,
  razon_social     text,
  CONSTRAINT uq_empresa_rotulo UNIQUE (nombre_comercial)
);

-- SERVICIO (catálogo)
CREATE TABLE IF NOT EXISTS servicio (
  id_servicio integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre      text NOT NULL,
  CONSTRAINT uq_servicio_nombre UNIQUE (nombre)
);

-- TIPO_CARBURANTE (catálogo)
CREATE TABLE IF NOT EXISTS tipo_carburante (
  id_tipo integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo  text    NOT NULL,        -- p. ej. G95E5, GOA, GLP, GNC, ...
  nombre  text    NOT NULL,
  unidad  text    NOT NULL DEFAULT '€/litro',
  CONSTRAINT uq_tipo_codigo UNIQUE (codigo)
);

-- ==========
-- ENTIDADES
-- ==========

-- HORARIO (texto libre)
CREATE TABLE IF NOT EXISTS horario (
  id_horario integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  descripcion text NOT NULL
);

-- ESTACION
CREATE TABLE IF NOT EXISTS estacion (
  id_estacion     integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  -- mapea IDEESS si lo deseas
  id_empresa      integer NOT NULL REFERENCES empresa(id_empresa) ON UPDATE CASCADE ON DELETE RESTRICT,
  id_municipio    integer NOT NULL REFERENCES municipio(id_municipio) ON UPDATE CASCADE ON DELETE RESTRICT,
  id_horario      integer REFERENCES horario(id_horario) ON UPDATE CASCADE ON DELETE SET NULL,
  direccion       text,
  codigo_postal   text,
  margen          text,                            -- 'D' (derecha), 'I' (izquierda), 'N' (no aplica)
  latitud         numeric(9,6),                    -- rango aprox. [-90, 90]
  longitud        numeric(9,6),                    -- rango aprox. [-180, 180]
  telefono        text,
  activa          boolean NOT NULL DEFAULT TRUE,
  fecha_actualizacion timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT ck_margen_valido CHECK (margen IS NULL OR margen IN ('D','I','N')),
  CONSTRAINT ck_latitud CHECK (latitud IS NULL OR (latitud >= -90 AND latitud <= 90)),
  CONSTRAINT ck_longitud CHECK (longitud IS NULL OR (longitud >= -180 AND longitud <= 180))
);

-- RELACIÓN N..M: ESTACION - SERVICIO
CREATE TABLE IF NOT EXISTS estacion_servicio (
  id_estacion integer NOT NULL REFERENCES estacion(id_estacion) ON UPDATE CASCADE ON DELETE CASCADE,
  id_servicio integer NOT NULL REFERENCES servicio(id_servicio) ON UPDATE CASCADE ON DELETE RESTRICT,
  observaciones text,
  PRIMARY KEY (id_estacion, id_servicio)
);

-- PRECIOS (histórico por estación y tipo de carburante)
CREATE TABLE IF NOT EXISTS precio (
  id_precio     bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_estacion   integer NOT NULL REFERENCES estacion(id_estacion) ON UPDATE CASCADE ON DELETE CASCADE,
  id_tipo       integer NOT NULL REFERENCES tipo_carburante(id_tipo) ON UPDATE CASCADE ON DELETE RESTRICT,
  importe       numeric(6,3) NOT NULL,           -- p. ej., 1.589 €/l
  fecha_reporte timestamptz NOT NULL,            -- instante del precio reportado
  fuente        text,
  -- Evita duplicados exactos para la misma estación, tipo y timestamp
  CONSTRAINT uq_precio_punto_temporal UNIQUE (id_estacion, id_tipo, fecha_reporte),
  -- Precio no negativo y razonable
  CONSTRAINT ck_importe_rango CHECK (importe >= 0 AND importe < 10)
);

-- =========
-- ÍNDICES
-- =========

-- Búsquedas frecuentes y FKs
CREATE INDEX IF NOT EXISTS idx_municipio_provincia ON municipio(id_provincia);
CREATE INDEX IF NOT EXISTS idx_estacion_empresa   ON estacion(id_empresa);
CREATE INDEX IF NOT EXISTS idx_estacion_municipio ON estacion(id_municipio);
CREATE INDEX IF NOT EXISTS idx_estacion_activa    ON estacion(activa);
CREATE INDEX IF NOT EXISTS idx_estacion_geo       ON estacion(latitud, longitud);

CREATE INDEX IF NOT EXISTS idx_precio_estacion      ON precio(id_estacion);
CREATE INDEX IF NOT EXISTS idx_precio_tipo          ON precio(id_tipo);
CREATE INDEX IF NOT EXISTS idx_precio_fecha         ON precio(fecha_reporte);
CREATE INDEX IF NOT EXISTS idx_precio_est_tipo_fecha ON precio(id_estacion, id_tipo, fecha_reporte DESC);

-- (Opcional) si harás búsquedas por código postal
CREATE INDEX IF NOT EXISTS idx_estacion_cp ON estacion(codigo_postal);

-- (Opcional) si harás búsquedas por texto en nombre de empresa / servicio
-- CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- CREATE INDEX IF NOT EXISTS idx_empresa_rotulo_trgm ON empresa USING gin (nombre_comercial gin_trgm_ops);
-- CREATE INDEX IF NOT EXISTS idx_servicio_nombre_trgm ON servicio USING gin (nombre gin_trgm_ops);

COMMIT;
