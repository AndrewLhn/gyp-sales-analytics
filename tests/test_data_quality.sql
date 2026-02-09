-- Тесты качества данных

-- 1. Уникальность ID (критично)
SELECT 
    id,
    COUNT(*) as duplicate_count
FROM {{ ref('stg_sales') }}
GROUP BY id
HAVING COUNT(*) > 1

-- 2. Отрицательные суммы (ошибка)
UNION ALL
SELECT 
    id,
    -1 as duplicate_count  -- маркер для другой проверки
FROM {{ ref('stg_sales') }}
WHERE total_amount < 0

-- 3. Отсутствие ID (критично)
UNION ALL
SELECT 
    NULL as id,
    -2 as duplicate_count
FROM {{ ref('stg_sales') }}
WHERE id IS NULL

-- 4. Отсутствие суммы (критично)
UNION ALL
SELECT 
    NULL as id,
    -3 as duplicate_count
FROM {{ ref('stg_sales') }}
WHERE total_amount IS NULL
