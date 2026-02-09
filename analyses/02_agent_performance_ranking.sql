-- Анализ 2: Для кожного агента визначте його середній дохід, к-ть продажів, 
-- а також середнє значення запропонованих знижок на кожну покупку.
-- Посортуйте по загальній сумі дохідності, та розставте рангові місця
WITH agent_stats AS (
    SELECT 
        sales_agent_name,
        COUNT(*) as total_sales,
        SUM(total_company_revenue) as total_revenue_calc,
        AVG(total_company_revenue) as avg_revenue_per_sale_calc,
        AVG(discount_amount) as avg_discount_per_sale_calc
    FROM {{ ref('fct_sales') }}
    WHERE sales_agent_name != 'N/A'
    GROUP BY sales_agent_name
),
agent_stats_numeric AS (
    SELECT 
        sales_agent_name,
        total_sales,
        CAST(total_revenue_calc AS numeric(10,2)) as total_revenue,
        CAST(avg_revenue_per_sale_calc AS numeric(10,2)) as avg_revenue_per_sale,
        CAST(avg_discount_per_sale_calc AS numeric(10,2)) as avg_discount_per_sale
    FROM agent_stats
),
ranked_agents AS (
    SELECT 
        sales_agent_name,
        total_sales,
        total_revenue,
        avg_revenue_per_sale,
        avg_discount_per_sale,
        ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as agent_rank
    FROM agent_stats_numeric
)
SELECT * FROM ranked_agents
ORDER BY agent_rank;
