# Tema 9 — Ejecución y procesamiento de consultas

## Resumen de conceptos clave

Este tema explica **cómo un sistema de gestión de bases de datos (SGBD) ejecuta una consulta SQL internamente**, desde que el usuario la envía hasta que devuelve los resultados. El foco no está en el lenguaje SQL, sino en **el proceso de ejecución**, el **coste** y el **rendimiento**.

## Fases de ejecución de una consulta

Cuando se ejecuta una consulta SQL, el SGBD sigue estas fases:

1. **Análisis**

   * Validación sintáctica y semántica.
   * Comprobación de tablas, columnas y permisos.

2. **Optimización**

   * El optimizador genera varios planes posibles.
   * Cada plan tiene un **coste estimado**.
   * Se elige el plan con menor coste.

3. **Ejecución**

   * Se ejecuta el plan elegido.
   * Se accede a memoria y/o disco.
   * Se producen los resultados.

> 📌 *Idea clave*: el SGBD **no ejecuta directamente** la consulta, primero decide *cómo* hacerlo.

## Optimización basada en costes

Los SGBD modernos utilizan un **optimizador basado en costes**:

* El coste **no es tiempo real**, es una estimación.
* Se basa en:

  * Estadísticas de las tablas.
  * Número de filas.
  * Selectividad de los filtros.
  * Coste de E/S y CPU.

> 📌 *Idea clave*: el optimizador compara planes entre sí, no busca el plan perfecto, sino el **más barato según su modelo**.

## Planes de ejecución

Un **plan de ejecución** describe cómo se obtendrán los datos:

* Tipo de acceso a tablas:

  * **Seq Scan** (escaneo secuencial)
  * **Index Scan** / **Bitmap Scan**
* Operadores:

  * Filtros
  * Ordenaciones
  * Agregaciones
  * JOINs

Los planes se visualizan con:

```sql
EXPLAIN
EXPLAIN ANALYZE
```

> 📌 *Idea clave*: entender un plan es entender **el coste real de una consulta**.

## Coste estimado vs tiempo real

* **EXPLAIN** → muestra el plan estimado (no ejecuta).
* **EXPLAIN ANALYZE** → ejecuta la consulta y mide:

  * Tiempo real
  * Filas reales
  * Uso de memoria y disco

> 📌 *Idea clave*: El coste es una predicción, el tiempo real es la verdad.

## Operación de selección (WHERE)

La selección puede ejecutarse de dos formas principales:

* **Sin índice**:

  * Escaneo secuencial.
  * Se leen muchas filas para luego descartarlas.
* **Con índice**:

  * Se accede solo a las filas relevantes.
  * Mucho menor coste.

> 📌 *Idea clave*: los índices reducen el **trabajo innecesario**, no solo el tiempo.

## Ordenación (ORDER BY)

La ordenación depende de la memoria disponible:

* **Ordenación en memoria**:

  * Rápida.
  * Limitada por `work_mem`.
* **Ordenación externa (en disco)**:

  * Más lenta.
  * Se usa cuando no cabe en memoria.

> 📌 *Idea clave*: la misma consulta puede cambiar de plan según los recursos del sistema.

## JOINs y estrategias de ejecución

Para unir tablas, el SGBD puede usar distintas estrategias:

* **Nested Loop**
* **Hash Join**
* **Merge Join**

La elección depende de:

* Tamaño de las tablas.
* Índices disponibles.
* Filtros aplicados.

> 📌 *Idea clave*: el orden de los JOINs y la estrategia elegida influyen enormemente en el rendimiento.

## Estadísticas y su importancia

El optimizador se apoya en **estadísticas**:

* Número de filas.
* Distribución de valores.
* Selectividad de columnas.

Si las estadísticas están desactualizadas:

* El optimizador puede elegir **planes incorrectos**.

> 📌 *Idea clave*: mantener estadísticas actualizadas es esencial para un buen rendimiento.

## Monitorización de consultas

Los SGBD proporcionan herramientas para analizar el rendimiento real:

* Consultas activas.
* Consultas más costosas.
* Tiempo total y medio de ejecución.

Estas herramientas permiten:

* Detectar cuellos de botella.
* Priorizar optimizaciones.
* Tomar decisiones basadas en datos reales.

## Conclusión

El Tema 9 muestra que:

* El rendimiento no depende solo del SQL, sino de **cómo se ejecuta**.
* El optimizador toma decisiones basadas en estimaciones.
* Índices, memoria y estadísticas influyen directamente en los planes.
* Comprender los planes de ejecución es una **competencia clave en bases de datos avanzadas**.
