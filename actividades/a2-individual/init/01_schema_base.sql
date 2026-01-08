BEGIN;

CREATE TABLE IF NOT EXISTS provincia (
  id_provincia   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre         text    NOT NULL,
  codigo_ine     text    UNIQUE
);

CREATE TABLE IF NOT EXISTS municipio (
  id_municipio   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre         text    NOT NULL,
  id_provincia   integer NOT NULL REFERENCES provincia(id_provincia) ON UPDATE CASCADE ON DELETE RESTRICT,
  codigo_ine     text,
  CONSTRAINT uq_municipio_prov_nombre UNIQUE (id_provincia, nombre)
);

CREATE TABLE IF NOT EXISTS empresa (
  id_empresa       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre_comercial text    NOT NULL,
  razon_social     text,
  CONSTRAINT uq_empresa_rotulo UNIQUE (nombre_comercial)
);

CREATE TABLE IF NOT EXISTS servicio (
  id_servicio integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre      text NOT NULL,
  CONSTRAINT uq_servicio_nombre UNIQUE (nombre)
);

CREATE TABLE IF NOT EXISTS tipo_carburante (
  id_tipo integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo  text    NOT NULL,
  nombre  text    NOT NULL,
  unidad  text    NOT NULL DEFAULT '€/litro',
  CONSTRAINT uq_tipo_codigo UNIQUE (codigo)
);

CREATE TABLE IF NOT EXISTS horario (
  id_horario integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  descripcion text NOT NULL
);

CREATE TABLE IF NOT EXISTS estacion (
  id_estacion     integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_empresa      integer NOT NULL REFERENCES empresa(id_empresa) ON UPDATE CASCADE ON DELETE RESTRICT,
  id_municipio    integer NOT NULL REFERENCES municipio(id_municipio) ON UPDATE CASCADE ON DELETE RESTRICT,
  id_horario      integer REFERENCES horario(id_horario) ON UPDATE CASCADE ON DELETE SET NULL,
  direccion       text,
  codigo_postal   text,
  margen          text,
  latitud         numeric(9,6),
  longitud        numeric(9,6),
  telefono        text,
  activa          boolean NOT NULL DEFAULT TRUE,
  fecha_actualizacion timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT ck_margen_valido CHECK (margen IS NULL OR margen IN ('D','I','N')),
  CONSTRAINT ck_latitud CHECK (latitud IS NULL OR (latitud >= -90 AND latitud <= 90)),
  CONSTRAINT ck_longitud CHECK (longitud IS NULL OR (longitud >= -180 AND longitud <= 180))
);

CREATE TABLE IF NOT EXISTS estacion_servicio (
  id_estacion integer NOT NULL REFERENCES estacion(id_estacion) ON UPDATE CASCADE ON DELETE CASCADE,
  id_servicio integer NOT NULL REFERENCES servicio(id_servicio) ON UPDATE CASCADE ON DELETE RESTRICT,
  observaciones text,
  PRIMARY KEY (id_estacion, id_servicio)
);

CREATE TABLE IF NOT EXISTS precio (
  id_precio     bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  id_estacion   integer NOT NULL REFERENCES estacion(id_estacion) ON UPDATE CASCADE ON DELETE CASCADE,
  id_tipo       integer NOT NULL REFERENCES tipo_carburante(id_tipo) ON UPDATE CASCADE ON DELETE RESTRICT,
  importe       numeric(6,3) NOT NULL,
  fecha_reporte timestamptz NOT NULL,
  fuente        text,
  CONSTRAINT uq_precio_punto_temporal UNIQUE (id_estacion, id_tipo, fecha_reporte),
  CONSTRAINT ck_importe_rango CHECK (importe >= 0 AND importe < 10)
);

COMMIT;
