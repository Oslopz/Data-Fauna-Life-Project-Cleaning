# Data Fauna Life Analytics — Data Cleaning & Pipeline Scripts

Este repositorio contiene los scripts SQL de diagnóstico, transformación y modelado semántico desarrollados en **Google Cloud BigQuery** para el proyecto de grado *Data Fauna Life* (Certificado Profesional de Análisis de Datos de Google).

## 📁 Estructura del Repositorio

| Archivo | Descripción / Fase | Técnicas Clave |
| :--- | :--- | :--- |
| `01_gap_diagnostics.sql` | Diagnóstico de integridad de esquemas, detección de registros huérfanos y análisis de frecuencias en pasarelas. | `GROUP BY`, `UPPER(TRIM())`, `LEFT JOIN` |
| `02_cleaning_transformations.sql` | Normalización categórica multicanal, sanitización de nulos y blindaje matemático. | `CASE WHEN`, `REGEXP_EXTRACT`, `COALESCE`, `SAFE_DIVIDE` |
| `03_production_views.sql` | DDL de vistas analíticas finales (`vw_rendimiento_produccion_limpio` y `vw_checkout_donaciones_limpio`) para consumo en Looker Studio. | `CREATE OR REPLACE VIEW` |

## 🛠️ Stack Tecnológico
* **Motor:** Google Cloud BigQuery
* **Dataset:** `data-fauna-life-analytics.fauna_analytics`
* **Gobernanza:** Transformational Philanthropy, Bioseguridad GPS (LEG-024), Anonimización PII.

## 👤 Autor
* **Lead Data Analyst:** Oscar Junior López Arias
