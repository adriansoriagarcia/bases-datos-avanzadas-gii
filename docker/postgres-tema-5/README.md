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

## 🔧 Funcionamiento general del entorno

La idea didáctica de este entorno es la siguiente:

* `db_centro` y `db_norte` → **fragmentación horizontal** de una tabla `estaciones`.
* `db_coord` → coordina y ve todo como una sola BD mediante `postgres_fdw`.
* `pgadmin` → interfaz web para gestionar y ejecutar las consultas.

### Scripts de inicialización

#### `init/centro/01_estaciones_centro.sql`

Tabla `estaciones` con datos de la zona centro:

```sql
CREATE TABLE IF NOT EXISTS estaciones (
    id         SERIAL PRIMARY KEY,
    comunidad  TEXT NOT NULL,
    municipio  TEXT NOT NULL,
    combustible TEXT NOT NULL,
    precio     NUMERIC(5,2) NOT NULL
);

INSERT INTO estaciones (comunidad, municipio, combustible, precio) VALUES
('Comunidad de Madrid', 'Madrid', 'Gasolina 95 E5', 1.58),
('Comunidad de Madrid', 'Alcalá de Henares', 'Gasolina 95 E5', 1.55),
('Comunidad de Madrid', 'Getafe', 'Gasóleo A', 1.49),
('Castilla-La Mancha', 'Toledo', 'Gasolina 95 E5', 1.53),
('Castilla-La Mancha', 'Albacete', 'Gasóleo A', 1.47),
('Castilla y León', 'Valladolid', 'Gasolina 95 E5', 1.56),
('Castilla y León', 'Segovia', 'Gasóleo A', 1.48);
```

#### `init/norte/01_estaciones_norte.sql`

Misma tabla pero con datos del norte:

```sql
CREATE TABLE IF NOT EXISTS estaciones (
    id         SERIAL PRIMARY KEY,
    comunidad  TEXT NOT NULL,
    municipio  TEXT NOT NULL,
    combustible TEXT NOT NULL,
    precio     NUMERIC(5,2) NOT NULL
);

INSERT INTO estaciones (comunidad, municipio, combustible, precio) VALUES
('Cantabria', 'Santander', 'Gasolina 95 E5', 1.60),
('Cantabria', 'Torrelavega', 'Gasóleo A', 1.50),
('Asturias', 'Oviedo', 'Gasolina 95 E5', 1.59),
('Asturias', 'Gijón', 'Gasóleo A', 1.52),
('País Vasco', 'Bilbao', 'Gasolina 95 E5', 1.62),
('País Vasco', 'San Sebastián', 'Gasóleo A', 1.54);
```

#### `init/coord/01_coord_init.sql`

En el coordinador solo preparamos la extensión FDW (el enlace a los otros nodos lo harás tú como parte de la demo):

```sql
CREATE EXTENSION IF NOT EXISTS postgres_fdw;
```

> Lo demás (CREATE SERVER, FOREIGN TABLE, VIEW…) lo harás desde pgAdmin.

### Arrancar el entorno

Iniciar los contenedores desde VSCode o con el siguiente comando:

```bash
docker compose up -d
```

Cuando todo esté “healthy”, abrir pgAdmin:

* pgAdmin: **[http://localhost:8081](http://localhost:8081)**

  * Usuario: `admin@example.com`
  * Contraseña: `admin`

---

### Configurar conexiones en pgAdmin

En pgAdmin crea tres servidores:

#### Servidor `db_centro`

* **Name:** `db_centro`
* **Connection → Host:** `db_centro`
* **Port:** `5432`
* **Maintenance DB:** `demos`
* **Username:** `profesor`
* **Password:** `postgres` (marca “Save Password”)

#### Servidor `db_norte`

* **Name:** `db_norte`
* **Host:** `db_norte`
* Resto igual que arriba.

#### Servidor `db_coord`

* **Name:** `db_coord`
* **Host:** `db_coord`
* **Maintenance DB:** `demos`
* Usuario/clave igual.

#### Configurar la base de datos distribuida en `db_coord`

Abre la Query Tool sobre la BD `demos` en `db_coord` y ejecuta el siguiente comando para asegurar la extensión FDW:

```sql
CREATE EXTENSION IF NOT EXISTS postgres_fdw;
```

#### Crear servidores remotos

```sql
CREATE SERVER srv_centro
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host 'db_centro', dbname 'demos', port '5432');

CREATE SERVER srv_norte
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host 'db_norte', dbname 'demos', port '5432');
```

#### Crear mappings de usuario

```sql
CREATE USER MAPPING FOR profesor
  SERVER srv_centro
  OPTIONS (user 'profesor', password 'postgres');

CREATE USER MAPPING FOR profesor
  SERVER srv_norte
  OPTIONS (user 'profesor', password 'postgres');
```

#### Crear tablas externas

Creamos dos tablas externas que apuntan a la tabla `estaciones` de cada nodo:

```sql
CREATE FOREIGN TABLE estaciones_centro (
    id         INTEGER,
    comunidad  TEXT,
    municipio  TEXT,
    combustible TEXT,
    precio     NUMERIC(5,2)
)
SERVER srv_centro
OPTIONS (schema_name 'public', table_name 'estaciones');

CREATE FOREIGN TABLE estaciones_norte (
    id         INTEGER,
    comunidad  TEXT,
    municipio  TEXT,
    combustible TEXT,
    precio     NUMERIC(5,2)
)
SERVER srv_norte
OPTIONS (schema_name 'public', table_name 'estaciones');
```

#### Crear vista unificada

```sql
CREATE VIEW estaciones_todas AS
SELECT * FROM estaciones_centro
UNION ALL
SELECT * FROM estaciones_norte;
```

### Consultas de ejemplo

Ahora, desde `db_coord`, ejecutas las siguientes consultas:

Ver todos los datos (transparencia de fragmentación + ubicación):

```sql
SELECT * FROM estaciones_todas
ORDER BY comunidad, municipio;
```

Estación más barata de Gasolina 95 E5:

```sql
SELECT comunidad, municipio, precio
FROM estaciones_todas
WHERE combustible = 'Gasolina 95 E5'
ORDER BY precio
LIMIT 3;
```

Precio medio por comunidad:

```sql
SELECT comunidad, combustible, AVG(precio) AS precio_medio
FROM estaciones_todas
GROUP BY comunidad, combustible
ORDER BY combustible, precio_medio;
```

👉 Didácticamente: estás ejecutando **una sola consulta** contra `db_coord`, pero en realidad está leyendo datos de **dos nodos físicos distintos** (`db_centro`, `db_norte`) usando FDW → **base de datos distribuida homogénea** con transparencia.
