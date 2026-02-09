{{ config(
    materialized='table',
    schema='raw_monitoring'
) }}

SELECT 
    CURRENT_TIMESTAMP as generated_at,
    'Sales Analytics Project' as project_name,
    'GYP Company' as client_name,
    COUNT(DISTINCT model_name) as total_models,
    SUM(row_count) as total_records_processed,
    ROUND(AVG(data_quality_score), 2) as avg_quality_score,
    MAX(CASE WHEN overall_status = 'PASS' THEN 1 ELSE 0 END) as is_passing
FROM {{ ref('final_project_report') }}
WHERE model_name NOT IN ('data_quality_metrics', 'project_status', 'final_project_report')
