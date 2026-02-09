-- Проверка что дата начала подписки не в будущем
SELECT
    *
FROM {{ ref('stg_sales') }}
WHERE subscription_start_date > CURRENT_DATE
