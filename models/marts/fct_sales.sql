{{ config(
    materialized='table',
    schema='raw_analytics'
) }}

WITH stg_sales AS (
    SELECT * FROM {{ ref('stg_sales') }}
)
SELECT 
    id,
    reference_id,
    
    COALESCE(country, 'N/A') as country,
    product_code,
    COALESCE(product_name, 'N/A') as product_name,
    COALESCE(sales_agent_name, 'N/A') as sales_agent_name,
    COALESCE(source, 'N/A') as source,
    COALESCE(campaign_name, 'N/A') as campaign_name,
    
    order_date_kyiv,
    return_date_kyiv,
    
    order_date_kyiv AT TIME ZONE 'UTC' as order_date_utc,
    return_date_kyiv AT TIME ZONE 'UTC' as return_date_utc,
    
    order_date_kyiv AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York' as order_date_ny,
    return_date_kyiv AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York' as return_date_ny,
    
    CASE 
        WHEN return_date_kyiv IS NOT NULL AND order_date_kyiv IS NOT NULL 
        THEN (return_date_kyiv - order_date_kyiv)
        ELSE NULL
    END as days_between_return_and_purchase,
    
    subscription_start_date,
    subscription_deactivation_date,
    subscription_duration_months,
    
    has_chargeback,
    has_refund,
    
    COALESCE(total_amount, 0) as total_amount,
    COALESCE(discount_amount, 0) as discount_amount,
    COALESCE(number_of_rebills, 0) as number_of_rebills,
    COALESCE(original_amount, 0) as original_amount,
    COALESCE(returned_amount, 0) as returned_amount,
    COALESCE(total_rebill_amount, 0) as total_rebill_amount,
    
    COALESCE(total_amount, 0) + COALESCE(total_rebill_amount, 0) - COALESCE(returned_amount, 0) as total_company_revenue,
    
    COALESCE(total_rebill_amount, 0) as rebill_revenue_only,
    
    created_at,
    CURRENT_TIMESTAMP as _loaded_at
    
FROM stg_sales
