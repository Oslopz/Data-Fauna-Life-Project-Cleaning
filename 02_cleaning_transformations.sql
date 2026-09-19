-- =============================================================================
-- SCRIPT 02: TRANSFORMACIONES Y LIMPIEZA DE DATOS (FASE PROCESS)
-- Proyecto: data-fauna-life-analytics
-- Dataset: fauna_analytics
-- Autor: Oscar Junior López Arias
-- Propósito: Normalización categórica multicanal, sanitización de nulos,
--            blindaje de divisiones por cero y extracción de patrones regex.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Estandarización categórica de estados de pago y sanitización de errores
-- -----------------------------------------------------------------------------
SELECT 
    id_transaccion_token,
    metodo_pago,
    dispositivo,
    monto_usd,
    monto_neto_refugio_usd,
    -- Normalización de variantes bilingües a 3 estados canónicos
    CASE 
        WHEN UPPER(TRIM(estado_transaccion)) IN ('SUCCESS', 'APROBADA', 'EXITOSO', 'PAID') THEN 'COMPLETED'
        WHEN UPPER(TRIM(estado_transaccion)) IN ('ABANDONED', 'ABANDONADA', 'DROPOUT') THEN 'ABANDONED'
        WHEN UPPER(TRIM(estado_transaccion)) IN ('FAILED', 'RECHAZADA', 'FALLIDO', 'DECLINED') THEN 'FAILED'
        ELSE 'OTHER'
    END AS estado_transaccion_limpio,
    -- Limpieza de códigos de error eliminando valores nulos o cadenas 'NONE'
    COALESCE(NULLIF(TRIM(error_codigo), 'NONE'), 'NO_ERROR') AS codigo_error_normalizado
FROM 
    `data-fauna-life-analytics.fauna_analytics.log_checkout_donaciones`;

-- -----------------------------------------------------------------------------
-- 2. Extracción de patrones de origen en auditorías mediante expresiones regulares
-- -----------------------------------------------------------------------------
SELECT 
    id_post,
    -- Extrae el prefijo de origen institucional (ej. 'HUELLAS', 'BORREGO', 'TT')
    REGEXP_EXTRACT(id_post, r'POST-(?:OBS-)?([A-Z]+)') AS fuente_origen,
    TRIM(arquetipo_emocional) AS arquetipo_limpio,
    TRIM(percepcion_etica_ia) AS percepcion_etica_limpia
FROM 
    `data-fauna-life-analytics.fauna_analytics.auditoria_cualitativa_posts`;

-- -----------------------------------------------------------------------------
-- 3. Blindaje matemático contra divisiones por cero e imputación de nulos
-- -----------------------------------------------------------------------------
SELECT 
    id_post,
    COALESCE(vistas_totales, 0) AS vistas_totales_clean,
    COALESCE(shares, 0) AS shares_clean,
    COALESCE(clicks_link_bio, 0) AS clicks_link_bio_clean,
    -- Cálculo seguro de tasa de viralidad evitando excepciones de tiempo de ejecución
    ROUND(SAFE_DIVIDE(COALESCE(shares, 0), NULLIF(vistas_totales, 0)) * 100, 3) AS indice_viralidad_calculado
FROM 
    `data-fauna-life-analytics.fauna_analytics.interacciones_posts`;
