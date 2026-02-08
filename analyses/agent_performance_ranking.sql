WITH agent_stats AS (
    SELECT 
        sales_agent_name,
        COUNT(*) as total_sales,
        SUM(total_company_revenue) as total_revenue,
        ROUND(AVG(total_company_revenue), 2) as avg_revenue_per_sale,
        ROUND(AVG(discount_amount), 2) as avg_discount_per_sale,
        SUM(total_company_revenue) - SUM(discount_amount) as net_revenue
    FROM analytics.fct_sales
    WHERE sales_agent_name != 'N/A'
    GROUP BY sales_agent_name
),
ranked_agents AS (
    SELECT 
        sales_agent_name,
        total_sales,
        total_revenue,
        avg_revenue_per_sale,
        avg_discount_per_sale,
        net_revenue,
        ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as rank_by_revenue,
        ROW_NUMBER() OVER (ORDER BY total_sales DESC) as rank_by_sales,
        ROW_NUMBER() OVER (ORDER BY net_revenue DESC) as rank_by_net_revenue
    FROM agent_stats
)
SELECT * FROM ranked_agents
ORDER BY rank_by_revenue;
