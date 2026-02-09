-- Анализ 1: Розрахунок відсоткового зростання доходу від місяця до місяця
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', order_date_kyiv) as month,
        SUM(total_company_revenue) as monthly_revenue
    FROM {{ ref('fct_sales') }}
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
ORDER BY month DESC;
