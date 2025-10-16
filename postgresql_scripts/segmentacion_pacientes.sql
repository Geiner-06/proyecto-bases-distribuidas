-- ============================================================
-- SEGMENTACIÓN HORIZONTAL DE PACIENTES POR PROVINCIA
-- Sistema de Gestión de Estudios Médicos Distribuido
-- Núcleo Transaccional - PostgreSQL
-- Autor: Geiner Barrantes
-- Fecha: 15/10/2025
-- ============================================================

SET search_path TO core_medico;

-- ============================================================
-- (1) PARTICIONES POR SUCURSAL
-- ============================================================

CREATE TABLE pacientes_sanjose
    PARTITION OF pacientes FOR VALUES IN (1);

CREATE TABLE pacientes_alajuela
    PARTITION OF pacientes FOR VALUES IN (2);

CREATE TABLE pacientes_cartago
    PARTITION OF pacientes FOR VALUES IN (3);

CREATE TABLE pacientes_heredia
    PARTITION OF pacientes FOR VALUES IN (4);

CREATE TABLE pacientes_guanacaste
    PARTITION OF pacientes FOR VALUES IN (5);

CREATE TABLE pacientes_puntarenas
    PARTITION OF pacientes FOR VALUES IN (6);

CREATE TABLE pacientes_limon
    PARTITION OF pacientes FOR VALUES IN (7);

-- ============================================================
-- (2) CONSTRAINTS POR PARTICIÓN
-- ============================================================

ALTER TABLE pacientes_sanjose 
  ADD CONSTRAINT uq_pacientes_sj_cedula UNIQUE (cedula),
  ADD CONSTRAINT uq_pacientes_sj_email UNIQUE (email),
  ADD CONSTRAINT chk_pacientes_sj_cedula CHECK (cedula ~ '^[0-9\-]+$'),
  ADD CONSTRAINT chk_pacientes_sj_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' OR email IS NULL);

ALTER TABLE pacientes_alajuela 
  ADD CONSTRAINT uq_pacientes_al_cedula UNIQUE (cedula),
  ADD CONSTRAINT uq_pacientes_al_email UNIQUE (email),
  ADD CONSTRAINT chk_pacientes_al_cedula CHECK (cedula ~ '^[0-9\-]+$'),
  ADD CONSTRAINT chk_pacientes_al_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' OR email IS NULL);

ALTER TABLE pacientes_cartago 
  ADD CONSTRAINT uq_pacientes_ca_cedula UNIQUE (cedula),
  ADD CONSTRAINT uq_pacientes_ca_email UNIQUE (email),
  ADD CONSTRAINT chk_pacientes_ca_cedula CHECK (cedula ~ '^[0-9\-]+$'),
  ADD CONSTRAINT chk_pacientes_ca_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' OR email IS NULL);

ALTER TABLE pacientes_heredia 
  ADD CONSTRAINT uq_pacientes_he_cedula UNIQUE (cedula),
  ADD CONSTRAINT uq_pacientes_he_email UNIQUE (email),
  ADD CONSTRAINT chk_pacientes_he_cedula CHECK (cedula ~ '^[0-9\-]+$'),
  ADD CONSTRAINT chk_pacientes_he_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' OR email IS NULL);

ALTER TABLE pacientes_guanacaste 
  ADD CONSTRAINT uq_pacientes_gu_cedula UNIQUE (cedula),
  ADD CONSTRAINT uq_pacientes_gu_email UNIQUE (email),
  ADD CONSTRAINT chk_pacientes_gu_cedula CHECK (cedula ~ '^[0-9\-]+$'),
  ADD CONSTRAINT chk_pacientes_gu_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' OR email IS NULL);

ALTER TABLE pacientes_puntarenas 
  ADD CONSTRAINT uq_pacientes_pu_cedula UNIQUE (cedula),
  ADD CONSTRAINT uq_pacientes_pu_email UNIQUE (email),
  ADD CONSTRAINT chk_pacientes_pu_cedula CHECK (cedula ~ '^[0-9\-]+$'),
  ADD CONSTRAINT chk_pacientes_pu_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' OR email IS NULL);

ALTER TABLE pacientes_limon 
  ADD CONSTRAINT uq_pacientes_li_cedula UNIQUE (cedula),
  ADD CONSTRAINT uq_pacientes_li_email UNIQUE (email),
  ADD CONSTRAINT chk_pacientes_li_cedula CHECK (cedula ~ '^[0-9\-]+$'),
  ADD CONSTRAINT chk_pacientes_li_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' OR email IS NULL);

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================