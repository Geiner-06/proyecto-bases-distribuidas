-- ============================================================
-- SISTEMA DE GESTIÓN DE ESTUDIOS MÉDICOS DISTRIBUIDO
-- Carga de Datos de Prueba - SQL Server (Integración Externa)
-- Fecha: 16/10/2025
-- ============================================================

USE integracion_externa_db;
GO

-- ============================================================
-- LIMPIEZA  (BORRA DATOS ANTERIORES)
-- ============================================================
DELETE FROM dbo.FacturacionExterna;
DELETE FROM dbo.ConveniosAseguradoras;
DELETE FROM dbo.PacienteIntegracion;
GO

-- ============================================================
-- (1) TABLA: PacienteIntegracion
-- ============================================================
INSERT INTO dbo.PacienteIntegracion (id_paciente_pg, id_aseguradora, codigo_paciente_externo, poliza_vigente)
VALUES
(1, 'INS', 'INS-0001', 1),
(2, 'INS', 'INS-0002', 1),
(3, 'MAPFRE', 'MAP-0003', 1),
(4, 'ASSA', 'ASSA-0004', 0),
(5, 'INS', 'INS-0005', 1),
(6, 'MAPFRE', 'MAP-0006', 1),
(7, 'ASSA', 'ASSA-0007', 0),
(8, 'INS', 'INS-0008', 1),
(9, 'MAPFRE', 'MAP-0009', 1),
(10, 'ASSA', 'ASSA-0010', 1);
GO

-- ============================================================
-- (2) TABLA: ConveniosAseguradoras
-- ============================================================
INSERT INTO dbo.ConveniosAseguradoras (id_aseguradora, codigo_estudio_pg, cobertura_porcentaje)
VALUES
('INS', 'LAB001', 90),
('INS', 'IMG001', 80),
('INS', 'IMG002', 85),
('MAPFRE', 'LAB001', 88),
('MAPFRE', 'LAB002', 92),
('MAPFRE', 'IMG003', 75),
('ASSA', 'LAB003', 70),
('ASSA', 'IMG001', 65),
('ASSA', 'IMG003', 72),
('ASSA', 'IMG002', 60);
GO

-- ============================================================
-- (3) TABLA: FacturacionExterna
-- ============================================================
INSERT INTO dbo.FacturacionExterna (id_estudio_ordenado_pg, monto, estado_facturacion, fecha_actualizacion_estado)
VALUES
(1, 25000.00, 'Pagada', GETDATE()),
(2, 38000.00, 'Pendiente', GETDATE()),
(3, 42000.00, 'Pagada', GETDATE()),
(4, 15000.00, 'Pendiente', GETDATE()),
(5, 52000.00, 'Pagada', GETDATE()),
(6, 27500.00, 'Rechazada', GETDATE()),
(7, 31000.00, 'Pendiente', GETDATE()),
(8, 29000.00, 'Pagada', GETDATE()),
(9, 47000.00, 'Pagada', GETDATE()),
(10, 19000.00, 'Pendiente', GETDATE());
GO

PRINT 'Datos de prueba insertados exitosamente en todas las tablas.';
GO