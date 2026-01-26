# Casos de Negocio

## Caso 1: Automoción (ventas por región y periodo)

**Contexto**
Un concesionario (o grupo) consolida ventas de vehículos y servicios posventa desde varios sistemas (CRM, ERP, DMS).

**Reto de negocio**
Responder rápido a preguntas del tipo: “Coches vendidos en Andalucía en septiembre”, “comparar ingresos con abril”, “repetir comparación por modelo y canal”.

**Cómo se resuelve con OLAP**

* **Dimensiones:** Tiempo (día/mes/trimestre), Región (CCAA/provincia), Producto (marca/modelo/acabado), Canal (online/showroom/flotas), Cliente (particular/empresa).
* **Medidas:** Unidades, Ingresos, Margen, Descuento medio, Tiempo de entrega.
* **Operaciones OLAP:**

  * *Slice/Dice* (Andalucía + septiembre),
  * *Drill-down* (CCAA → provincia → ciudad),
  * *Pivot* (comparar por modelo vs por canal),
  * *YoY/MoM* (comparativas entre periodos).
* **Resultado:** análisis interactivo en segundos, sin cargar el sistema transaccional.

**Herramientas posibles**

* DW: **BigQuery / Snowflake / Synapse / Redshift**
* OLAP/semántica: **SSAS Tabular / Power BI semantic model / Azure Analysis Services**
* BI: **Power BI / Tableau / Looker**
* ELT/ETL: **dbt / Data Factory / SSIS / Airflow**

## Caso 2: Retail / eCommerce (márgenes y rotación por categoría)

**Contexto**
Una cadena minorista vende en tienda y online. Maneja surtido amplio, promociones y estacionalidad.

**Reto de negocio**
Detectar qué categorías y productos “explican” el margen:

* “¿Qué promociones aumentaron ventas pero erosionaron margen?”
* “¿Qué tiendas tienen rotación lenta y riesgo de sobrestock?”
* “¿Cómo se comporta la cesta por región y tipo de cliente?”

**Cómo se resuelve con OLAP**

* **Dimensiones:** Tiempo, Tienda/Canal, Producto (categoría/marca/SKU), Cliente (segmento), Promoción, Proveedor.
* **Medidas:** Ventas netas, Margen bruto, Unidades, Ticket promedio, Rotación inventario, Stock medio.
* **Operaciones OLAP:**

  * *Drill-down* de categoría → subcategoría → SKU para localizar “fugas de margen”.
  * *Dice* por promoción + segmento para evaluar efectividad real.
  * *Ranking/Top N* (peores márgenes, rotación más lenta).
* **Resultado:** decisiones rápidas sobre pricing, promociones y reposición basadas en agregados consistentes.

**Herramientas posibles**

* DW: **Snowflake / BigQuery** (alto volumen + histórico)
* OLAP: **Power BI semantic model** (tabular con medidas DAX) o **SSAS Tabular**
* BI: **Power BI / Qlik Sense**
* ETL/ELT: **dbt + Airflow** o **Talend**

## Caso 3: Telecom / Contact Center (calidad de servicio y productividad)

**Contexto**
Un centro de atención al cliente gestiona llamadas/chats/tickets. Hay SLAs, múltiples colas y campañas.

**Reto de negocio**
Explicar variaciones de calidad:

* “¿Por qué sube el tiempo medio de espera en ciertas horas?”
* “¿Qué colas o motivos generan recontactos?”
* “¿Qué campañas aumentan volumen sin mejorar resolución?”

**Cómo se resuelve con OLAP**

* **Dimensiones:** Tiempo (hora/día), Canal (voz/chat/email), Cola/Equipo, Agente, Motivo/Tipificación, Campaña, Cliente (segmento).
* **Medidas:** AHT (tiempo medio de atención), ASA (espera), FCR (resolución primer contacto), Recontacto, SLA cumplido, CSAT/NPS.
* **Operaciones OLAP:**

  * *Slice* por franja horaria + canal para detectar picos.
  * *Drill-down* cola → equipo → agente para encontrar cuellos de botella.
  * *Pivot* motivo vs canal para rediseñar flujos o bots.
* **Resultado:** diagnóstico operativo basado en series históricas y segmentación multidimensional.

**Herramientas posibles**

* DW: **Synapse / BigQuery / Redshift**
* OLAP: **Tabular (SSAS/Power BI)** con métricas y jerarquías de tiempo
* BI: **Power BI / Tableau**
* ETL/Streaming (si aplica): **Data Factory / Glue / Airflow** (o pipelines propios)

## Caso 4: Banca / Fintech (riesgo y rentabilidad por cartera)

**Contexto**
Una entidad analiza crédito y rentabilidad de productos (préstamos, tarjetas), con comportamiento por cohortes.

**Reto de negocio**
Combinar rendimiento y riesgo:

* “¿Qué segmentos aportan margen ajustado al riesgo?”
* “¿Cómo evoluciona la morosidad por cohorte y canal?”
* “¿Qué sucursales o campañas traen más incumplimientos?”

**Cómo se resuelve con OLAP**

* **Dimensiones:** Tiempo, Producto, Segmento cliente, Canal origen, Sucursal/Región, Cohorte (mes de alta), Score/rating, Estado del préstamo.
* **Medidas:** EAD, PD/LGD (si modeladas), Impagos, Pérdida esperada, Ingresos por intereses, Coste de riesgo, Margen ajustado.
* **Operaciones OLAP:**

  * *Cohort analysis* (cohorte por mes de originación y evolución mensual).
  * *Drill-down* región → sucursal → gestor.
  * *Slice* por rating + canal para políticas de originación.
* **Resultado:** reporting regulatorio y de negocio consistente, con trazabilidad por dimensiones.

**Herramientas posibles**

* DW: **Snowflake / Synapse** (gobernanza + escalabilidad)
* OLAP/semántica: **SSAS Tabular** o **Power BI semantic model**
* BI: **Power BI** (control de acceso por roles)
* ETL/ELT: **Informatica / dbt / Data Factory**

## Caso 5: Logística / Cadena de suministro (OTIF, costes y cuellos de botella)

**Contexto**
Empresa distribuidora con almacenes, rutas y múltiples transportistas. Existen tiempos y costes variables.

**Reto de negocio**
Mejorar servicio y reducir costes:

* “¿Dónde fallamos OTIF (on time in full) y por qué?”
* “¿Qué rutas o transportistas disparan coste por entrega?”
* “¿Qué SKU provocan más incidencias o devoluciones?”

**Cómo se resuelve con OLAP**

* **Dimensiones:** Tiempo, Almacén, Ruta, Transportista, Cliente, Producto/SKU, Incidencia (tipo/causa), Geografía.
* **Medidas:** OTIF, Tiempo de preparación, Lead time, Coste por entrega, Km recorridos, Tasa de devoluciones, Daños.
* **Operaciones OLAP:**

  * *Drill-down* almacén → zona → ruta para localizar cuellos.
  * *Dice* transportista + tipo incidencia para renegociación/gestión.
  * *Pivot* producto vs región para optimizar stock y reaprovisionamiento.
* **Resultado:** priorización basada en impacto (coste/servicio) y análisis histórico sin fricción.

**Herramientas posibles**

* DW: **BigQuery / Redshift / Snowflake**
* OLAP: **Power BI semantic model** (medidas y jerarquías) o **Apache Kylin** si hay stack big data
* BI: **Power BI / Looker**
* ETL/ELT: **dbt + Airflow / Glue / Data Factory**
