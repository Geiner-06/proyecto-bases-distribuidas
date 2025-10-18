-- ============================================================
-- SISTEMA DE GESTIÓN DE ESTUDIOS MÉDICOS DISTRIBUIDO
-- Núcleo Transaccional - PostgreSQL
-- Autor: Geiner Barrantes
-- Fecha: 15/10/2025
-- ============================================================

DROP SCHEMA IF EXISTS core_medico CASCADE;

-- (1) CREACIÓN DEL ESQUEMA PRINCIPAL
CREATE SCHEMA IF NOT EXISTS core_medico;
SET search_path TO core_medico;

-- ============================================================
-- (2) TABLA: Sucursales
-- ============================================================
CREATE TABLE IF NOT EXISTS sucursales (
    id_sucursal SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    direccion TEXT,
    telefono VARCHAR(20),
	CONSTRAINT chk_telefono_formato
    CHECK (telefono ~ '^[0-9+\- ]{8,20}$' OR telefono IS NULL)
);

-- ============================================================
-- (3) TABLA: Pacientes
-- ============================================================

CREATE TABLE pacientes (
    id_paciente SERIAL,
    cedula VARCHAR(25) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido1 VARCHAR(100) NOT NULL,
    apellido2 VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    id_sucursal_fk INTEGER NOT NULL,

    -- PRIMARY KEY incluye la columna de partición
    PRIMARY KEY (id_paciente, id_sucursal_fk),

    -- Constraints únicas también incluyen la columna de partición
    CONSTRAINT uq_pacientes_cedula_sucursal UNIQUE (cedula, id_sucursal_fk),
    CONSTRAINT uq_pacientes_email_sucursal UNIQUE (email, id_sucursal_fk)
) PARTITION BY LIST (id_sucursal_fk);


-- ============================================================
-- (4) TABLA: Médicos
-- ============================================================
CREATE TABLE IF NOT EXISTS medicos (
    id_medico SERIAL PRIMARY KEY,
    cedula_profesional VARCHAR(25) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido1 VARCHAR(100) NOT NULL,
	apellido2 VARCHAR(100) NOT NULL,
    especialidad VARCHAR(100)
);

-- ============================================================
-- (5) TABLA: Usuarios (Administrativos)
-- ============================================================
CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nombre_completo VARCHAR(200),
    rol VARCHAR(50),
    id_sucursal_fk INTEGER NOT NULL,
    CONSTRAINT fk_usuario_sucursal FOREIGN KEY (id_sucursal_fk)
        REFERENCES sucursales (id_sucursal)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ============================================================
-- (6) TABLA: Tipos de Estudio
-- ============================================================
CREATE TABLE IF NOT EXISTS tipos_estudio (
    id_tipo_estudio SERIAL PRIMARY KEY,
    codigo_estudio VARCHAR(20) NOT NULL UNIQUE,
    nombre_estudio VARCHAR(255) NOT NULL,
    descripcion TEXT
);

-- ============================================================
-- (7) TABLA: Citas
-- ============================================================
CREATE TABLE IF NOT EXISTS citas (
    id_cita SERIAL PRIMARY KEY,
    fecha_hora_agendada TIMESTAMP NOT NULL,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('Agendada', 'Completada', 'Cancelada')),
    id_paciente_fk INTEGER NOT NULL,
    id_medico_fk INTEGER NOT NULL,
    id_sucursal_fk INTEGER NOT NULL,
    CONSTRAINT fk_cita_paciente FOREIGN KEY (id_paciente_fk, id_sucursal_fk)
    REFERENCES pacientes (id_paciente, id_sucursal_fk)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_cita_medico FOREIGN KEY (id_medico_fk)
        REFERENCES medicos (id_medico)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_cita_sucursal FOREIGN KEY (id_sucursal_fk)
        REFERENCES sucursales (id_sucursal)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ============================================================
-- (8) TABLA: Órdenes Médicas
-- ============================================================
CREATE TABLE IF NOT EXISTS ordenes_medicas (
    id_orden SERIAL PRIMARY KEY,
    fecha_creacion TIMESTAMP DEFAULT now(),
    id_cita_fk INTEGER NOT NULL,
    id_medico_solicitante_fk INTEGER NOT NULL,
    CONSTRAINT fk_orden_cita FOREIGN KEY (id_cita_fk)
        REFERENCES citas (id_cita)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_orden_medico FOREIGN KEY (id_medico_solicitante_fk)
        REFERENCES medicos (id_medico)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ============================================================
-- (9) TABLA: Estudios Ordenados (relación N–a–N)
-- ============================================================
CREATE TABLE IF NOT EXISTS estudios_ordenados (
    id_estudio_ordenado SERIAL PRIMARY KEY,
    id_orden_fk INTEGER NOT NULL,
    id_tipo_estudio_fk INTEGER NOT NULL,
    estado_estudio VARCHAR(50) CHECK (estado_estudio IN ('Pendiente de toma', 'En proceso', 'Resultado listo')),
    resultado TEXT,
    fecha_resultado TIMESTAMP,
    CONSTRAINT fk_estudio_orden FOREIGN KEY (id_orden_fk)
        REFERENCES ordenes_medicas (id_orden)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_estudio_tipo FOREIGN KEY (id_tipo_estudio_fk)
        REFERENCES tipos_estudio (id_tipo_estudio)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ============================================================
-- (10) ÍNDICES Y VISTAS ÚTILES
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_pacientes_sucursal ON pacientes(id_sucursal_fk);
CREATE INDEX IF NOT EXISTS idx_citas_paciente ON citas(id_paciente_fk);
CREATE INDEX IF NOT EXISTS idx_citas_medico ON citas(id_medico_fk);

-- Vista de ejemplo: Detalle de citas con paciente y médico
CREATE OR REPLACE VIEW vista_citas_detalle AS
SELECT 
    c.id_cita,
    c.fecha_hora_agendada,
    c.estado,
    p.nombre || ' ' || p.apellido1 || ' ' || p.apellido2 AS paciente,
    m.nombre || ' ' || m.apellido1 || ' ' || m.apellido2 AS medico,
    s.nombre AS sucursal
FROM citas c
JOIN pacientes p ON c.id_paciente_fk = p.id_paciente
JOIN medicos m ON c.id_medico_fk = m.id_medico
JOIN sucursales s ON c.id_sucursal_fk = s.id_sucursal;

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
