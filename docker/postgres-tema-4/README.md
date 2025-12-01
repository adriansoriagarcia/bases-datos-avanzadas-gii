# Entorno Docker — Tema 4: Bases de Datos Paralelas

## 🎯 **Objetivo pedagógico**

Este Docker sirve para ilustrar de manera práctica:

* Cómo PostgreSQL implementa **paralelismo intra-consulta**.
* Qué decisiones toma el planificador.
* Cómo se distribuye el trabajo entre *workers*.
* Qué impacto tiene sobre el tiempo de ejecución en grandes volúmenes de datos.

## 📘 Descripción del entorno

El fichero `docker-compose.yml` del Tema 4 define un entorno completo para demostrar el **procesamiento paralelo de consultas en PostgreSQL**, tal como se explica en la teoría del tema.

Este entorno incluye:

* Un contenedor **PostgreSQL** configurado con una base de datos llamada `demos`.
* Un contenedor **pgAdmin**, herramienta web para administrar PostgreSQL.
* Un script de inicialización que genera automáticamente una tabla grande con millones de registros para poder observar el paralelismo real.

A continuación, se describe cada servicio:

## 🐘 **1. Servicio `demos-db` (PostgreSQL)**

Es el núcleo de la demo. Este contenedor ejecuta PostgreSQL configurado con:

* **Usuario:** `profesor`
* **Contraseña:** `postgres`
* **Base de datos:** `demos`

En este nodo se ejecutan las consultas paralelas que sirven para ilustrar:

* *Parallel Seq Scan*
* *Parallel Hash Join*
* *Parallel Aggregate*
* El uso de operadores `Gather` y `Gather Merge`

### 📌 ¿Qué incluye este contenedor?

1. **Asignación de puertos**
   Expone PostgreSQL en `5432` para que pgAdmin y el host puedan conectarse.

2. **Volúmenes**

   * `demos-data`: persiste los datos.
   * `./init:/docker-entrypoint-initdb.d`: ejecuta automáticamente scripts SQL de inicialización.

3. **Scripts de inicialización**
   Dentro de la carpeta `init/` se incluyen archivos como:

   * `01_parallel_demo.sql` → Crea una tabla `ventas` con **5 millones de registros**, necesaria para que el planificador active el paralelismo.
   * `ANALYZE` → Asegura estadísticas actualizadas.

### 📌 Resultado

Al arrancar el contenedor, la tabla estará lista para ejecutar consultas con y sin paralelismo y comparar tiempos con `EXPLAIN ANALYZE`.

## 🖥️ **2. Servicio `pgadmin`**

Este contenedor proporciona un entorno gráfico accesible desde el navegador:

👉 [http://localhost:8080](http://localhost:8080)

Configuración predeterminada:

* **Email:** `admin@example.com`
* **Contraseña:** `admin`

pgAdmin permite:

* Crear conexiones al servidor PostgreSQL.
* Ejecutar consultas y visualizar planes de ejecución.
* Cambiar parámetros como `max_parallel_workers_per_gather`.

Esto permite experimentar con:

* **Ejecución secuencial vs paralela**
* Diferencia entre operadores `Seq Scan` y `Parallel Seq Scan`
* Cómo afecta el paralelismo al tiempo de ejecución y al plan generado

## 🔧 **3. Variables relevantes del entorno**

El entorno funciona gracias a:

* `max_parallel_workers_per_gather`
* `max_parallel_workers`
* `parallel_setup_cost`

Estas configuraciones pueden modificarse desde:

```sql
SET max_parallel_workers_per_gather = 0;  -- sin paralelismo
SET max_parallel_workers_per_gather = 4;  -- con paralelismo
```

Cambiando estas configuraciones, se puede ver cómo el optimizador decide paralelizar o no, y cómo cambia el plan de ejecución.

## 🔄 **4. ¿Cómo se usa este entorno?**

1. Iniciar servicios desde VSCode con el complemento [_Container Tools_](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-containers) o con el siguiente comando:

   ```bash
   docker compose up -d
   ```

2. Abrir pgAdmin:
   [http://localhost:8080](http://localhost:8080)

3. Conectarse al servidor `demos-db`.

4. Ejecutar las consultas de demostración:

   * Sin paralelismo
   * Con paralelismo
     y comparar los planes resultantes.

5. Modificar parámetros y observar:

   * Grado de paralelismo.
   * Cambios en `Gather/Gather Merge`.
   * Costes estimados y reales.
   * Número de workers lanzados.
