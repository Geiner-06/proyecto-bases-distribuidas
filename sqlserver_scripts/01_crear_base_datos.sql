-- ============================================================
-- CONFIGURACI�N INICIAL DE SQL SERVER
-- Crear Base de Datos y Usuario para conexi�n FDW desde PostgreSQL
-- Fecha: 16/10/2025
-- ============================================================

-- (1) Crear la base de datos para integraci�n externa
CREATE DATABASE integracion_externa_db;
GO

-- (2) Cambiar al contexto de la base creada
USE integracion_externa_db;
GO

-- (3) Crear el login (a nivel de servidor)
-- Esta cuenta ser� usada por PostgreSQL para conectarse v�a FDW.
CREATE LOGIN usr_fdw_pg_mssql WITH PASSWORD = 'Postgres_123';
GO

-- (4) Crear el usuario (a nivel de base de datos)
-- Lo asociamos al login creado anteriormente.
CREATE USER usr_fdw_pg_mssql FOR LOGIN usr_fdw_pg_mssql;
GO