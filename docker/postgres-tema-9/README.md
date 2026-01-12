# Entorno Docker del Tema 9 - Ejecución y procesamiento de consultas en PostgreSQL

En este tema vamos a estudiar **cómo PostgreSQL ejecuta realmente una consulta SQL**.
No nos centraremos solo en *qué* devuelve una consulta, sino en **cómo llega a ese resultado** y **cuánto cuesta** obtenerlo.

## 🎯 Objetivos de aprendizaje

Al finalizar esta guía deberías ser capaz de:

* Entender que una consulta SQL pasa por **varias fases internas**.
* Leer e interpretar un **plan de ejecución** (`EXPLAIN`).
* Distinguir entre **coste estimado** y **tiempo real**.
* Comprender por qué PostgreSQL elige un **tipo de acceso** (secuencial o por índice).
* Ver el impacto de **índices**, **memoria** y **ordenación**.
* Utilizar herramientas de **monitorización** para detectar consultas costosas.

## ¿Qué ocurre cuando ejecutas una consulta SQL?

Cuando escribes una consulta como:

```sql
SELECT *
FROM orders
WHERE status = 'SHIPPED'
  AND order_ts >= now() - interval '30 days';
```

PostgreSQL **no empieza a leer datos inmediatamente**.

Internamente realiza estos pasos:

1. **Análisis**: comprueba que la consulta es válida.
2. **Optimización**: calcula varios planes posibles y elige el de **menor coste estimado**.
3. **Ejecución**: ejecuta el plan elegido.

> 📌 **Idea clave**
> PostgreSQL no busca el plan “perfecto”, busca el **más barato según su modelo de costes**.

## EXPLAIN y EXPLAIN ANALYZE

### EXPLAIN: ver el plan sin ejecutar

```sql
EXPLAIN
SELECT *
FROM orders
WHERE status = 'SHIPPED'
  AND order_ts >= now() - interval '30 days';
```

Esto muestra **cómo PostgreSQL ejecutaría la consulta**, pero **no accede a los datos**.

Sirve para:

* Ver el tipo de acceso (secuencial, índice…)
* Ver el coste estimado
* Entender la estrategia general

### EXPLAIN ANALYZE: ejecutar y medir

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM orders
WHERE status = 'SHIPPED'
  AND order_ts >= now() - interval '30 days';
```

Aquí PostgreSQL:

* Ejecuta realmente la consulta
* Mide tiempos reales
* Muestra uso de memoria y disco

> 📌 **Idea clave**
> `EXPLAIN` = estimación
> `EXPLAIN ANALYZE` = realidad

## Interpretando un plan de ejecución real

Ejemplo de salida:

```text
Seq Scan on orders
(cost=0.00..5725.00 rows=8603 width=37)
(actual time=0.013..16.395 rows=8297 loops=1)
Filter: (status = 'SHIPPED' AND order_ts >= now() - '30 days')
Rows Removed by Filter: 191703
Buffers: shared hit=1725
```

### Seq Scan on orders

* PostgreSQL ha leído **toda la tabla `orders` fila a fila**.
* No se ha usado ningún índice.

>📌 **Qué significa**
> PostgreSQL ha decidido que leer toda la tabla es más barato que usar un índice (o no había uno útil).

### cost=0.00..5725.00

* **No es tiempo**
* Es una **unidad interna de coste**
* Se usa solo para comparar planes entre sí

> 📌 **Idea clave**
> El optimizador compara **costes**, no milisegundos.

### rows estimadas vs reales

* Estimadas: `rows=8603`
* Reales: `rows=8297`

La estimación es bastante buena, lo que indica que las **estadísticas están actualizadas**.

### Rows Removed by Filter

```text
Rows Removed by Filter: 191703
```

Esta es una de las líneas más importantes.

* PostgreSQL leyó casi **200.000 filas**
* Solo ~8.300 eran válidas
* Más del **95 % del trabajo se descartó**

> 📌 **Idea clave**
> Leer datos para luego descartarlos es caro.
> Los índices evitan este trabajo innecesario.

### Buffers: shared hit

* Los datos estaban en memoria
* No hubo lecturas de disco

> 📌 **Advertencia importante**
> La consulta es rápida porque los datos caben en RAM,
> no porque el plan sea bueno.

## Selección: sin índice vs con índice

### Consulta sin índice

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, customer_id, order_ts
FROM orders
WHERE customer_id = 12345
ORDER BY order_ts DESC
LIMIT 20;
```

Probablemente verás:

* `Seq Scan`
* Muchas filas leídas
* Tiempo elevado

> 📌 **Pregunta clave**
> ¿Por qué leer toda la tabla si solo quiero 20 filas?

### Crear el índice

```sql
CREATE INDEX idx_orders_customer_ts_desc
ON orders(customer_id, order_ts DESC);
```

Repite la consulta.

Ahora verás:

* `Index Scan`
* Muy pocas filas leídas
* Mucho menos tiempo

> 📌 **Idea clave**
> Un índice no acelera la consulta,
> acelera **el acceso a los datos correctos**.

## Ordenación: memoria vs disco

### Poca memoria

```sql
SET work_mem = '1MB';

EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, total_amount
FROM orders
ORDER BY total_amount DESC
LIMIT 20000;
```

Probablemente aparecerá:

* `Sort Method: external merge`
* Uso de disco
* Mayor tiempo

> 📌 **Qué significa**
> La ordenación no cabía en memoria → PostgreSQL usó disco.

### Más memoria

```sql
SET work_mem = '64MB';
```

Repite la consulta.

Ahora:

* `Sort Method: quicksort`
* Todo en memoria
* Mucho más rápido

> 📌 **Idea clave**
> La misma consulta puede ejecutarse de forma muy distinta
> dependiendo de los recursos disponibles.

## JOINs y estrategias de ejecución

Consulta con varias tablas:

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT c.city, sum(oi.qty * oi.unit_price)
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status IN ('PAID','SHIPPED')
GROUP BY c.city;
```

Observa:

* Tipo de JOIN (`Hash Join`, `Nested Loop`, etc.)
* Orden de ejecución de las tablas
* Coste total

> 📌 **Idea clave**
> El optimizador decide el orden y la estrategia de los JOINs.

## Monitorización: qué está pasando en el sistema

### Sesiones activas

```sql
SELECT pid, state, now() - query_start, query
FROM pg_stat_activity
WHERE datname = 'demos';
```

Permite ver:

* Qué consultas se están ejecutando
* Cuánto tiempo llevan activas

### Consultas más costosas

```sql
SELECT calls, total_exec_time, mean_exec_time, query
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;
```

> 📌 **Idea clave**
> El mayor problema suele ser una consulta “normal”
> ejecutada miles de veces.

## Conclusión del Tema 9

Este tema nos enseña que:

* El rendimiento depende de **cómo se ejecuta**, no solo de qué se consulta.
* `EXPLAIN ANALYZE` es una herramienta fundamental.
* Los índices, la memoria y las estadísticas cambian radicalmente los planes.
* Optimizar es **entender**, no adivinar.
