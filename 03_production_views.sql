-- =============================================================================
-- SCRIPT 03: VISTAS ANALÍTICAS DE PRODUCCIÓN (DDL VIEWS)
-- Proyecto: data-fauna-life-analytics
-- Dataset: fauna_analytics
-- Autor: Oscar Junior López Arias
-- Propósito: Despliegue de capas semánticas virtuales para consumo directo
--            en Looker Studio con nomenclatura y tipado estandarizados.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Vista Analítica: Rendimiento de Contenido y Retención (Producción)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `data-fauna-life-analytics.fauna_analytics.vw_rendimiento_produccion_limpio` AS
SELECT 
    p.id_post,
    p.plataforma,
    p.tipo_post,
    p.es_pauta_pagada,
    COALESCE(i.vistas_totales, 0) AS vistas_totales,
    ROUND(COALESCE(i.tasa_retencion_3s, 0), 4) AS tasa_retencion_3s_pct,
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
-- 2. Vista Analítica: Rendimiento Completo y Estrategia UICN
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `data-fauna-life-analytics.fauna_analytics.vw_rendimiento_completo` AS
SELECT 
    m.id_contenido,
    m.plataforma,
    p.arquetipo_avatar,
    p.especie_comun,
    p.nombre_cientifico,
    p.estado_uicn,
    p.gancho_inicial,
    m.vistas_totales,
    m.likes,
    m.compartidos AS shares, 
    m.clicks_link_bio,
    m.tiempo_promedio_retencion_seg,
    m.tasa_retencion_3s_pct
FROM 
    `data-fauna-life-analytics.fauna_analytics.metricas_rendimiento` m
LEFT JOIN 
    `data-fauna-life-analytics.fauna_analytics.contenido_plan` p 
    ON m.id_contenido = p.id_contenido;

-- -----------------------------------------------------------------------------
-- 3. Vista Analítica: Embudo Transaccional y Donaciones Netas
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
    CAST(ROUND(COALESCE(c.monto_usd, 0), 2) AS NUMERIC) AS monto_bruto_usd,
    CAST(ROUND(COALESCE(c.monto_neto_refugio_usd, 0), 2) AS NUMERIC) AS monto_neto_refugio_usd,
    CAST(ROUND(COALESCE(c.monto_usd, 0) - COALESCE(c.monto_neto_refugio_usd, 0), 2) AS NUMERIC) AS comision_pasarela_usd,
    COALESCE(NULLIF(TRIM(c.error_codigo), 'NONE'), 'NO_ERROR') AS codigo_error_normalizado
FROM 
    `data-fauna-life-analytics.fauna_analytics.log_checkout_donaciones` c;
