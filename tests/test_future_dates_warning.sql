-- Этот тест не должен падать, только предупреждать
{{ config(severity='warn') }}

SELECT *
FROM {{ ref('stg_sales') }}
WHERE subscription_start_date > CURRENT_DATE
