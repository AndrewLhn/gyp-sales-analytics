-- Умная проверка дат: игнорируем небольшие расхождения, ловим только явные ошибки
SELECT *
FROM {{ ref('stg_sales') }}
WHERE 
    -- Явная ошибка: дата начала в далеком будущем (> 1 года)
    subscription_start_date > (CURRENT_DATE + INTERVAL '1 year')
    
    -- Логическая ошибка: отмена раньше начала
    OR (subscription_deactivation_date IS NOT NULL 
        AND subscription_deactivation_date < subscription_start_date)
        
    -- Явная ошибка: отмена в далеком будущем (> 2 года)
    OR subscription_deactivation_date > (CURRENT_DATE + INTERVAL '2 years')
    
    -- Историческая ошибка: даты из далекого прошлого (< 2000 год)
    OR subscription_start_date < '2000-01-01'
    OR (subscription_deactivation_date IS NOT NULL 
        AND subscription_deactivation_date < '2000-01-01')
