WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', order_date_kyiv) as month,
        SUM(total_company_revenue) as monthly_revenue
    FROM raw_analytics.fct_sales
    WHERE order_date_kyiv IS NOT NULL
    GROUP BY DATE_TRUNC('month', order_date_kyiv)
),
revenue_with_growth AS (
    SELECT 
        month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (ORDER BY month) as prev_month_revenue
    FROM monthly_revenue
)
SELECT 
    TO_CHAR(month, 'YYYY-MM') as year_month,
    monthly_revenue::numeric(10,2) as monthly_revenue,
    prev_month_revenue::numeric(10,2) as prev_month_revenue,
    CASE 
        WHEN prev_month_revenue > 0 
        THEN ROUND(((monthly_revenue - prev_month_revenue) * 100.0 / prev_month_revenue)::numeric, 2)
        ELSE NULL
    END as revenue_growth_percent
FROM revenue_with_growth
ORDER BY month DESC;
