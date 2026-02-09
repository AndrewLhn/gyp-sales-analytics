-- Только критически важные поля должны быть NOT NULL
SELECT *
FROM {{ ref('stg_sales') }}
WHERE id IS NULL  -- ID всегда должен быть
   OR total_amount IS NULL  -- Сумма всегда должна быть
