-- Только критические проблемы
SELECT *
FROM {{ ref('stg_sales') }}
WHERE id IS NULL  -- Без ID данные бесполезны
   OR total_amount IS NULL  -- Без суммы тоже
   OR total_amount < 0  -- Отрицательные суммы - ошибка
