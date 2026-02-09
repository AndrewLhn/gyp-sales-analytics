{{ config(
    materialized='table',
    schema='raw_monitoring'
) }}

WITH model_counts AS (
    SELECT 'stg_sales' as model_name, COUNT(*) as row_count FROM {{ ref('stg_sales') }}
    UNION ALL
    SELECT 'dim_customers' as model_name, COUNT(*) as row_count FROM {{ ref('dim_customers') }}
    UNION ALL
    SELECT 'fct_sales' as model_name, COUNT(*) as row_count FROM {{ ref('fct_sales') }}
    UNION ALL
    SELECT 'monthly_sales_report' as model_name, COUNT(*) as row_count FROM {{ ref('monthly_sales_report') }}
    UNION ALL
    SELECT 'data_quality_metrics' as model_name, COUNT(*) as row_count FROM {{ ref('data_quality_metrics') }}
    UNION ALL
    SELECT 'project_status' as model_name, COUNT(*) as row_count FROM {{ ref('project_status') }}
),
quality_summary AS (
    SELECT 
        checked_at,
        total_records,
        unique_ids,
        duplicate_ids,
        null_ids,
        null_reference_ids,
        null_amounts,
        negative_amounts,
        null_dates,
        future_dates,
        invalid_date_ranges,
        critical_issue_percent,
        data_quality_score,
        CASE 
            WHEN critical_issue_percent = 0 THEN 'PASS'
            ELSE 'WARNING'
        END as quality_status
    FROM {{ ref('data_quality_metrics') }}
    ORDER BY checked_at DESC
    LIMIT 1
)

SELECT 
    CURRENT_TIMESTAMP as report_timestamp,
    (SELECT COUNT(*) FROM model_counts) as total_models,
    (SELECT SUM(row_count) FROM model_counts) as total_rows,
    mc.model_name,
    mc.row_count,
    qs.total_records,
    qs.unique_ids,
    qs.duplicate_ids,
    qs.null_ids,
    qs.null_reference_ids,
    qs.null_amounts,
    qs.negative_amounts,
    qs.null_dates,
    qs.future_dates,
    qs.invalid_date_ranges,
    qs.critical_issue_percent,
    qs.data_quality_score,
    qs.quality_status as overall_status,
    qs.checked_at as last_quality_check
FROM model_counts mc
CROSS JOIN quality_summary qs
ORDER BY mc.model_name
