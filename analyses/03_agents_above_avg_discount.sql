-- Анализ 3: Визначте агентів, які надають знижки вище загального середнього рівня
WITH agent_discounts AS (
    SELECT 
        sales_agent_name,
        COUNT(*) as total_sales,
        AVG(discount_amount) as avg_discount_per_sale_calc
    FROM {{ ref('fct_sales') }}
    WHERE sales_agent_name != 'N/A'
    GROUP BY sales_agent_name
),
agent_discounts_numeric AS (
    SELECT 
        sales_agent_name,
        total_sales,
        CAST(avg_discount_per_sale_calc AS numeric(10,2)) as avg_discount_per_sale
    FROM agent_discounts
),
overall_avg AS (
    SELECT CAST(AVG(discount_amount) AS numeric(10,2)) as overall_avg_discount
    FROM {{ ref('fct_sales') }}
    WHERE sales_agent_name != 'N/A'
)
SELECT 
    ad.sales_agent_name,
    ad.total_sales,
    ad.avg_discount_per_sale,
    oa.overall_avg_discount,
    (ad.avg_discount_per_sale - oa.overall_avg_discount) as discount_diff_from_avg
FROM agent_discounts_numeric ad
CROSS JOIN overall_avg oa
WHERE ad.avg_discount_per_sale > oa.overall_avg_discount
ORDER BY discount_diff_from_avg DESC;
