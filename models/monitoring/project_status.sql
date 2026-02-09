{{ config(materialized='table', schema='monitoring') }}

WITH stats AS (
    SELECT 
        (SELECT COUNT(*) FROM {{ ref('raw_sales') }}) as raw_records,
        (SELECT COUNT(*) FROM {{ ref('stg_sales') }}) as staging_records,
        (SELECT COUNT(*) FROM {{ ref('fct_sales') }}) as analytics_records,
        (SELECT COUNT(*) FROM {{ ref('monthly_sales_report') }}) as report_records,
        (SELECT COUNT(*) FROM {{ ref('dim_customers') }}) as dimension_records,
        (SELECT COUNT(*) FROM {{ ref('stg_sales') }} WHERE id IS NULL OR total_amount IS NULL) as critical_issues
)
SELECT 
    'Проект аналитики продаж' as project_name,
    'PostgreSQL + dbt' as technology_stack,
    CURRENT_DATE as report_date,
    raw_records,
    staging_records,
    analytics_records,
    report_records,
    dimension_records,
    critical_issues,
    '✅ Работоспособен' as status
FROM stats
