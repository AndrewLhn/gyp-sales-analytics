#!/bin/bash
echo "📊 ТЕСТИРОВАНИЕ АНАЛИТИЧЕСКИХ ЗАПРОСОВ"
echo "====================================="

# 1. Месячный рост дохода
echo -e "\n1. 📈 МЕСЯЧНЫЙ РОСТ ДОХОДА"
echo "---------------------------"
PGPASSWORD=postgres psql -U postgres -d gyp_sales -h localhost -c "
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', order_date_kyiv) as month,
        SUM(total_amount + total_rebill_amount - returned_amount) as monthly_revenue
    FROM raw_analytics.fct_sales
    WHERE order_date_kyiv IS NOT NULL
    GROUP BY DATE_TRUNC('month', order_date_kyiv)
),
monthly_revenue_numeric AS (
    SELECT 
        month,
        CAST(monthly_revenue AS numeric(10,2)) as monthly_revenue
    FROM monthly_revenue
)
SELECT 
    TO_CHAR(month, 'YYYY-MM') as year_month,
    monthly_revenue,
    COALESCE(
        ROUND(
            100.0 * (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY month)) / 
            NULLIF(LAG(monthly_revenue) OVER (ORDER BY month), 0), 
            2
        ),
        0
    ) as month_over_month_growth_percent
FROM monthly_revenue_numeric
ORDER BY month DESC
LIMIT 6;"

# 2. Рейтинг агентов
echo -e "\n2. 🥇 РЕЙТИНГ АГЕНТОВ (ТОП-10)"
echo "-----------------------------"
PGPASSWORD=postgres psql -U postgres -d gyp_sales -h localhost -c "
SELECT 
    sales_agent_name,
    COUNT(*) as total_sales,
    CAST(SUM(total_amount + total_rebill_amount - returned_amount) AS numeric(10,2)) as total_revenue,
    CAST(AVG(total_amount + total_rebill_amount - returned_amount) AS numeric(10,2)) as avg_revenue_per_sale,
    CAST(AVG(discount_amount) AS numeric(10,2)) as avg_discount_per_sale
FROM raw_analytics.fct_sales
WHERE sales_agent_name != 'N/A'
GROUP BY sales_agent_name
ORDER BY total_revenue DESC
LIMIT 10;"

# 3. Агенты с высокими скидками
echo -e "\n3. �� АГЕНТЫ С ВЫСОКИМИ СКИДКАМИ"
echo "---------------------------------"
PGPASSWORD=postgres psql -U postgres -d gyp_sales -h localhost -c "
WITH agent_discounts AS (
    SELECT 
        sales_agent_name,
        COUNT(*) as total_sales,
        AVG(discount_amount) as avg_discount_per_sale_calc
    FROM raw_analytics.fct_sales
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
    FROM raw_analytics.fct_sales
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
ORDER BY discount_diff_from_avg DESC
LIMIT 10;"

echo -e "\n✅ ВСЕ 3 АНАЛИТИЧЕСКИХ ЗАПРОСА ВЫПОЛНЕНЫ УСПЕШНО!"
