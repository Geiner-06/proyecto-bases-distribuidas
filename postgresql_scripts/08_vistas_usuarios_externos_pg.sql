-- ============================================================
-- SCRIPT DE CREACIÓN DE VISTAS PARA APLICACIONES
-- Sistema de Gestión de Estudios Médicos Distribuido
-- Fecha: 19/10/2025
-- ============================================================

-- Se establece el esquema de trabajo principal.
SET search_path TO core_medico, integracion;

-- ============================================================
-- (1) VISTA PARA LA APP MÓVIL: PRÓXIMAS CITAS DEL PACIENTE
-- Descripción: Vista ligera que muestra las citas futuras
-- de un paciente, ideal para que un usuario consulte desde su móvil.
-- ============================================================
CREATE OR REPLACE VIEW vista_movil_proximas_citas AS
SELECT
    c.id_cita,
    p.id_paciente,
    c.fecha_hora_agendada,
    s.nombre AS sucursal,
    m.nombre || ' ' || m.apellido1 AS medico_tratante,
    m.especialidad
FROM core_medico.citas c
JOIN core_medico.pacientes p ON c.id_paciente_fk = p.id_paciente AND c.id_sucursal_fk = p.id_sucursal_fk
JOIN core_medico.medicos m ON c.id_medico_fk = m.id_medico
JOIN core_medico.sucursales s ON c.id_sucursal_fk = s.id_sucursal
WHERE
    c.estado = 'Agendada' AND c.fecha_hora_agendada >= NOW();

SELECT * FROM vista_movil_proximas_citas;

-- ============================================================
-- (2) VISTA PARA AMBAS APIS: HISTORIAL DE ESTUDIOS DEL PACIENTE
-- Descripción: Ofrece un resumen completo de los estudios
-- ordenados a un paciente, incluyendo su estado y resultados.
-- Útil tanto en la web para una vista detallada como en el móvil.
-- ============================================================
CREATE OR REPLACE VIEW vista_historial_estudios_paciente AS
SELECT
    p.id_paciente,
    eo.id_estudio_ordenado,
    om.fecha_creacion AS fecha_orden,
    te.nombre_estudio AS estudio,
    eo.estado_estudio,
    eo.resultado,
    eo.fecha_resultado,
    s.nombre AS sucursal_atencion
FROM core_medico.estudios_ordenados eo
JOIN core_medico.ordenes_medicas om ON eo.id_orden_fk = om.id_orden
JOIN core_medico.citas c ON om.id_cita_fk = c.id_cita
JOIN core_medico.pacientes p ON c.id_paciente_fk = p.id_paciente AND c.id_sucursal_fk = p.id_sucursal_fk
JOIN core_medico.tipos_estudio te ON eo.id_tipo_estudio_fk = te.id_tipo_estudio
JOIN core_medico.sucursales s ON c.id_sucursal_fk = s.id_sucursal
ORDER BY p.id_paciente, om.fecha_creacion DESC;

SELECT * FROM vista_historial_estudios_paciente;

-- ============================================================
-- (3) VISTA PARA LA API WEB: PANEL DE CITAS DEL DÍA POR SUCURSAL
-- Descripción: Vista administrativa para la aplicación web.
-- Muestra todas las citas del día para una sucursal,
-- permitiendo al personal de recepción gestionar el flujo de pacientes.
-- ============================================================
CREATE OR REPLACE VIEW vista_web_panel_citas_diarias AS
SELECT
    c.id_cita,
    c.fecha_hora_agendada,
    c.estado,
    p.nombre || ' ' || p.apellido1 AS nombre_paciente,
    p.cedula AS cedula_paciente,
    m.nombre || ' ' || m.apellido1 AS nombre_medico,
    s.nombre AS sucursal,
    s.id_sucursal
FROM core_medico.citas c
JOIN core_medico.pacientes p ON c.id_paciente_fk = p.id_paciente AND c.id_sucursal_fk = p.id_sucursal_fk
JOIN core_medico.medicos m ON c.id_medico_fk = m.id_medico
JOIN core_medico.sucursales s ON c.id_sucursal_fk = s.id_sucursal
WHERE
    c.fecha_hora_agendada::date = CURRENT_DATE;

SELECT * FROM vista_web_panel_citas_diarias;
-- ============================================================
-- (4) VISTA WEB/MÓVIL: DATOS DEL PACIENTE CON INFO DE ASEGURADORA
-- Descripción: Combina datos locales de PostgreSQL con datos
-- remotos de SQL Server (a través de FDW). Permite a la aplicación
-- mostrar si la póliza de un paciente está vigente.
-- Hereda la vista 'vista_paciente_aseguradora' ya creada en "07_pruebas_consultas_pg".
-- ============================================================
--Si no se creó la vista, es esta:
CREATE OR REPLACE VIEW vista_paciente_aseguradora AS
SELECT
    p.id_paciente,
    p.nombre || ' ' || p.apellido1 AS nombre_completo,
    pi.id_aseguradora,
    pi.poliza_vigente
FROM core_medico.pacientes p
LEFT JOIN integracion.paciente_integracion_fdw pi ON p.id_paciente = pi.id_paciente_pg;
-- ============================================================

CREATE OR REPLACE VIEW vista_web_paciente_poliza AS
SELECT
    p.id_paciente,
    p.cedula,
    p.nombre || ' ' || p.apellido1 || ' ' || p.apellido2 AS nombre_completo,
    p.email,
    p.telefono,
    s.nombre AS sucursal_principal,
    COALESCE(vpa.id_aseguradora, 'No Registrada') AS aseguradora,
    COALESCE(vpa.poliza_vigente, FALSE) AS poliza_vigente
FROM core_medico.pacientes p
JOIN core_medico.sucursales s ON p.id_sucursal_fk = s.id_sucursal
LEFT JOIN core_medico.vista_paciente_aseguradora vpa ON p.id_paciente = vpa.id_paciente;

SELECT * FROM vista_web_paciente_poliza;
-- ============================================================
-- (5) ASIGNACIÓN DE PERMISOS A ROLES DE API
-- Descripción: Se otorgan permisos de solo lectura (SELECT)
-- sobre las nuevas vistas al rol 'rol_api_acceso_vistas',
-- que agrupa a los usuarios 'usr_api_web' y 'usr_api_mobile'.
-- ============================================================

-- Otorgar permisos para las nuevas vistas
GRANT SELECT ON vista_movil_proximas_citas TO rol_api_acceso_vistas;
GRANT SELECT ON vista_historial_estudios_paciente TO rol_api_acceso_vistas;
GRANT SELECT ON vista_web_panel_citas_diarias TO rol_api_acceso_vistas;
GRANT SELECT ON vista_web_paciente_poliza TO rol_api_acceso_vistas;

-- Confirmación de la asignación
SELECT grantee, table_schema, table_name, privilege_type
FROM information_schema.table_privileges
WHERE grantee = 'rol_api_acceso_vistas'
AND table_name IN (
    'vista_citas_detalle',
    'vista_paciente_aseguradora',
    'vista_movil_proximas_citas',
    'vista_historial_estudios_paciente',
    'vista_web_panel_citas_diarias',
    'vista_web_paciente_poliza'
);

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================