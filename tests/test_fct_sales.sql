-- Тесты для fct_sales

-- 1. Проверка что все записи из stg_sales попали в fct_sales
SELECT s.id
FROM {{ ref('stg_sales') }} s
LEFT JOIN {{ ref('fct_sales') }} f ON s.id = f.id
WHERE f.id IS NULL
