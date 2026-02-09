{{ config(
    materialized='table',
    schema='monitoring'
) }}

WITH metrics AS (
    SELECT 
        COUNT(*) as total_records,
        COUNT(DISTINCT id) as unique_ids,
        COUNT(*) FILTER (WHERE id IS NULL) as null_ids,
        COUNT(*) FILTER (WHERE reference_id IS NULL) as null_reference_ids,
        COUNT(*) FILTER (WHERE total_amount IS NULL) as null_amounts,
        COUNT(*) FILTER (WHERE total_amount < 0) as negative_amounts,
        COUNT(*) FILTER (WHERE subscription_start_date IS NULL) as null_dates,
        COUNT(*) FILTER (WHERE subscription_start_date > CURRENT_DATE) as future_dates,
        COUNT(*) FILTER (WHERE subscription_deactivation_date < subscription_start_date) as invalid_date_ranges
    FROM {{ ref('stg_sales') }}
)
SELECT 
    total_records,
    unique_ids,
    total_records - unique_ids as duplicate_ids,
    null_ids,
    null_reference_ids,
    null_amounts,
    negative_amounts,
    null_dates,
    future_dates,
    invalid_date_ranges,
    ROUND(100.0 * (null_ids + null_amounts) / NULLIF(total_records, 0), 2) as critical_issue_percent,
    ROUND(100.0 * (total_records - null_ids - null_amounts - negative_amounts) / NULLIF(total_records, 0), 2) as data_quality_score,
    CURRENT_TIMESTAMP as checked_at
FROM metrics
