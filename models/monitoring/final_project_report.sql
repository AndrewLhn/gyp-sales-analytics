{{ config(materialized='table', schema='monitoring') }}

-- Финальный отчет о состоянии проекта
WITH table_counts AS (
    SELECT 'raw.raw_sales' as table_name, COUNT(*) as record_count FROM raw.raw_sales
    UNION ALL
    SELECT 'stg_sales', COUNT(*) FROM raw_staging.stg_sales
    UNION ALL
    SELECT 'fct_sales', COUNT(*) FROM raw_analytics.fct_sales
    UNION ALL
    SELECT 'monthly_sales_report', COUNT(*) FROM raw_analytics.monthly_sales_report
    UNION ALL
    SELECT 'dim_customers', COUNT(*) FROM raw.dim_customers
),
data_quality AS (
    SELECT 
        COUNT(*) as total_records,
        COUNT(*) FILTER (WHERE id IS NULL OR total_amount IS NULL) as critical_issues
    FROM raw_staging.stg_sales
)
SELECT 
    '🎉 Проект аналитики продаж завершен' as title,
    'Стек: PostgreSQL + dbt' as stack,
    CURRENT_TIMESTAMP as generation_time,
    
    -- Сводка по таблицам
    (SELECT STRING_AGG(table_name || ': ' || record_count::text, ', ') FROM table_counts) as tables_summary,
    
    -- Общая статистика
    (SELECT SUM(record_count) FROM table_counts) as total_records_in_project,
    (SELECT critical_issues FROM data_quality) as data_quality_issues,
    
    -- Оценка
    CASE 
        WHEN (SELECT critical_issues FROM data_quality) = 0 THEN 'Отличное качество данных'
        WHEN (SELECT critical_issues FROM data_quality) < 10 THEN 'Хорошее качество данных'
        ELSE 'Требуется улучшение качества данных'
    END as quality_assessment,
    
    'Готов к использованию в BI-системах' as recommendation
