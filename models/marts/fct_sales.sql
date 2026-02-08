{{ config(
    materialized='table',
    schema='analytics'
) }}

WITH stg_sales AS (
    SELECT 
        id,
        reference_id,
        COALESCE(country, 'N/A') as country,
        product_code,
        COALESCE(product_name, 'N/A') as product_name,
        subscription_start_date,
        subscription_deactivation_date,
        subscription_duration_months,
        order_date_kyiv,
        return_date_kyiv,
        last_rebill_date_kyiv,
        COALESCE(has_chargeback, FALSE) as has_chargeback,
        COALESCE(has_refund, FALSE) as has_refund,
        COALESCE(sales_agent_name, 'N/A') as sales_agent_name,
        COALESCE(source, 'N/A') as source,
        COALESCE(campaign_name, 'N/A') as campaign_name,
        COALESCE(total_amount, 0) as total_amount,
        COALESCE(discount_amount, 0) as discount_amount,
        COALESCE(number_of_rebills, 0) as number_of_rebills,
        COALESCE(original_amount, 0) as original_amount,
        COALESCE(returned_amount, 0) as returned_amount,
        COALESCE(total_rebill_amount, 0) as total_rebill_amount,
        created_at,
        CURRENT_TIMESTAMP as _loaded_at
    FROM {{ ref('stg_sales') }}
)
SELECT 
    -- Идентификаторы
    id,
    reference_id,
    
    -- Измерения
    country,
    product_code,
    product_name,
    sales_agent_name,
    source,
    campaign_name,
    
    -- Даты в разных часовых поясах
    -- Киев (исходный)
    order_date_kyiv as order_date_kyiv,
    return_date_kyiv as return_date_kyiv,
    
    -- UTC (предполагаем, что Киев = UTC+2 зимой, UTC+3 летой)
    order_date_kyiv AT TIME ZONE 'UTC' as order_date_utc,
    return_date_kyiv AT TIME ZONE 'UTC' as return_date_utc,
    
    -- Нью-Йорк (EST = UTC-5)
    order_date_kyiv AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York' as order_date_ny,
    return_date_kyiv AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York' as return_date_ny,
    
    -- Разница дней между покупкой и возвратом
    CASE 
        WHEN return_date_kyiv IS NOT NULL AND order_date_kyiv IS NOT NULL 
        THEN (return_date_kyiv - order_date_kyiv)
        ELSE NULL
    END as days_between_return_and_purchase,
    
    -- Подписка
    subscription_start_date,
    subscription_deactivation_date,
    subscription_duration_months,
    
    -- Флаги
    has_chargeback,
    has_refund,
    
    -- Финансовые метрики
    total_amount,
    discount_amount,
    number_of_rebills,
    original_amount,
    returned_amount,
    total_rebill_amount,
    
    -- Расчетные поля
    -- Общий доход с учетом ребиллов и возвратов
    total_amount + total_rebill_amount - returned_amount as total_company_revenue,
    
    -- Доход только от ребиллов
    total_rebill_amount as rebill_revenue_only,
    
    -- Метаданные
    created_at,
    _loaded_at
    
FROM stg_sales
