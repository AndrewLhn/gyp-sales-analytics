-- Проверка что разница дней от 0 до 365
SELECT 
    COUNT(*) as invalid_days
FROM raw_analytics.fct_sales
WHERE days_between_return_and_purchase IS NOT NULL
  AND (days_between_return_and_purchase < 0 OR days_between_return_and_purchase > 365)
HAVING COUNT(*) > 0
