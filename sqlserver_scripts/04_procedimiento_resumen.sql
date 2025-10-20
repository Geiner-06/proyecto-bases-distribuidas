USE integracion_externa_db;
GO

-- 1Crear la vista con los datos agregados
CREATE OR ALTER VIEW dbo.v_resumen_facturacion AS
SELECT 
    pi.id_aseguradora AS aseguradora,
    COUNT(fe.id_factura_externa) AS total_facturas,
    SUM(fe.monto) AS monto_total,
    AVG(fe.monto) AS promedio
FROM dbo.FacturacionExterna fe
JOIN dbo.PacienteIntegracion pi 
    ON fe.id_estudio_ordenado_pg = pi.id_paciente_pg
GROUP BY pi.id_aseguradora;
GO

-- Otorgar permisos de lectura al usuario FDW (no EXECUTE)
GRANT SELECT ON dbo.v_resumen_facturacion TO usr_fdw_pg_mssql;
GO
