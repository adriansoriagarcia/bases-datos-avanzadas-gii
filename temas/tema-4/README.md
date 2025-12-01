# Tema 4 — Bases de Datos Paralelas

## 🧠 Resumen general

El tema 4 introduce los fundamentos de las **bases de datos paralelas**, sistemas capaces de utilizar múltiples procesadores, memorias o discos para acelerar la ejecución de consultas y aumentar la productividad en entornos con grandes volúmenes de datos.

## 🖥️ Contenedor Docker para este tema

La descripción del contenedor Docker para poner en práctica los conceptos de este tema se encuentra disponible en el directorio [docker/postgres-tema-4](../../docker/postgres-tema-4/README.md)

## 1. Sistemas paralelos

Los sistemas paralelos permiten ejecutar tareas simultáneamente usando múltiples CPUs o nodos.

### Tipos de máquinas

* **Grano grueso**: pocos procesadores muy potentes.
* **Grano fino**: muchos procesadores más simples.

### Métricas clave

* **Productividad**: tareas procesadas por unidad de tiempo.
* **Tiempo de respuesta**: duración de una única tarea.

## 2. Ganancia de velocidad y ampliabilidad

### ✔️ Ganancia de velocidad (speedup)

Se refiere al incremento en el rendimiento en comparación con la ejecución secuencial.

* **Lineal**: ideal pero infrecuente.
* **Sublineal**: lo habitual debido a sobrecostes de coordinación.

### ✔️ Escalabilidad (scalability)

Capacidad del sistema para mantener rendimiento al aumentar la carga.

* **Por lotes**: crece BD y tamaño de tareas.
* **De transacciones**: crece la llegada de operaciones.

## 3. Desventajas y retos del paralelismo

* **Coste de inicio**: arrancar varios procesos puede ser más lento que ejecutar secuencialmente.
* **Interferencias**: disputa por memoria o recursos compartidos.
* **Sesgo**: particiones de trabajo no siempre equilibradas.

## 4. Arquitecturas paralelas de bases de datos

1. **Memoria compartida**

   * Comunicación directa
     − Congestión del bus de memoria

2. **Disco compartido**

   * Mayor tolerancia a fallos
     − Accesos más lentos a disco

3. **Sin compartimiento (shared-nothing)**

   * Máxima escalabilidad
     − Mayor coste de comunicación entre nodos

4. **Jerárquica**
   Combinación de los modelos anteriores.

## 5. Paralelismo en consultas (intra-query)

Consiste en dividir una **misma consulta** en suboperaciones que se ejecutan en paralelo.

Tipos:

* **Paralelismo en operaciones** (ej.: selección, ordenación).
* **Paralelismo entre operaciones** (ej.: pipelines de operadores).

➡ Beneficio principal: **reduce el tiempo de respuesta**.

## 6. Paralelismo entre consultas (inter-query)

Varias consultas diferentes se ejecutan en paralelo.

* Aumenta la **productividad total**.
* No siempre reduce el tiempo de respuesta individual.
* Requiere gestionar **coherencia de cachés**.

## 7. Diseño de sistemas paralelos

Un sistema paralelo debe garantizar:

* **Alta disponibilidad**.
* Capacidad de **recuperación ante fallos**.
* Redistribución eficiente de datos y cargas.

## 8. Procesamiento paralelo en PostgreSQL

PostgreSQL incorpora paralelismo **intra-consulta** desde la versión 9.6 y ha ampliado sus capacidades en versiones posteriores (especialmente en 12+). El motor decide automáticamente cuándo paralelizar una consulta en función del coste estimado.

### ✔️ ¿Cuándo paraleliza PostgreSQL?

El planificador activa el paralelismo cuando detecta que:

* La tabla es suficientemente grande (alto coste de lectura).
* La operación es apta para paralelismo (seq scan, join, aggregate…).
* Los parámetros de configuración lo permiten.

### ✔️ Operaciones paralelizables

PostgreSQL puede paralelizar:

* **Parallel Seq Scan** (lectura paralela de tablas grandes)
* **Parallel Hash Join** y **Parallel Merge Join**
* **Parallel Aggregation** (agrupaciones y sumarios)
* **Parallel Bitmap Heap Scan**
* Fases intermedias como **Gather** y **Gather Merge**

### ✔️ Procesos implicados

Un plan paralelo incluye:

* **Workers paralelos**: procesos que hacen parte del trabajo (escaneo, filtros…).
* **Líder de consulta**: el proceso principal que coordina y combina resultados.
* Operadores:

  * `Gather` → recoge resultados de los workers.
  * `Gather Merge` → usa ORDER BY con merge paralelo.

### ✔️ Parámetros principales

* `max_parallel_workers_per_gather`
  Límite de workers para una sola consulta (por defecto suele ser 2).

* `max_parallel_workers`
  Total de workers que PostgreSQL puede lanzar en todo el servidor.

* `parallel_setup_cost` y `parallel_tuple_cost`
  Controlan cuándo el optimizador considera rentable paralelizar.

### ✔️ Ejemplo de configuración en clase

```sql
SET max_parallel_workers_per_gather = 0;  -- sin paralelismo
-- ejecutar consulta y ver Seq Scan

SET max_parallel_workers_per_gather = 4;  -- con paralelismo
-- ejecutar consulta y ver Parallel Seq Scan + Gather
```

### ✔️ Ventajas y limitaciones

**Ventajas:**

* Reduce tiempos de respuesta en consultas pesadas.
* Aprovecha varios núcleos sin cambiar la aplicación.

**Limitaciones:**

* No todas las operaciones son paralelizables.
* No existe paralelismo en DML por defecto (INSERT/UPDATE) como en Oracle.
* Ganancia sublineal por sobrecarga de coordinación.
