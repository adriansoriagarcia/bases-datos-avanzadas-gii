# Entorno Docker — Tema 6: Indexación y Asociación

El fichero `docker-compose.yml` del Tema 6 define un entorno preparado para estudiar el funcionamiento de los **índices en bases de datos** utilizando PostgreSQL y pgAdmin. El objetivo es disponer de un entorno controlado donde se puedan ejecutar consultas sobre grandes volúmenes de datos y observar el impacto de diferentes tipos de índices.

El sistema está compuesto por:

* Un contenedor PostgreSQL con una base de datos llamada `demos`.
* Un conjunto de scripts SQL que crean tablas y generan miles de registros ficticios.
* Un contenedor pgAdmin para ejecutar consultas, analizar planes de ejecución y aplicar índices de forma interactiva.

Este entorno permite comparar de forma clara el rendimiento de consultas **con y sin índices**, así como experimentar con tipos específicos de indexación (compuestos, funcionales, parciales, trigramas…).

## 🐘 1. Servicio `demos-db` (PostgreSQL)

El contenedor principal ejecuta PostgreSQL 16 con:

* Usuario: `profesor`
* Contraseña: `postgres`
* Base de datos inicial: `demos`

Este nodo se inicializa mediante varios scripts SQL incluidos en la carpeta `init/`, que crean el esquema y cargan datos masivos para realizar las pruebas de indexación.

### 📌 Funcionalidades incluidas

1. **Creación del esquema básico**
   Se generan dos tablas:

   * `clientes`: contiene alrededor de 1.000 registros con información básica de clientes.
   * `llamadas`: contiene entre 50.000 y 100.000 registros simulando llamadas telefónicas asociadas a clientes.

2. **Carga de datos generada automáticamente**
   Se utiliza `generate_series` y funciones aleatorias para crear:

   * Fechas de llamadas en distintos rangos.
   * Diferentes países.
   * Duración, costo y estado de cada llamada.

   Esto crea un entorno lo suficientemente grande para que el planificador de PostgreSQL utilice estrategias de acceso relevantes (Sec Scan, Bitmap Scan, Index Scan…).

3. **Inclusión de extensiones**
   El script activa la extensión `pg_trgm`, necesaria para demostrar:

   * Búsqueda por similitud
   * Aceleración de consultas con `LIKE '%texto%'` mediante índices GIN

4. **Sin índices secundarios por defecto**
   Los índices adicionales se aplican manualmente en la fase de demostración para permitir comparar el desempeño antes y después.

### 📌 Persistencia

El volumen `demos-data` guarda la información generada para que los datos no se pierdan entre reinicios.

## 🖥️ 2. Servicio `pgadmin`

Este servicio proporciona la herramienta administrativa pgAdmin, accesible en:

👉 [http://localhost:8080](http://localhost:8080)

Configuración:

* Usuario: `admin@example.com`
* Contraseña: `admin`

pgAdmin permite:

* Conectarse al servidor PostgreSQL.
* Ejecutar consultas SQL.
* Analizar planes de ejecución (`EXPLAIN` y `EXPLAIN ANALYZE`).
* Observar las diferencias de rendimiento tras crear índices.
* Crear índices gráficos o mediante scripts SQL.

El volumen `pgadmin-data` mantiene configuraciones y conexiones guardadas.

## 🔧 Funcionamiento general del entorno

Tras levantar el entorno con VSCode o con el siguiente comando:

```bash
docker compose up -d
```

PostgreSQL ejecuta secuencialmente los scripts del directorio `init/`:

1. **01_extensions.sql**
   Activa extensiones necesarias para técnicas avanzadas de indexación.

2. **02_schema.sql**
   Crea las tablas `clientes` y `llamadas` sin índices secundarios.

3. **03_seed.sql**
   Genera decenas de miles de registros ficticios para que las consultas tengan un volumen apreciable.

Una vez ejecutadas, se procede a cargar los índices desde el script independiente `04_indexes.sql`, que incluye:

* Índices simples
* Índices compuestos
* Índices parciales
* Índices funcionales
* Índices GIN basados en trigramas

Esto permite evaluar la evolución de las consultas:

* Cambios en tiempos de ejecución
* Selección de planes (`Seq Scan` → `Index Scan` / `Bitmap Index Scan`)
* Uso de índices adecuados según selectividad y patrón de búsqueda

## 🎯 Propósito del entorno

El objetivo de este Docker es proporcionar un contexto controlado que permita:

* Demostrar cómo se construyen y utilizan diversos tipos de índices en PostgreSQL.
* Comparar el costo de consultas con y sin indexación.
* Analizar cómo el planificador selecciona diferentes métodos de acceso.
* Mostrar la importancia de estadísticas (`ANALYZE`) e información sobre selectividad.
* Explorar técnicas avanzadas como índices parciales y trigramas.

El entorno ofrece reproducibilidad total: con `docker compose up -d`, se crea una base de datos completa con datos realistas y listas para experimentar con técnicas de indexación abordadas en el Tema 6.
