# Tema 3: Bases de Datos para Documentos XML

## Enfoques de almacenamiento de XML

| 💡 Enfoque                           | ⚙️ Descripción                                                 | ✅ Ventajas                                             | ⚠️ Limitaciones                                       |
| ------------------------------------ | -------------------------------------------------------------- | ------------------------------------------------------ | ----------------------------------------------------- |
| **Archivos XML**                     | Guardar directamente en el sistema de archivos.                | Sencillo de implementar.                               | Sin control de integridad, seguridad ni concurrencia. |
| **Relacional XML**                   | Almacenar XML en tablas relacionales (CLOB o descomposición).  | Aprovecha las ventajas de los SGBD tradicionales.      | Complejo de mantener y de reconstruir.                |
| **SQL/XML**                          | Extensión del SQL con funciones para crear y consultar XML.    | Integra SQL y XML en una misma consulta.               | No está disponible en todos los SGBD.                 |
| **Bases de Datos Nativas XML (NXD)** | Almacenan documentos XML completos en estructuras optimizadas. | Alto rendimiento y soporte nativo para XPath y XQuery. | Curva de aprendizaje y configuración más complejas.   |

## Lenguajes y herramientas clave

* XPath → Navegar y localizar elementos XML.
* XQuery → Consultar y transformar datos XML.
* SQL/XML → Generar XML desde SQL (XMLELEMENT, XMLFOREST).
* Ejemplos de NXD: BaseX, eXist-db, Sedna.

## Ejemplos de consultas en Postgres

Para la demostración de consultas SQL, se recomienda utilizar el [contenedor Docker de Postgres](../../docker/postgres-tema-3/README.md) que se encuentra en la carpeta `docker`.

* [code/consultas_xml.sql](code/consultas_xml.sql) - Ejemplo de consultas SQL en una base de datos relacional.
