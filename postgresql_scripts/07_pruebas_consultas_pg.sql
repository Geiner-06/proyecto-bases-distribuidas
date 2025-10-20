-- ============================================================
-- PRUEBAS DISTRIBUIDAS ENTRE POSTGRESQL, SQL SERVER Y MONGODB
-- Fecha: 18/10/2025
-- ============================================================

SET search_path TO core_medico, integracion;

-- 1. Consulta en PostgreSQL que obtiene datos del paciente y su estado de facturación desde SQL Server.
-- -----------------------------------------------------------------------------------------------------

SELECT 
    p.nombre || ' ' || p.apellido1 AS paciente,
    p.email,
    fe.monto,
    fe.estado_facturacion,
    fe.fecha_actualizacion_estado
FROM 
    core_medico.pacientes p
JOIN 
    core_medico.estudios_ordenados eo ON p.id_paciente = (
        SELECT c.id_paciente_fk 
        FROM core_medico.citas c 
        JOIN core_medico.ordenes_medicas om ON c.id_cita = om.id_cita_fk 
        WHERE om.id_orden = eo.id_orden_fk 
        LIMIT 1
    )
JOIN 
    integracion.facturacion_externa_fdw fe ON eo.id_estudio_ordenado = fe.id_estudio_ordenado_pg
WHERE 
    p.id_paciente = 1;


-- 2. Inserción en PostgreSQL que actualiza un documento en MongoDB (vía trigger).
-- -----------------------------------------------------------------------------------

UPDATE estudios_ordenados
SET 
    resultado = 'El paciente muestra niveles de glucosa estables.',
    estado_estudio = 'Resultado listo',
    fecha_resultado = now()
WHERE id_estudio_ordenado = 4; -- Usamos el ID 4 que estaba 'Pendiente de toma'

-- Después de ejecutar esto, se debe verificar en MongoDB que el nuevo documento fue creado.


-- 3. Creación de una vista en PostgreSQL que combine datos locales y remotos.
-- --------------------------------------------------------------------------------

CREATE OR REPLACE VIEW vista_paciente_aseguradora AS
SELECT
    p.id_paciente,
    p.nombre || ' ' || p.apellido1 AS nombre_completo,
    pi.id_aseguradora,
    pi.poliza_vigente
FROM pacientes p
LEFT JOIN paciente_integracion_fdw pi ON p.id_paciente = pi.id_paciente_pg;

-- Otorgar permisos a los roles de la API para que puedan usarla
GRANT SELECT ON vista_paciente_aseguradora TO rol_api_acceso_vistas;

-- Consulta de prueba sobre la nueva vista
SELECT * FROM vista_paciente_aseguradora WHERE id_aseguradora = 'INS';

-- 4. Consulta analítica en MongoDB
-- ---------------------------------------------------------------------

-- db.reportes_estudios.aggregate([ { $group: { _id: "$sucursal", total_estudios: { $sum: 1 } } } ]);


-- 5. Llamar a la tabla de resumen de SQL Server desde PostgreSQL.
-- -------------------------------------------------------------------------------------------

SELECT * FROM integracion.v_resumen_facturacion_fdw;

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
