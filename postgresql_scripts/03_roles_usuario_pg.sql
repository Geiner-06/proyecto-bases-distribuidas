-- ============================================================
-- SISTEMA DE GESTIÓN DE ESTUDIOS MÉDICOS DISTRIBUIDO
-- Crear Roles de Usuario, Asignar Permisos y Conexión FDW
-- Autor: Geiner Barrantes
-- Fecha: 15/10/2025
-- ============================================================

SET search_path TO core_medico;

-- ============================================================
-- (1) CREACIÓN DE ROLES DE USUARIO
-- ============================================================

-- A. Perfiles internos del clúster (para comunicación entre BDs)
CREATE ROLE usr_fdw_pg_mssql WITH LOGIN PASSWORD 'mssql123';
CREATE ROLE usr_fdw_pg_mongo WITH LOGIN PASSWORD 'mongo123';

-- B. Perfiles externos (para las aplicaciones)
CREATE ROLE usr_api_web WITH LOGIN PASSWORD 'api_web_pass';
CREATE ROLE usr_api_mobile WITH LOGIN PASSWORD 'api_mobile_pass';

-- C. Rol grupo para la API
CREATE ROLE rol_api_acceso_vistas;
GRANT rol_api_acceso_vistas TO usr_api_web, usr_api_mobile;

-- Asegurar restricciones de privilegios
ALTER ROLE usr_fdw_pg_mssql  NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;
ALTER ROLE usr_fdw_pg_mongo  NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;
ALTER ROLE usr_api_web       NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;
ALTER ROLE usr_api_mobile    NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;

-- ============================================================
-- (2) ASIGNACIÓN DE PERMISOS
-- ============================================================

-- Permitir conexión a la base
GRANT CONNECT ON DATABASE sistema_medico_db TO rol_api_acceso_vistas;
GRANT CONNECT ON DATABASE sistema_medico_db TO usr_fdw_pg_mssql, usr_fdw_pg_mongo;

-- A. Permisos API (solo lectura en vistas)
GRANT USAGE ON SCHEMA core_medico TO rol_api_acceso_vistas;
GRANT SELECT ON vista_citas_detalle TO rol_api_acceso_vistas;

-- Permisos automáticos para futuras vistas
ALTER DEFAULT PRIVILEGES IN SCHEMA core_medico
GRANT SELECT ON TABLES TO rol_api_acceso_vistas;

-- B. Permisos FDW (solo lectura general)
GRANT USAGE ON SCHEMA core_medico TO usr_fdw_pg_mssql, usr_fdw_pg_mongo;

-- ============================================================
-- (3) INSTALACIÓN DE EXTENSIONES FDW
-- ============================================================
CREATE EXTENSION IF NOT EXISTS tds_fdw;
CREATE EXTENSION IF NOT EXISTS mongo_fdw;

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
