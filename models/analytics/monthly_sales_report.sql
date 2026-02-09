{{ config(materialized='table') }}

SELECT 
    DATE_TRUNC('month', subscription_start_date) as month,
    country,
    product_name,
    COUNT(*) as total_subscriptions,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value,
    -- Универсальное решение работает для любого типа
    SUM(
        CASE 
            WHEN has_refund::text IN ('true', '1', 'yes', 't', 'TRUE') THEN 1
            WHEN has_refund::text IN ('false', '0', 'no', 'f', 'FALSE', '') THEN 0
            WHEN has_refund IS NULL THEN 0
            ELSE has_refund::integer  -- если уже число
        END
    ) as refund_count
FROM {{ ref('stg_sales') }}
GROUP BY 1, 2, 3
ORDER BY 1 DESC, 5 DESC
