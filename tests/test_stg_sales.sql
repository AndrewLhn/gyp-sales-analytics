-- Тесты для stg_sales - каждый тест в отдельном файле лучше

-- Проверка уникальности ID
SELECT 
    id,
    COUNT(*) as duplicate_count
FROM {{ ref('stg_sales') }}
GROUP BY id
HAVING COUNT(*) > 1
