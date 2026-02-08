WITH agent_discounts AS (
    SELECT
        sales_agent_name,
        AVG(discount_amount) AS avg_discount
    FROM {{ ref('fct_sales') }}
    WHERE sales_agent_name != 'N/A'
    GROUP BY 1
),

overall_avg AS (
    SELECT AVG(discount_amount) AS overall_avg_discount
    FROM {{ ref('fct_sales') }}
)

SELECT
    ad.sales_agent_name,
    ROUND(ad.avg_discount::numeric, 2) AS agent_avg_discount,
    ROUND(oa.overall_avg_discount::numeric, 2) AS overall_avg_discount
FROM agent_discounts ad
CROSS JOIN overall_avg oa
WHERE ad.avg_discount > oa.overall_avg_discount
ORDER BY ad.avg_discount DESC