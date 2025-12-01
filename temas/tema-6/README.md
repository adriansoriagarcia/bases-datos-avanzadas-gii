# 🧠 Tema 6 — Indexación y Asociación

Este tema explica cómo funcionan los **índices** en bases de datos, por qué aceleran las consultas y cuáles son las técnicas para almacenarlos y gestionarlos de manera eficiente. También introduce los **métodos de asociación**, usados para acceso directo a datos sin recurrir a índices tradicionales.

## 🖥️ Contenedor Docker para este tema

La descripción del contenedor Docker para poner en práctica los conceptos de este tema se encuentra disponible en el directorio [docker/postgres-tema-6](../../docker/postgres-tema-6/README.md)

## 1. ¿Qué es un índice en una base de datos?

Un índice funciona igual que el índice de un libro: permite **acceder rápidamente** a un registro sin leer toda la tabla.

Es una estructura adicional que mejora las consultas, pero que **consume espacio** y **incrementa el coste de inserción/borrado**.

Los criterios para evaluar una técnica de indexación son:

* Tiempo de acceso
* Tiempo de inserción
* Tiempo de borrado
* Tipos de acceso (búsqueda concreta o por rangos)
* Espacio adicional requerido

## 2. Tipos de índices ordenados

Los índices ordenados organizan las entradas siguiendo el orden de la clave de búsqueda. Se clasifican en:

### Índices con agrupación (o primarios)

* La clave de búsqueda coincide con el orden en que están almacenados los registros.
* Normalmente se basan en la clave primaria.

### Índices sin agrupación (o secundarios)

* La clave de búsqueda **no** coincide con el orden físico de los registros.

## 3. Índices densos y dispersos

Cada entrada del índice incluye un valor de la clave y un puntero a uno o varios registros. Existen dos variantes:

### Índice denso

* Contiene **una entrada por cada valor de clave**.
* Más rápido al buscar, pero **requiere más espacio** y más trabajo al actualizar.

### Índice disperso

* Contiene entradas solo para **algunos valores**.
* Más pequeño y fácil de mantener, pero más lento en búsquedas.

## 4. Índices multinivel

Cuando incluso un índice disperso es demasiado grande, se construyen **índices sobre índices**, formando varios niveles:

* El nivel superior suele mantenerse en memoria → búsquedas más rápidas.
* El proceso de búsqueda combina:

  * **Búsqueda binaria** en el índice externo.
  * **Búsqueda secuencial** en el interno.

Los índices con dos o más niveles se llaman **multinivel**.

## 5. Actualización de índices

Cada inserción o borrado exige actualizar el índice. Las acciones varían según el tipo:

### Inserciones

* **Densos:** si no existe la clave, se crea una entrada nueva.
* **Dispersos:** si aparece un nuevo bloque o cambia el mínimo valor del bloque, se actualiza la entrada.

### Borrados

* **Densos:** si se elimina el único registro con esa clave, se borra la entrada del índice.
* **Dispersos:** solo se actualiza si afectaba al bloque representado.

## 6. Asociación estática

Son una alternativa a los índices tradicionales. La asociación usa una función que asigna claves a **cajones** (buckets) donde se almacenan los registros.

Permite acceder a los datos **sin recorrer índices secuenciales**, pero puede causar **desbordamientos** si la distribución no es uniforme.

### Problemas típicos

* Cajones (_slots_) insuficientes
* Distribución desigual (atasco)
* Funciones de asociación mal diseñadas

También existen **índices asociativos**, que aplican esta técnica a tablas de índices.

## 7. ¿Cuándo usar índices en bases de datos?

Los índices permiten **consultas más rápidas** porque evitan leer todas las filas.
Sin embargo, tienen inconvenientes que obligan a planificar bien su diseño:

### ✔️ Ventajas

* Consultas más rápidas con menos E/S.
* Especialmente útiles con columnas de búsqueda frecuente (ej. país, fecha_alta).
* Mejoran el rendimiento de vistas con agregaciones o joins.

### ⚠️ Inconvenientes

* Ocupan espacio adicional.
* Dificultan inserciones, actualizaciones y borrados (más coste).
* Demasiados índices pueden degradar el rendimiento.

### Buenas prácticas

* No crear demasiados índices en tablas con muchas escrituras.
* Crear índices compuestos para consultas por varias columnas.
* Elegir el orden adecuado de las columnas en índices multicolumna.

## Índices basados en trigramas (`pg_trgm`)

Los *trigramas* son una técnica de indexación avanzada que permite acelerar búsquedas por similitud y consultas con patrones del tipo:

* `LIKE '%texto%'`
* `ILIKE '%cadena%'`
* Comparaciones por **distancia de edición**
* Búsquedas difusas o aproximadas

Este tipo de consulta normalmente **no puede utilizar índices B-tree**, porque el patrón empieza con un comodín (`%`), lo que impide ordenar eficientemente por prefijo. Sin embargo, PostgreSQL ofrece la extensión **`pg_trgm`**, que analiza el texto dividiéndolo en trigramas para permitir búsquedas ultra rápidas incluso en patrones no indexables de forma tradicional.

### ✔️ ¿Qué es un trigrama?

Un **trigrama** es un grupo de **tres caracteres consecutivos** extraídos de una cadena.

Ejemplo:

Cadena:

```text
"gato"
```

Trigramas generados:

```text
" ga", "gat", "ato", "o "
```

(Se añaden espacios virtuales al inicio y al final para capturar el contexto).

Esto permite comparar cadenas basándose en cuántos trigramas comparten, lo que es útil para medir **similitud** entre textos.

### ✔️ ¿Cómo funciona `pg_trgm`?

La extensión crea un índice especial (normalmente tipo **GIN**, aunque también permite **GiST**) que almacena los trigramas de cada valor de texto. Cuando se ejecuta una consulta con `LIKE '%texto%'`, PostgreSQL:

1. Divide el patrón de búsqueda en trigramas.
2. Busca en el índice qué filas contienen trigramas similares.
3. Reduce drásticamente el número de filas a examinar.
4. Compara las coincidencias reales para obtener el resultado final.

De este modo, consultas que normalmente requerirían un **Seq Scan** sobre miles o millones de filas pasan a usar un índice optimizado para búsquedas aproximadas.

### ✔️ Ejemplo de creación de índice de trigramas

La extensión debe activarse una vez:

```sql
CREATE EXTENSION IF NOT EXISTS pg_trgm;
```

Creación del índice:

```sql
CREATE INDEX idx_clientes_nombre_trgm
ON clientes USING gin (nombre gin_trgm_ops);
```

### ✔️ Comparación práctica

#### Sin índice

```sql
EXPLAIN ANALYZE
SELECT * FROM clientes
WHERE nombre ILIKE '%and%';
```

Plan esperado:

* `Seq Scan` por toda la tabla.
* Tiempo elevado si la tabla tiene muchos registros.

#### Con índice de trigramas

```sql
CREATE INDEX idx_clientes_nombre_trgm
ON clientes USING gin (nombre gin_trgm_ops);
```

Repetir consulta:

```sql
EXPLAIN ANALYZE
SELECT * FROM clientes
WHERE nombre ILIKE '%and%';
```

Plan esperado:

* `Bitmap Index Scan` o `Index Cond` usando `idx_clientes_nombre_trgm`.
* Tiempo muy reducido.
* Menos lecturas en disco.
* Escalabilidad mucho mayor.

### ✔️ ¿Cuándo usar trigramas?

Son especialmente útiles cuando:

* Existen búsquedas frecuentes con comodines al inicio (`%texto%`).
* Se buscan cadenas dentro de otras cadenas (substring search).
* Se realizan búsquedas de nombres, direcciones, productos, descripciones, etc.
* El texto es moderadamente largo (nombre, email, comentarios…).
* Se requieren búsquedas aproximadas (*fuzzy search*) con `similarity()`.

Ejemplo de comparación difusa:

```sql
SELECT *
FROM clientes
WHERE similarity(nombre, 'María') > 0.4
ORDER BY similarity(nombre, 'María') DESC;
```

### ✔️ Impacto y limitaciones

**Ventajas:**

* Aceleración espectacular de búsquedas con `%...%`.
* Compatibles con `LIKE`, `ILIKE`, `similarity` y operadores `<->`.
* Ideales para bases de datos con mucho texto.

**Limitaciones:**

* Consumen más espacio que un índice B-tree tradicional.
* Requieren más trabajo en inserciones y actualizaciones.
* No son idóneos para columnas muy cortas (p. ej., códigos de 2–3 caracteres).
