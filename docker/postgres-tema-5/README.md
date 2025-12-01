# Descripción del entorno Docker — Tema 5: Bases de Datos Distribuidas

El fichero `docker-compose.yml` del Tema 5 define un entorno pensado para demostrar el funcionamiento de una **base de datos distribuida homogénea**, construida con varios nodos PostgreSQL que cooperan mediante **postgres_fdw**. Este entorno permite ilustrar conceptos como:

* Fragmentación horizontal de datos
* Acceso transparente a datos remotos
* Consulta distribuida
* Gestión de múltiples nodos
* Coordinación entre servidores

El ecosistema se compone de tres instancias de PostgreSQL y una instancia de pgAdmin.

## 🐘 1. Servicio `db_centro` (nodo 1)

Este contenedor representa un nodo que almacena una parte de la información, típicamente datos de una región geográfica o partición lógica determinada.

Características:

* Ejecuta PostgreSQL 16.
* Base de datos inicial `demos`.
* Scripts de inicialización que crean la tabla `estaciones` con registros pertenecientes a zonas del centro (ej.: Madrid, Castilla-La Mancha, Castilla y León).
* El volumen `centro-data` persiste los datos del nodo.

Este nodo actúa como uno de los fragmentos de la base de datos distribuida: contiene sólo un subconjunto de filas.

## 🐘 2. Servicio `db_norte` (nodo 2)

Este contenedor funciona de forma equivalente al nodo anterior, pero con un conjunto de datos diferente.

Características:

* También ejecuta PostgreSQL 16.
* Scripts de inicialización específicos generan otra partición de la tabla `estaciones`, esta vez con datos de regiones del norte (ej.: Cantabria, Asturias, País Vasco).
* El volumen `norte-data` mantiene persistencia propia e independiente.

Junto con `db_centro`, este nodo conforma una **fragmentación horizontal** de la tabla `estaciones`: cada nodo contiene distintas filas, pero la estructura de tabla es la misma.

## 🐘 3. Servicio `db_coord` (coordinador)

Este contenedor funciona como **nodo coordinador** de la base de datos distribuida.

Características:

* Ejecuta PostgreSQL 16.
* Incluye un script de inicialización minimalista que activa la extensión `postgres_fdw`.
* Será el encargado de conectarse a `db_centro` y `db_norte`, importar sus tablas y construir vistas unificadas que integren los datos remotos.
* El volumen `coord-data` mantiene el estado y metadatos necesarios para las operaciones remotas.

Este nodo no almacena datos de la tabla `estaciones` por sí mismo, sino que accede a los datos distribuidos mediante _foreign tables_.

## 🖥️ 4. Servicio `pgadmin`

Este contenedor proporciona la interfaz administrativa y de consulta del entorno:

* Acceso web a través de `http://localhost:8081`.
* Permite gestionar cada uno de los nodos PostgreSQL agregando conexiones independientes.
* Resulta útil para supervisar el comportamiento de la base distribuida, ejecutar consultas remotas y configurar servidores FDW desde una interfaz visual.

Su volumen `pgadmin-data` mantiene la configuración persistente de conexiones, preferencias y servidores registrados.

# 🔧 Funcionamiento general del entorno

Cada nodo PostgreSQL se inicia con su propio conjunto de datos, de acuerdo con el script correspondiente. Todos los nodos comparten:

* Estructura de tabla idéntica (`estaciones`).
* Autenticación homogénea (`profesor/postgres`).
* La misma base de datos (`demos`).

El nodo coordinador (`db_coord`) se configura para:

1. Crear **servidores remotos** (`CREATE SERVER`) apuntando a `db_centro` y `db_norte`.
2. Definir **user mappings** para la autenticación remota.
3. Crear **foreign tables** que representan las tablas del nodo remoto.
4. Unificar los datos mediante vistas (ej.: `CREATE VIEW estaciones_todas AS ...`).

Esto permite ejecutar consultas como:

```sql
SELECT * FROM estaciones_todas;
```

y obtener datos provenientes de múltiples nodos sin que sea necesario conocer su ubicación física.

# 🎯 Propósito del entorno

Este entorno Docker está diseñado para mostrar de manera reproducible:

* Cómo se construye una arquitectura distribuida homogénea basada en PostgreSQL.
* Cómo dividir datos entre nodos físicos independientes (fragmentación horizontal).
* Cómo acceder de forma transparente a esos datos desde un nodo coordinador.
* Cómo funcionan las consultas distribuidas a través de foreign tables.
* Qué implicaciones tienen estas configuraciones en términos de rendimiento y organización de datos.

El entorno, además, es completamente aislado y reproducible: con un simple `docker compose up -d` se obtiene una infraestructura distribuida completa lista para ser usada.
