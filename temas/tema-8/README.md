# Tema 8 — Sistemas de recuperación

## Resumen general

El Tema 8 aborda los **sistemas de recuperación** en los sistemas gestores de bases de datos (SGBD), cuyo objetivo principal es garantizar la **atomicidad, consistencia y durabilidad** de las transacciones ante la aparición de fallos. La recuperación es un componente esencial para asegurar la fiabilidad de la base de datos en entornos reales.

## 🖥️ Contenedor Docker para este tema

La descripción del contenedor Docker para poner en práctica los conceptos de este tema se encuentra disponible en el directorio [docker/postgres-tema-8](../../docker/postgres-tema-8/README.md)

## 1. Introducción a los sistemas de recuperación

Los fallos son inevitables en cualquier sistema informático. En bases de datos, el sistema de recuperación permite que, incluso ante errores, la base de datos pueda volver a un **estado consistente**, preservando las propiedades ACID y minimizando el tiempo de indisponibilidad.

## 2. Clasificación de fallos

Los SGBD distinguen varios tipos de fallos, cada uno con implicaciones distintas:

- **Fallo de transacción**: errores lógicos o abortos durante la ejecución.
- **Caída del sistema**: pérdida de memoria volátil por fallos hardware o cortes eléctricos.
- **Fallo de disco**: daños en el almacenamiento persistente que requieren restauración desde copias de seguridad.

## 3. Tareas del sistema de recuperación

El sistema de recuperación realiza dos tipos de tareas:

1. **Tareas preventivas**, ejecutadas durante el funcionamiento normal (registro histórico).
2. **Acciones de recuperación**, ejecutadas tras un fallo para restaurar la consistencia.

## 4. Tipos de almacenamiento

Para comprender la recuperación se diferencian:

- **Almacenamiento volátil**: pierde datos tras un fallo.
- **Almacenamiento no volátil**: conserva datos tras el fallo.
- **Almacenamiento estable**: concepto teórico basado en redundancia para evitar pérdidas.

## 5. Atomicidad y recuperación

Ante un fallo, el sistema debe decidir si una transacción se **deshace (UNDO)** o se **rehace (REDO)**. Repetir o ignorar siempre una transacción no es válido, por lo que se requieren mecanismos formales de recuperación.

## 6. Recuperación basada en registro histórico

El método más extendido es el **log de transacciones**, donde cada modificación queda registrada antes de aplicarse. Esto permite:

- Deshacer transacciones incompletas.
- Rehacer transacciones confirmadas.

El registro histórico es clave para garantizar la durabilidad.

## 7. Modificación diferida e inmediata

- **Modificación diferida**: los cambios se aplican tras el commit.
- **Modificación inmediata**: los cambios se aplican durante la ejecución y pueden requerir UNDO.

Cada técnica presenta ventajas y costes distintos.

## 8. Recuperación y concurrencia

La recuperación debe coordinarse con el control de concurrencia, ya que varias transacciones pueden acceder simultáneamente a los mismos datos. Esto obliga a restringir accesos y a gestionar cuidadosamente los bloqueos.

## 9. Alta disponibilidad

Los SGBD modernos incorporan mecanismos de alta disponibilidad para reducir el impacto de fallos graves, como:

- Réplicas de bases de datos.
- Sistemas de backup y restore.
- Soluciones específicas de cada proveedor (Oracle, SQL Server, PostgreSQL).