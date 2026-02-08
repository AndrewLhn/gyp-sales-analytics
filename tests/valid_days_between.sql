SELECT 
    COUNT(*) as invalid_days
FROM {{ ref('fct_sales') }}
WHERE days_between_return_and_purchase < 0 
   OR days_between_return_and_purchase > 365
HAVING COUNT(*) > 0
