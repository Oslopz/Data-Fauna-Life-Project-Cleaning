-- =============================================================================
-- SCRIPT 03: VISTAS ANALÍTICAS DE PRODUCCIÓN (DDL VIEWS)
-- Proyecto: data-fauna-life-analytics
-- Dataset: fauna_analytics
-- Autor: Oscar Junior López Arias
-- Propósito: Despliegue de capas semánticas virtuales para consumo directo
--            en Looker Studio sin duplicación física de almacenamiento.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Vista Analítica: Rendimiento y Retención de Contenido
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `data-fauna-life-analytics.fauna_analytics.vw_rendimiento_produccion_limpio` AS
SELECT 
    p.id_post,
    p.plataforma,
    p.tipo_post,
    p.es_pauta_pagada,
    COALESCE(i.vistas_totales, 0) AS vistas_totales,
    ROUND(COALESCE(i.tasa_retencion_3s, 0), 4) AS tasa_retencion_3s,
    COALESCE(i.shares, 0) AS shares,
    COALESCE(i.clicks_link_bio, 0) AS clicks_link_bio,
    ROUND(SAFE_DIVIDE(COALESCE(i.shares, 0), NULLIF(i.vistas_totales, 0)) * 100, 3) AS indice_viralidad_pct,
    CASE 
        WHEN i.tasa_retencion_3s >= 0.60 THEN 'Optimo (>=60%)'
        ELSE 'Bajo Umbral (<60%)'
    END AS clasificacion_retencion
FROM 
    `data-fauna-life-analytics.fauna_analytics.contenido_posts` p
LEFT JOIN 
    `data-fauna-life-analytics.fauna_analytics.interacciones_posts` i 
    ON p.id_post = i.id_post;

-- -----------------------------------------------------------------------------
-- 2. Vista Analítica: Embudo de Checkout y Donaciones Netas
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `data-fauna-life-analytics.fauna_analytics.vw_checkout_donaciones_limpio` AS
SELECT 
    c.id_transaccion_token,
    c.metodo_pago,
    c.dispositivo,
    CASE 
        WHEN UPPER(TRIM(c.estado_transaccion)) IN ('SUCCESS', 'APROBADA', 'EXITOSO', 'PAID') THEN 'COMPLETED'
        WHEN UPPER(TRIM(c.estado_transaccion)) IN ('ABANDONED', 'ABANDONADA', 'DROPOUT') THEN 'ABANDONED'
        WHEN UPPER(TRIM(c.estado_transaccion)) IN ('FAILED', 'RECHAZADA', 'FALLIDO', 'DECLINED') THEN 'FAILED'
        ELSE 'OTHER'
    END AS estado_transaccion_limpio,
    ROUND(COALESCE(c.monto_usd, 0), 2) AS monto_bruto_usd,
    ROUND(COALESCE(c.monto_neto_refugio_usd, 0), 2) AS monto_neto_refugio_usd,
    ROUND(COALESCE(c.monto_usd, 0) - COALESCE(c.monto_neto_refugio_usd, 0), 2) AS comision_pasarela_usd,
    COALESCE(NULLIF(TRIM(c.error_codigo), 'NONE'), 'NO_ERROR') AS codigo_error_normalizado
FROM 
    `data-fauna-life-analytics.fauna_analytics.log_checkout_donaciones` c;
