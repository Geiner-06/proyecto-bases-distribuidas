-- ============================================================
-- SISTEMA DE GESTIÓN DE ESTUDIOS MÉDICOS DISTRIBUIDO
-- Datos de Prueba - Núcleo Transaccional (PostgreSQL)
-- Autor: Geiner Barrantes
-- Fecha: 15/10/2025
-- ============================================================

SET search_path TO core_medico;

-- ============================================================
-- (1) SUCURSALES
-- ============================================================
INSERT INTO sucursales (nombre, direccion, telefono) VALUES
('San José', 'Av. Central 101, San José', '+506 2222-1111'),
('Alajuela', 'Calle Real, Alajuela', '+506 2444-2222'),
('Cartago', 'Ave. 3, Cartago Centro', '+506 2555-3333'),
('Heredia', 'Calle 8, Heredia Centro', '+506 2266-4444'),
('Guanacaste', 'Liberia, 100m norte del parque', '+506 2666-5555'),
('Puntarenas', 'Paseo de los Turistas, Puntarenas', '+506 2661-6666'),
('Limón', 'Centro de Limón, diagonal al hospital', '+506 2758-7777');

-- ============================================================
-- (2) MÉDICOS
-- ============================================================
INSERT INTO medicos (cedula_profesional, nombre, apellido1, apellido2, especialidad) VALUES
('MED001', 'Ana', 'Ramírez', 'Campos', 'Radiología'),
('MED002', 'Carlos', 'Gómez', 'Vargas', 'Pediatría'),
('MED003', 'Laura', 'Jiménez', 'Soto', 'Cardiología'),
('MED004', 'Jorge', 'Sáenz', 'Mora', 'Dermatología'),
('MED005', 'María', 'Cordero', 'Rojas', 'Medicina General'),
('MED006', 'Andrés', 'Pérez', 'Guzmán', 'Gastroenterología'),
('MED007', 'Sofía', 'Arias', 'Méndez', 'Neurología');

-- ============================================================
-- (3) USUARIOS ADMINISTRATIVOS
-- ============================================================
INSERT INTO usuarios (username, password_hash, nombre_completo, rol, id_sucursal_fk) VALUES
('admin_sj', 'hash123', 'Lucía Fernández', 'admin', 1),
('recep_al', 'hash456', 'Juan Castro', 'recepcionista', 2),
('admin_ca', 'hash789', 'Elena Solís', 'admin', 3),
('recep_he', 'hash321', 'Mario Monge', 'recepcionista', 4),
('admin_gu', 'hash654', 'Carmen Herrera', 'admin', 5),
('recep_pu', 'hash987', 'Luis Delgado', 'recepcionista', 6),
('admin_li', 'hash741', 'Beatriz Alfaro', 'admin', 7);

-- ============================================================
-- (4) PACIENTES
-- ============================================================
INSERT INTO pacientes (cedula, nombre, apellido1, apellido2, fecha_nacimiento, telefono, email, id_sucursal_fk) VALUES
('1-1234-5678', 'José', 'Pérez', 'Gómez', '1980-03-15', '+506 8888-1111', 'jose.perez@email.com', 1),
('2-2345-6789', 'María', 'Rodríguez', 'Solis', '1990-07-20', '+506 8888-2222', 'maria.rodriguez@email.com', 2),
('3-3456-7890', 'Andrés', 'Campos', 'Jiménez', '1985-02-10', '+506 8888-3333', 'andres.campos@email.com', 3),
('4-4567-8901', 'Carolina', 'Vargas', 'Mora', '1992-12-05', '+506 8888-4444', 'carolina.vargas@email.com', 4),
('5-5678-9012', 'Felipe', 'Cordero', 'Araya', '1978-11-30', '+506 8888-5555', 'felipe.cordero@email.com', 5),
('6-6789-0123', 'Daniela', 'Jiménez', 'Soto', '1988-09-09', '+506 8888-6666', 'daniela.jimenez@email.com', 6),
('7-7890-1234', 'Esteban', 'Méndez', 'Ramírez', '1995-04-25', '+506 8888-7777', 'esteban.mendez@email.com', 7);

-- ============================================================
-- (5) TIPOS DE ESTUDIO
-- ============================================================
INSERT INTO tipos_estudio (codigo_estudio, nombre_estudio, descripcion) VALUES
('LAB001', 'Hemograma completo', 'Análisis general de sangre.'),
('IMG001', 'Radiografía de tórax', 'Imagen de la caja torácica.'),
('IMG002', 'Ultrasonido abdominal', 'Evaluación de órganos abdominales.'),
('LAB002', 'Perfil lipídico', 'Medición de colesterol y triglicéridos.'),
('IMG003', 'Resonancia magnética cerebral', 'Exploración del cerebro.'),
('LAB003', 'Prueba de glucosa', 'Determinación del nivel de azúcar en sangre.');

-- ============================================================
-- (6) CITAS
-- ============================================================
INSERT INTO citas (fecha_hora_agendada, estado, id_paciente_fk, id_medico_fk, id_sucursal_fk) VALUES
('2025-10-20 08:00:00', 'Agendada', 1, 1, 1),
('2025-10-20 09:30:00', 'Completada', 2, 2, 2),
('2025-10-21 10:00:00', 'Agendada', 3, 3, 3),
('2025-10-22 11:00:00', 'Agendada', 4, 4, 4),
('2025-10-23 13:00:00', 'Completada', 5, 5, 5),
('2025-10-23 14:30:00', 'Cancelada', 6, 6, 6),
('2025-10-24 15:00:00', 'Agendada', 7, 7, 7);

-- ============================================================
-- (7) ÓRDENES MÉDICAS
-- ============================================================
INSERT INTO ordenes_medicas (fecha_creacion, id_cita_fk, id_medico_solicitante_fk) VALUES
(now(), 1, 1),
(now(), 2, 2),
(now(), 3, 3),
(now(), 4, 4),
(now(), 5, 5),
(now(), 6, 6),
(now(), 7, 7);

-- ============================================================
-- (8) ESTUDIOS ORDENADOS
-- ============================================================
INSERT INTO estudios_ordenados (id_orden_fk, id_tipo_estudio_fk, estado_estudio, resultado, fecha_resultado) VALUES
(1, 1, 'Pendiente de toma', NULL, NULL),
(2, 2, 'Resultado listo', 'Sin anomalías detectadas.', now()),
(3, 3, 'En proceso', NULL, NULL),
(4, 4, 'Pendiente de toma', NULL, NULL),
(5, 5, 'Resultado listo', 'Se observan lesiones menores.', now()),
(6, 6, 'Pendiente de toma', NULL, NULL),
(7, 1, 'Pendiente de toma', NULL, NULL);

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================