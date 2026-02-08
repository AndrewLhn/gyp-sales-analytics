WITH agent_stats AS (
    SELECT 
        sales_agent_name,
        COUNT(*) as total_sales,
        SUM(total_company_revenue) as total_revenue,
        AVG(total_company_revenue)::numeric(10,2) as avg_revenue_per_sale,
        AVG(discount_amount)::numeric(10,2) as avg_discount_per_sale
    FROM raw_analytics.fct_sales
    WHERE sales_agent_name != 'N/A'
    GROUP BY sales_agent_name
),
ranked_agents AS (
    SELECT 
        sales_agent_name,
        total_sales,
        total_revenue::numeric(10,2) as total_revenue,
        avg_revenue_per_sale,
        avg_discount_per_sale,
        ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as rank_by_revenue
    FROM agent_stats
)
SELECT * FROM ranked_agents
ORDER BY rank_by_revenue;
