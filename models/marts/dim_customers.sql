{{ config(materialized='table') }}

SELECT 
    reference_id,
    country,
    COUNT(*) as total_orders,
    SUM(total_amount) as lifetime_value,
    MIN(subscription_start_date) as first_order_date,
    MAX(subscription_start_date) as last_order_date
FROM {{ ref('stg_sales') }}
GROUP BY 1, 2