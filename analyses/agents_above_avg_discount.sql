WITH discount_stats AS (
    SELECT 
        AVG(discount_amount) as avg_discount_all,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY discount_amount) as median_discount
    FROM analytics.fct_sales
    WHERE discount_amount > 0
),
agent_discounts AS (
    SELECT 
        sales_agent_name,
        COUNT(*) as total_sales,
        ROUND(AVG(discount_amount), 2) as avg_discount,
        SUM(discount_amount) as total_discount_given
    FROM analytics.fct_sales
    WHERE sales_agent_name != 'N/A'
    GROUP BY sales_agent_name
)
SELECT 
    ad.sales_agent_name,
    ad.total_sales,
    ad.avg_discount,
    ad.total_discount_given,
    ds.avg_discount_all as company_avg_discount,
    CASE 
        WHEN ad.avg_discount > ds.avg_discount_all THEN 'ABOVE_AVERAGE'
        WHEN ad.avg_discount = ds.avg_discount_all THEN 'AVERAGE'
        ELSE 'BELOW_AVERAGE'
    END as discount_category
FROM agent_discounts ad
CROSS JOIN discount_stats ds
WHERE ad.avg_discount > ds.avg_discount_all
ORDER BY ad.avg_discount DESC;
