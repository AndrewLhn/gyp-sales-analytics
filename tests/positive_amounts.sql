-- Проверка что суммы положительные
SELECT
    *
FROM {{ ref('stg_sales') }}
WHERE total_amount < 0
   OR discount_amount < 0
   OR original_amount < 0
