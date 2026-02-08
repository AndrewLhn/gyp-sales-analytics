WITH agent_stats AS (
    SELECT
        sales_agent_name,
        COUNT(DISTINCT referenceid) AS sales_count,
        SUM(company_revenue) AS total_revenue,
        AVG(company_revenue) AS avg_revenue_per_sale,
        AVG(discount_amount) AS avg_discount_per_sale
    FROM {{ ref('fct_sales') }}
    WHERE sales_agent_name != 'N/A'
    GROUP BY 1
),

ranked_agents AS (
    SELECT
        sales_agent_name,
        sales_count,
        total_revenue,
        ROUND(avg_revenue_per_sale::numeric, 2) AS avg_revenue_per_sale,
        ROUND(avg_discount_per_sale::numeric, 2) AS avg_discount_per_sale,
        RANK() OVER (ORDER BY total_revenue DESC) AS rank_position
    FROM agent_stats
)

SELECT * FROM ranked_agents
ORDER BY rank_position