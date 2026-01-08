# Actividad 2 — Índices en bases de datos (PostgreSQL)

Este paquete contiene una **solución de referencia** para la Actividad 2, basada en un modelo relacional para precios de carburantes.

## Contenido

- `00_schema_base.sql`  
  Crea el esquema (tablas + PK/UK/FK + CHECK). **No** crea índices adicionales manuales (solo los que PostgreSQL crea automáticamente por PK/UNIQUE).

- `01_listar_indices_por_defecto.sql`  
  Consultas para listar **índices creados por defecto** (PK/UNIQUE) y para identificar FKs sin índice.

- `02_indices_para_mejorar_consultas.sql`  
  Índices propuestos para mejorar consultas típicas del dominio (último precio por estación, búsquedas por provincia/municipio, filtros por carburante, etc.).

- `03_indices_extra_justificados.sql`  
  Índices adicionales (parciales, BRIN, trigramas) con justificación y una consulta ejemplo por cada uno.

- `04_consultas_ejemplo_con_explain.sql`  
  Consultas de ejemplo y plantilla de medición con `EXPLAIN (ANALYZE, BUFFERS)`.

## Uso recomendado

1) Ejecutar el esquema base:

```sql
\i 00_schema_base.sql
```

2) Ver índices “por defecto”:

```sql
\i 01_listar_indices_por_defecto.sql
```

3) Medir consultas **antes** de crear índices adicionales (usar `04_consultas_ejemplo_con_explain.sql`).

4) Crear índices propuestos:

```sql
\i 02_indices_para_mejorar_consultas.sql
\i 03_indices_extra_justificados.sql
```

5) Repetir `EXPLAIN (ANALYZE, BUFFERS)` y comparar planes y tiempos.

Notas:
- En PostgreSQL, **PK** y **UNIQUE** crean índices automáticamente.
- PostgreSQL **NO** crea índices automáticamente para claves foráneas (FK); si se consultan o se usan en JOINs con frecuencia, conviene indexarlas.
