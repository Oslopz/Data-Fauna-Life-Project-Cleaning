-- =============================================================================
-- SCRIPT 01: GAP ANALYSIS & DIAGNÓSTICO DE INTEGRIDAD
-- Proyecto: data-fauna-life-analytics
-- Autor: Oscar Junior López Arias
-- Propósito: Identificar brechas de esquema, frecuencias reales de texto 
--            e inconsistencias relacionales entre tablas crudas.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Diagnóstico de frecuencias reales en estados de pasarela (Fuga de datos)
-- -----------------------------------------------------------------------------
SELECT 
    estado_transaccion AS valor_crudo,
    UPPER(TRIM(estado_transaccion)) AS valor_limpio,
    COUNT(1) AS frecuencia
FROM 
    `data-fauna-life-analytics.fauna_analytics.log_checkout_donaciones`
GROUP BY 
    1, 2
ORDER BY 
    frecuencia DESC;

-- -----------------------------------------------------------------------------
-- 2. Diagnóstico de registros huérfanos entre Auditoría Cualitativa y Telemetría
-- -----------------------------------------------------------------------------
SELECT 
    c.id_post AS id_post_auditoria,
    c.arquetipo_emocional,
    i.id_post AS id_post_telemetria,
    CASE 
        WHEN i.id_post IS NULL THEN 'Huérfano en Auditoría (Sin Telemetría - Benchmarks)'
        ELSE 'Coincidencia Exitosa (Telemetría Interna)'
    END AS estado_integridad
FROM 
    `data-fauna-life-analytics.fauna_analytics.auditoria_cualitativa_posts` c
LEFT JOIN 
    `data-fauna-life-analytics.fauna_analytics.interacciones_posts` i 
    ON TRIM(c.id_post) = TRIM(i.id_post);
