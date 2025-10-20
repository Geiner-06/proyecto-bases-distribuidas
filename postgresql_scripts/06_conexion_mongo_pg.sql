-- ============================================================
-- CONFIGURACIÓN DE CONEXIÓN FDW POSTGRESQL → MONGODB
-- Proyecto: Sistema Distribuido de Estudios Médicos
-- Fecha: 16/10/2025
-- ============================================================
SET search_path TO core_medico;
-- ============================================================
-- (1) CREAR EL SERVIDOR FORÁNEO
-- ============================================================
CREATE SERVER IF NOT EXISTS servidor_mongo_externo
FOREIGN DATA WRAPPER mongo_fdw
OPTIONS (
    address 'db_mongo',
    port '27017'
);

-- ============================================================
-- (2) CREAR EL MAPEO DE USUARIO
-- ============================================================
CREATE USER MAPPING IF NOT EXISTS FOR usr_fdw_pg_mongo
SERVER servidor_mongo_externo
OPTIONS (
    username 'usr_fdw_pg_mongo',        -- Usuario de MongoDB
    password 'PasswordParaMongo_789!'   -- Contraseña de MongoDB
);

-- Permitir que el usuario 'admin_pg' use la conexión FDW
CREATE USER MAPPING FOR admin_pg -- El usuario que está ejecutando el UPDATE
    SERVER servidor_mongo_externo
    OPTIONS (
        username 'usr_fdw_pg_mongo',     
        password 'PasswordParaMongo_789!'
    );

-- ============================================================
-- (3) CREAR LA TABLA FORÁNEA
-- ============================================================
-- Representa la colección 'reportes_estudios' de MongoDB

CREATE FOREIGN TABLE IF NOT EXISTS integracion.reportes_estudios_fdw (
    _id NAME,                       -- ID de MongoDB
    id_estudio_ordenado_pg INTEGER,
    fecha_estudio TIMESTAMP,
    sucursal TEXT,
    paciente TEXT,
    medico_solicitante TEXT,
    estudio TEXT,
    resultado_analitico TEXT,
    facturacion TEXT
)
SERVER servidor_mongo_externo
OPTIONS (
    database 'analitica_medica_db',
    collection 'reportes_estudios'
); 

-- ============================================================
-- (4) ASIGNAR PERMISOS
-- ============================================================
GRANT USAGE ON FOREIGN SERVER servidor_mongo_externo TO usr_fdw_pg_mongo;
GRANT INSERT ON integracion.reportes_estudios_fdw TO usr_fdw_pg_mongo; -- Solo inserción
GRANT INSERT ON integracion.reportes_estudios_fdw TO admin_pg;

-- ============================================================
-- (5) FUNCIÓN PARA EXPORTAR ESTUDIOS A MONGO
-- ============================================================
CREATE OR REPLACE FUNCTION integracion.fn_exportar_estudio_a_mongo() 
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.estado_estudio = 'Resultado listo' THEN
        INSERT INTO integracion.reportes_estudios_fdw (
            id_estudio_ordenado_pg,
            fecha_estudio,
            sucursal,
            paciente,
            medico_solicitante,
            estudio,
            resultado_analitico,
            facturacion
        )
        SELECT
            NEW.id_estudio_ordenado,
            NEW.fecha_resultado,
            jsonb_build_object('id_sucursal_pg', s.id_sucursal, 'nombre', s.nombre),
            jsonb_build_object('id_paciente_pg', p.id_paciente, 'nombre_completo', p.nombre || ' ' || p.apellido1),
            jsonb_build_object(
                'id_medico_pg', m.id_medico,
                'nombre_completo', m.nombre || ' ' || m.apellido1,
                'especialidad', COALESCE(m.especialidad, '')
            ),
            jsonb_build_object('codigo', te.codigo_estudio, 'nombre', te.nombre_estudio),
            jsonb_build_object('diagnostico', COALESCE(NEW.resultado, '')),
            jsonb_build_object(
                'monto', COALESCE(fe.monto, 0),
                'estado', COALESCE(fe.estado_facturacion, 'Pendiente'),
                'fecha_actualizacion', COALESCE(fe.fecha_actualizacion_estado, now())
            )
        FROM core_medico.ordenes_medicas om
        JOIN core_medico.citas c ON om.id_cita_fk = c.id_cita
        JOIN core_medico.pacientes p ON c.id_paciente_fk = p.id_paciente
        JOIN core_medico.medicos m ON om.id_medico_solicitante_fk = m.id_medico
        JOIN core_medico.sucursales s ON c.id_sucursal_fk = s.id_sucursal
        JOIN core_medico.tipos_estudio te ON NEW.id_tipo_estudio_fk = te.id_tipo_estudio
        LEFT JOIN integracion.facturacion_externa_fdw fe ON NEW.id_estudio_ordenado = fe.id_estudio_ordenado_pg
        WHERE om.id_orden = NEW.id_orden_fk;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- (6) CREAR TRIGGER PARA ENVIAR RESULTADOS A MONGO
-- ============================================================
CREATE TRIGGER trg_enviar_resultado_a_mongo
AFTER INSERT OR UPDATE ON core_medico.estudios_ordenados
FOR EACH ROW
EXECUTE FUNCTION integracion.fn_exportar_estudio_a_mongo();

-- ============================================================
-- AJUSTE DE PERMISOS PARA EL TRIGGER DE MONGODB
-- Otorgar permisos de lectura al usuario FDW de MongoDB
-- ============================================================

-- El usuario FDW necesita LEER de estas tablas para construir el reporte
GRANT SELECT ON TABLE ordenes_medicas TO usr_fdw_pg_mongo;
GRANT SELECT ON TABLE citas TO usr_fdw_pg_mongo;
GRANT SELECT ON TABLE pacientes TO usr_fdw_pg_mongo;
GRANT SELECT ON TABLE medicos TO usr_fdw_pg_mongo;
GRANT SELECT ON TABLE sucursales TO usr_fdw_pg_mongo;
GRANT SELECT ON TABLE tipos_estudio TO usr_fdw_pg_mongo;
GRANT SELECT ON TABLE estudios_ordenados TO usr_fdw_pg_mongo;

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
