WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', order_date_kyiv) as month,
        SUM(total_company_revenue) as monthly_revenue
    FROM analytics.fct_sales
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
    monthly_revenue,
    prev_month_revenue,
    ROUND(
        CASE 
            WHEN prev_month_revenue > 0 
            THEN (monthly_revenue - prev_month_revenue) * 100.0 / prev_month_revenue
            ELSE NULL
        END, 2
    ) as revenue_growth_percent
FROM revenue_with_growth
ORDER BY month DESC;
