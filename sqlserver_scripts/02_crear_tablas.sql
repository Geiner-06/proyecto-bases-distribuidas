-- ============================================================
-- CREACIÓN DE TABLAS DE INTEGRACIÓN
-- Estas tablas representan la parte que SQL Server aportará
-- al sistema distribuido de estudios médicos.
-- Fecha: 16/10/2025
-- ============================================================

USE integracion_externa_db;
GO

-- Limpieza: elimina tablas existentes si ya fueron creadas
IF OBJECT_ID('dbo.FacturacionExterna', 'U') IS NOT NULL DROP TABLE dbo.FacturacionExterna;
IF OBJECT_ID('dbo.ConveniosAseguradoras', 'U') IS NOT NULL DROP TABLE dbo.ConveniosAseguradoras;
IF OBJECT_ID('dbo.PacienteIntegracion', 'U') IS NOT NULL DROP TABLE dbo.PacienteIntegracion;
GO

-- ============================================================
-- (1) TABLA: PacienteIntegracion
-- Segmentación vertical: asocia el ID del paciente en PostgreSQL
-- con datos administrativos externos (por ejemplo, aseguradora)
-- ============================================================
CREATE TABLE dbo.PacienteIntegracion (
    id_paciente_pg INT PRIMARY KEY,
    id_aseguradora VARCHAR(50) NOT NULL,
    codigo_paciente_externo VARCHAR(100) NOT NULL,
    poliza_vigente BIT NOT NULL DEFAULT 1
);
GO

-- ============================================================
-- (2) TABLA: ConveniosAseguradoras
-- Catálogo de convenios entre aseguradoras y estudios médicos
-- ============================================================
CREATE TABLE dbo.ConveniosAseguradoras (
    id_convenio INT IDENTITY(1,1) PRIMARY KEY,
    id_aseguradora VARCHAR(50) NOT NULL,
    codigo_estudio_pg VARCHAR(20) NOT NULL,
    cobertura_porcentaje INT NOT NULL CHECK (cobertura_porcentaje BETWEEN 0 AND 100)
);
GO

-- ============================================================
-- (3) TABLA: FacturacionExterna
-- Registra el estado de facturación de los estudios realizados
-- ============================================================
CREATE TABLE dbo.FacturacionExterna (
    id_factura_externa INT IDENTITY(1,1) PRIMARY KEY,
    id_estudio_ordenado_pg INT NOT NULL,
    monto DECIMAL(12, 2) NOT NULL CHECK (monto >= 0),
    estado_facturacion VARCHAR(50) NOT NULL,
    fecha_actualizacion_estado DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================================
-- ASIGNACIÓN DE PERMISOS MÍNIMOS
-- Solo lectura para el usuario FDW desde PostgreSQL
-- ============================================================

GRANT SELECT ON dbo.PacienteIntegracion TO usr_fdw_pg_mssql;
GRANT SELECT ON dbo.ConveniosAseguradoras TO usr_fdw_pg_mssql;
GRANT SELECT ON dbo.FacturacionExterna TO usr_fdw_pg_mssql;
GO