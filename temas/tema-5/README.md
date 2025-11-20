# Tema 5 — Bases de Datos Distribuidas

## 🧠 Resumen general

Las bases de datos distribuidas almacenan y gestionan datos desde **varios nodos interconectados**, manteniendo transparencia para el usuario final. Estos sistemas aportan autonomía, disponibilidad y escalabilidad, pero también introducen complejidad en su gestión.

## 1. Sistemas distribuidos

Un sistema distribuido está formado por varios ordenadores (nodos) que **no comparten memoria ni disco**, pero cooperan a través de redes.

### Características principales

- Nodos sin memoria compartida.  
- Dispersión geográfica posible.  
- Administración independiente en cada sitio.  
- Transacciones **locales** y **globales**.

## 2. Ventajas e inconvenientes

### ✔️ Ventajas

- **Datos compartidos** de forma transparente.  
- **Autonomía local** de cada nodo.  
- **Alta disponibilidad** gracias a la replicación.

### ⚠️ Inconvenientes

- Mayor complejidad de desarrollo y mantenimiento.  
- Mayor probabilidad de errores por coordinación entre nodos.  
- Sobrecarga de comunicación entre sitios.

## 3. Tipos de bases de datos distribuidas

### ✔️ Homogéneas

- Mismo SGBD en todos los nodos.  
- Cooperan entre sí.

### ✔️ Heterogéneas

- Diferentes SGBD, incluso esquemas distintos.  
- Un nodo puede desconocer la existencia de otros.

## 4. Almacenamiento distribuido

Dos enfoques principales:

### ✔️ Réplica

Copia completa de las tablas en varios nodos.

- **Ventajas:** más disponibilidad, mejor rendimiento de lectura.  
- **Desventaja:** mayor coste en actualizaciones.

### ✔️ Fragmentación

Divide la tabla:

- **Horizontal**: por filas (reconstrucción con `UNION`).  
- **Vertical**: por columnas (reconstrucción con `JOIN`).

### ✔️ Transparencia

Los sistemas distribuidos deben ofrecer:

- Transparencia de **fragmentación**  
- Transparencia de **réplica**  
- Transparencia de **ubicación**

## 5. Disponibilidad y robustez

La replicación mejora la disponibilidad, pero implica más complejidad.

Un sistema robusto debe:

1. Detectar fallos.  
2. Reconfigurar el sistema.  
3. Recuperarse y sincronizar réplicas.

## 6. Procesamiento distribuido de consultas

Factores clave:

- **Coste de transmisión por red**.  
- **Beneficio del paralelismo entre nodos**.

Procesar una consulta puede implicar:

- Elegir la réplica más económica.  
- Reconstruir tablas fragmentadas con operaciones distribuidas.

## 7. Proveedores y tecnologías relevantes

### ✔️ Oracle Distributed Database

Conceptos clave:

- **Database links** para conectar nodos.  
- **SQL remoto**: operaciones en un único nodo.  
- **SQL distribuido**: operaciones en varios nodos.  
- **Commit en dos fases (2PC)**: atomicidad en transacciones distribuidas.

### ✔️ SQL Server — Replicación

Modelos:

- **Snapshot replication**  
- **Transactional replication**  
- **Merge replication**

Componentes:

- Publicador  
- Distribuidor  
- Suscriptor  
- Artículos y publicaciones

## 🧩 Conclusión

Las bases de datos distribuidas permiten:

- Escalabilidad horizontal.  
- Alta disponibilidad mediante replicación.  
- Procesamiento de consultas en varios nodos.  

Pero requieren:

- Compleja coordinación.  
- Gestión robusta de fallos.  
- Diseños cuidadosos de almacenamiento y transacciones.
