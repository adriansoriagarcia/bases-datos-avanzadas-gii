-- ===========================================================
-- 01 — ¿Qué índices hay por defecto tras crear el esquema?
-- PostgreSQL crea índices automáticamente para:
--  - PRIMARY KEY
--  - UNIQUE
-- (y para constraints EXCLUDE, si existieran)
--
-- Importante: PostgreSQL NO crea índices automáticamente en FKs.
-- ===========================================================

-- 1) Listado de índices existentes (incluye PK/UNIQUE)
SELECT
  n.nspname  AS esquema,
  t.relname  AS tabla,
  i.relname  AS indice,
  pg_get_indexdef(ix.indexrelid) AS definicion,
  ix.indisunique AS es_unico,
  ix.indisprimary AS es_pk
FROM pg_class t
JOIN pg_namespace n ON n.oid = t.relnamespace
JOIN pg_index ix ON ix.indrelid = t.oid
JOIN pg_class i ON i.oid = ix.indexrelid
WHERE t.relkind = 'r'
  AND n.nspname = 'public'
ORDER BY tabla, indice;

-- 2) ¿Qué constraints generan índices?
SELECT
  conrelid::regclass AS tabla,
  conname AS constraint,
  contype AS tipo_constraint,
  pg_get_constraintdef(oid) AS definicion
FROM pg_constraint
WHERE connamespace = 'public'::regnamespace
  AND contype IN ('p','u')  -- primary key, unique
ORDER BY tabla, contype, conname;

-- 3) Detectar claves foráneas (FK) SIN índice en la(s) columna(s) FK
-- (Esto suele degradar JOINs y operaciones de DELETE/UPDATE en la tabla padre).
WITH fks AS (
  SELECT
    c.conname,
    c.conrelid::regclass AS tabla_hija,
    c.confrelid::regclass AS tabla_padre,
    c.conkey,
    array_agg(a.attname ORDER BY ord.n) AS cols_fk
  FROM pg_constraint c
  JOIN LATERAL unnest(c.conkey) WITH ORDINALITY AS ord(attnum, n) ON TRUE
  JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = ord.attnum
  WHERE c.contype = 'f'
    AND c.connamespace = 'public'::regnamespace
  GROUP BY c.conname, c.conrelid, c.confrelid, c.conkey
),
fk_index AS (
  SELECT
    t.oid AS tab_oid,
    ix.indexrelid,
    ix.indkey::int2[] AS ind_cols
  FROM pg_class t
  JOIN pg_namespace n ON n.oid = t.relnamespace
  JOIN pg_index ix ON ix.indrelid = t.oid
  WHERE t.relkind='r' AND n.nspname='public'
)
SELECT
  f.conname,
  f.tabla_hija,
  f.tabla_padre,
  f.cols_fk,
  CASE
    WHEN EXISTS (
      SELECT 1
      FROM fk_index fi
      WHERE fi.tab_oid = (SELECT oid FROM pg_class WHERE relname = split_part(f.tabla_hija::text,'.',2))
        AND fi.ind_cols[1:array_length(f.conkey,1)] = f.conkey::int2[]
    )
    THEN 'OK (hay índice que cubre el prefijo FK)'
    ELSE 'FALTA ÍNDICE en FK (recomendado)'
  END AS diagnostico
FROM fks f
ORDER BY f.tabla_hija::text, f.conname;
