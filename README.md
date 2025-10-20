# Sistema de Gestión de Estudios Médicos Distribuido

Proyecto del curso **Bases de Datos II – TEC**  
Arquitectura de **tres motores de base de datos** integrados mediante **Docker Compose** para la gestión de estudios médicos (laboratorios clínicos, radiografías, ultrasonidos, etc.).  

El proyecto **no incluye la aplicación web o móvil**, sino la infraestructura de datos distribuida y la interoperabilidad entre sistemas.

---

## 🔹 Estructura de la solución

| Motor de Base de Datos | Contenedor | Propósito | Tipo de segmentación |
|-----------------------|-----------|-----------|--------------------|
| PostgreSQL | `db_postgres` | Núcleo transaccional. Manejo de pacientes, médicos, citas, resultados y diagnósticos. | Horizontal |
| SQL Server | `db_sqlserver` | Integración con sistemas externos (aseguradoras, ministerios, facturación). | Vertical |
| MongoDB | `db_mongo` | Almacenamiento analítico y generación de reportes. Documentos JSON de resultados de estudios. | No relacional |

---

## 🔹 Flujo de información

1. **PostgreSQL ↔ SQL Server**
   - PostgreSQL accede a datos de integración mediante **Foreign Data Wrapper (tds_fdw)**.
   - Permite consultas de estado de facturación, convenios y procedimientos almacenados de SQL Server.
   - Roles internos: `usr_fdw_pg_mssql` (solo lectura o ejecución controlada).

2. **PostgreSQL ↔ MongoDB**
   - PostgreSQL exporta resúmenes y resultados de estudios a MongoDB mediante **mongo_fdw**.
   - MongoDB sirve para reportes analíticos, agregaciones y consultas rápidas.
   - Roles internos: `usr_fdw_pg_mongo` (lectura/escritura limitada).

3. **Roles externos (para aplicaciones)**
   - `usr_api_web` → acceso a vistas completas para la web.
   - `usr_api_mobile` → acceso a vistas simplificadas para móviles.

4. **Ejemplo de flujo distribuido**
   - Se inserta un resultado de estudio en PostgreSQL.
   - PostgreSQL actualiza un documento resumen en MongoDB.
   - Una consulta web obtiene la información combinada de PostgreSQL y SQL Server.

---

## 🔹 Instalación y ejecución

1. Clonar el repositorio:

```bash
git clone https://github.com/Geiner-06/proyecto-bases-distribuidas.git
cd proyecto-bases-distribuidas
```
2. Levantar los contenedores

Ejecutar los contenedores con Docker Compose:

```bash
docker-compose up -d
```
3. Verificar que los servicios estén corriendo:
```bash
docker ps
```
4. Servicios esperados:
- postgres_server → puerto 5433
- sqlserver_server → puerto 1433
- mongo_server → puerto 27017

### 3. Configurar las Bases de Datos
Después de levantar los contenedores, sus bases de datos están vacías. Debes ejecutar los scripts de inicialización en el orden correcto.

En mi caso utilizé pgAdmin 4 para PostgreSQL, SSMS para SQLServer y Mongo Compass para mongo, para conectarme a cada servicio.

#### a. Configurar PostgreSQL (Núcleo Transaccional)
1.  Conéctate a PostgreSQL con los siguientes datos:
    *   **Host:** `localhost`
    *   **Puerto:** `5433`
    *   **Base de Datos:** `sistema_medico_db`
    *   **Usuario:** `admin_pg`
    *   **Contraseña:** `ComplexPass-2025`
2.  Ejecuta los siguientes scripts en orden:
    *   `01_crear_esquema_pg.sql`
    *   `02_segmentacion_pacientes_pg.sql`
    *   `03_roles_usuario_pg.sql`
    *   `04_datos_prueba_pg.sql`
    *   `05_conexion_sqlserver_pg.sql`
    *   `06_conexion_mongo_pg.sql`
    *   `07_pruebas_consultas_pg.sql`
    *   `08_vistas_usuarios_externos_pg.sql`

#### b. Configurar SQL Server (Integración Externa)
1.  Conéctate a SQL Server:
    *   **Host:** `localhost,1433`
    *   **Autenticación:** SQL Server Authentication
    *   **Usuario:** `sa`
    *   **Contraseña:** `ComplexPass2025!`
2.  Ejecuta los siguientes scripts en orden:
    *   `01_crear_base_datos.sql`
    *   `02_crear_tablas.sql`
    *   `03_datos_prueba.sql`
    *   `04_procedimiento_resumen.sql`

#### c. Configurar MongoDB (Capa Analítica)
1.  Conéctate a MongoDB:
    *   **Host:** `localhost`
    *   **Puerto:** `27017`
    *   **Autenticación:** Username/Password
    *   **Usuario:** `admin_mongo`
    *   **Contraseña:** `ComplexPass-2025`
2.  Ejecuta el script:
    *   `01_crear_base_datos_mongo.js` (Crea la base de datos `analitica_medica_db`, la colección `reportes_estudios` y el usuario `usr_fdw_pg_mongo`).

¡Felicidades! El sistema distribuido está completamente configurado y listo para ser probado.

---
