SELECT 
    COUNT(*) as negative_discounts
FROM raw_analytics.fct_sales
WHERE discount_amount < 0
HAVING COUNT(*) > 0
