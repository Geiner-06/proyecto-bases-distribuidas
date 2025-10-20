-- ============================================================
-- CONFIGURACIÓN DE CONEXIÓN FDW POSTGRESQL → SQL SERVER
-- ============================================================

-- Paso 0: Crear extensión FDW (si no existe)
CREATE EXTENSION IF NOT EXISTS tds_fdw;

-- Crear esquema para las tablas foráneas (si no existe)
CREATE SCHEMA IF NOT EXISTS integracion;

-- Cambiar al esquema de trabajo principal
SET search_path TO core_medico;

-- ============================================================
-- PASO 1: CREAR EL SERVIDOR FORÁNEO
-- ============================================================

CREATE SERVER servidor_mssql_externo
FOREIGN DATA WRAPPER tds_fdw
OPTIONS (
    servername 'db_sqlserver',           -- Nombre del contenedor o hostname
    port '1433',                        -- Puerto SQL Server
    database 'integracion_externa_db',   -- Nombre de la base de datos remota
    tds_version '7.4'                    -- Protocolo TDS compatible con SQL Server 2019+
);

-- ============================================================
-- PASO 2: CREAR EL MAPEO DE USUARIO
-- ============================================================

CREATE USER MAPPING FOR usr_fdw_pg_mssql
SERVER servidor_mssql_externo
OPTIONS (
    username 'usr_fdw_pg_mssql',             -- Usuario remoto en SQL Server
    password 'Postgres_123'     -- Contraseña definida en SQL Server
);

CREATE USER MAPPING FOR admin_pg
SERVER servidor_mssql_externo
OPTIONS (
    username 'usr_fdw_pg_mssql',  -- El usuario remoto en SQL Server
    password 'Postgres_123'      -- La contraseña definida en SQL Server
);
-- ============================================================
-- PASO 3: CREAR LAS TABLAS FORÁNEAS
-- ============================================================

-- Tabla: PacienteIntegracion
CREATE FOREIGN TABLE integracion.paciente_integracion_fdw (
    id_paciente_pg INTEGER,
    id_aseguradora VARCHAR(50),
    codigo_paciente_externo VARCHAR(100),
    poliza_vigente BOOLEAN
)
SERVER servidor_mssql_externo
OPTIONS (
    schema_name 'dbo',
    table_name 'PacienteIntegracion'
);

-- Tabla: ConveniosAseguradoras
CREATE FOREIGN TABLE integracion.convenios_aseguradoras_fdw (
    id_convenio INTEGER,
    id_aseguradora VARCHAR(50),
    codigo_estudio_pg VARCHAR(20),
    cobertura_porcentaje INTEGER
)
SERVER servidor_mssql_externo
OPTIONS (
    schema_name 'dbo',
    table_name 'ConveniosAseguradoras'
);

-- Tabla: FacturacionExterna
CREATE FOREIGN TABLE integracion.facturacion_externa_fdw (
    id_factura_externa INTEGER,
    id_estudio_ordenado_pg INTEGER,
    monto NUMERIC(12, 2),
    estado_facturacion VARCHAR(50),
    fecha_actualizacion_estado TIMESTAMP
)
SERVER servidor_mssql_externo
OPTIONS (
    schema_name 'dbo',
    table_name 'FacturacionExterna'
);

-- Tabla: Vista de resumen de facturacion
CREATE FOREIGN TABLE integracion.v_resumen_facturacion_fdw (
    aseguradora VARCHAR(50),
    total_facturas INT,
    monto_total DECIMAL(18,2),
    promedio DECIMAL(18,2)
)
SERVER servidor_mssql_externo
OPTIONS (
    schema_name 'dbo',
    table_name 'v_resumen_facturacion'
);

-- ============================================================
-- PASO 4: PERMISOS DE USO Y LECTURA
-- ============================================================

GRANT USAGE ON FOREIGN SERVER servidor_mssql_externo TO usr_fdw_pg_mssql;
-- Otorgar permiso de uso del esquema
GRANT USAGE ON SCHEMA integracion TO usr_fdw_pg_mssql;

-- Otorgar permiso de lectura sobre todas las tablas dentro del esquema
GRANT SELECT ON ALL TABLES IN SCHEMA integracion TO usr_fdw_pg_mssql;

-- Dar permisos automáticos para futuras tablas
ALTER DEFAULT PRIVILEGES IN SCHEMA integracion
GRANT SELECT ON TABLES TO usr_fdw_pg_mssql;


