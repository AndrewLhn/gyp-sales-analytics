SELECT 
    COUNT(*) as negative_discounts
FROM {{ ref('fct_sales') }}
WHERE discount_amount < 0
HAVING COUNT(*) > 0
