-- ============================================================
-- PRUEBAS DISTRIBUIDAS ENTRE POSTGRESQL, SQL SERVER Y MONGODB
-- Autor: Geiner Barrantes
-- Fecha: 17/10/2025
-- ============================================================

SET search_path TO core_medico;

-- ============================================================
-- CONSULTA CRUZADA: Información del paciente + facturación (SQL Server)
-- ============================================================

-- Esta vista combina datos del núcleo clínico (PostgreSQL)
-- con el estado de facturación (desde SQL Server vía FDW).
CREATE OR REPLACE VIEW integracion.vw_paciente_facturacion AS
SELECT 
    p.id_paciente,
    p.nombre || ' ' || p.apellido1 || ' ' || p.apellido2 AS paciente,
    s.nombre AS sucursal,
    f.monto,
    f.estado_facturacion,
    f.fecha_actualizacion_estado
FROM core_medico.pacientes p
JOIN core_medico.citas c ON p.id_paciente = c.id_paciente_fk
JOIN core_medico.ordenes_medicas om ON c.id_cita = om.id_cita_fk
JOIN core_medico.estudios_ordenados eo ON om.id_orden = eo.id_orden_fk
LEFT JOIN integracion.facturacion_externa_fdw f ON eo.id_estudio_ordenado = f.id_estudio_ordenado_pg
JOIN core_medico.sucursales s ON p.id_sucursal_fk = s.id_sucursal;

-- Probar consulta
SELECT * FROM integracion.vw_paciente_facturacion LIMIT 7;

-- ============================================================
-- INSERCIÓN CON EXPORTACIÓN AUTOMÁTICA A MONGODB
-- ============================================================

-- Insertar un nuevo estudio que genera trigger hacia MongoDB

INSERT INTO core_medico.estudios_ordenados (id_orden_fk, id_tipo_estudio_fk, estado_estudio, resultado, fecha_resultado)
VALUES (1, 2, 'Resultado listo', 'Todo en parámetros normales', now());

-- Verificar que el documento se haya exportado
-- (Esto se puede ver en MongoDB Compass dentro de la colección "reportes_estudios")

-- ============================================================
-- ACTUALIZACIÓN Y SINCRONIZACIÓN
-- ============================================================

-- Simular la actualización de un estudio (se vuelve a exportar a Mongo)
UPDATE core_medico.estudios_ordenados
SET resultado = 'Leve aumento de glóbulos blancos', estado_estudio = 'Resultado listo', fecha_resultado = now()
WHERE id_estudio_ordenado = 1;

-- ============================================================
-- ELIMINACIÓN CON EFECTO DISTRIBUIDO
-- ============================================================

-- Eliminar una cita y verificar restricción en cascada (PostgreSQL)
DELETE FROM core_medico.citas WHERE id_cita = 7;

-- Comprobar si las órdenes relacionadas se mantienen o se bloquea por FK
-- (debe dar error si existen estudios asociados, demostrando integridad referencial)
-- ============================================================
-- VISTA PARA APLICACIÓN WEB: Datos combinados (PostgreSQL + SQL Server)
-- ============================================================

CREATE OR REPLACE VIEW integracion.vw_resumen_estudios AS
SELECT 
    eo.id_estudio_ordenado,
    p.nombre || ' ' || p.apellido1 AS paciente,
    te.nombre_estudio,
    s.nombre AS sucursal,
    f.estado_facturacion,
    f.monto,
    eo.resultado,
    eo.fecha_resultado
FROM core_medico.estudios_ordenados eo
JOIN core_medico.ordenes_medicas om ON eo.id_orden_fk = om.id_orden
JOIN core_medico.citas c ON om.id_cita_fk = c.id_cita
JOIN core_medico.pacientes p ON c.id_paciente_fk = p.id_paciente
JOIN core_medico.sucursales s ON c.id_sucursal_fk = s.id_sucursal
LEFT JOIN integracion.facturacion_externa_fdw f ON eo.id_estudio_ordenado = f.id_estudio_ordenado_pg
JOIN core_medico.tipos_estudio te ON eo.id_tipo_estudio_fk = te.id_tipo_estudio;

-- Vista lista para usar por la API web
SELECT * FROM integracion.vw_resumen_estudios LIMIT 10;

-- ============================================================
-- EXPORTACIÓN MASIVA A MONGODB PARA REPORTES
-- ============================================================

INSERT INTO integracion.reportes_estudios_fdw (
    id_estudio_ordenado_pg,
    fecha_estudio,
    sucursal,
    paciente,
    medico_solicitante,
    estudio,
    resultado_analitico
)
SELECT
    eo.id_estudio_ordenado,
    eo.fecha_resultado,
    (jsonb_build_object('id_sucursal_pg', s.id_sucursal, 'nombre', s.nombre))::text,
    (jsonb_build_object('id_paciente_pg', p.id_paciente, 'nombre_completo', p.nombre || ' ' || p.apellido1))::text,
    (jsonb_build_object('id_medico_pg', m.id_medico, 'nombre_completo', m.nombre || ' ' || m.apellido1, 'especialidad', m.especialidad))::text,
    (jsonb_build_object('codigo', te.codigo_estudio, 'nombre', te.nombre_estudio))::text,
    (jsonb_build_object('diagnostico', COALESCE(eo.resultado, '')))::text
FROM core_medico.estudios_ordenados eo
JOIN core_medico.ordenes_medicas om ON eo.id_orden_fk = om.id_orden
JOIN core_medico.citas c ON om.id_cita_fk = c.id_cita
JOIN core_medico.pacientes p ON c.id_paciente_fk = p.id_paciente
JOIN core_medico.medicos m ON om.id_medico_solicitante_fk = m.id_medico
JOIN core_medico.sucursales s ON c.id_sucursal_fk = s.id_sucursal
JOIN core_medico.tipos_estudio te ON eo.id_tipo_estudio_fk = te.id_tipo_estudio
WHERE eo.estado_estudio = 'Resultado listo';

-- ============================================================
-- CONSULTA ANALÍTICA EN MONGODB
-- ============================================================
-- En MongoDB Compass o shell ejecutar:

-- db.reportes_estudios.aggregate([
--   { $group: {
--       _id: { medico: "$medico_solicitante.nombre_completo", tipo: "$estudio.nombre" },
--       total_estudios: { $sum: 1 }
--   }},
--   { $sort: { "total_estudios": -1 } }
-- ]);

-- Resultado: Conteo de estudios realizados agrupados por médico y tipo de estudio.

-- ============================================================
-- FIN DEL SCRIPT DE PRUEBAS DISTRIBUIDAS
-- ============================================================
