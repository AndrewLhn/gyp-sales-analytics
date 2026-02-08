cat > README.md << 'EOF'
# GYB Sales Analytics

Solution to the test task for sales analytics using dbt and PostgreSQL.

## 📊 Project Description

The project represents an ETL/ELT pipeline for analyzing company sales data.
Includes data loading, transformation, data mart creation, and analytical queries.

## 🎯 Completed Tasks

### 1. Creation of the `fct_sales` Data Mart
- Name of the sold product
- List of sales agents' names
- Country and campaign
- Sales source
- Company revenue considering rebills and refunds
- Revenue from rebills only
- Number of rebills
- Discount amount and refunds
- Dates in three time zones (Kyiv, UTC, New York)
- Difference in days between purchase and refund

### 2. Analytical Queries
- Monthly revenue growth percentage
- Agent performance ranking
- Agents with above-average discounts

### 3. Data Testing
- Data uniqueness and completeness validation
- Business rule verification

## 🛠 Technologies

- **Database:** PostgreSQL
- **ETL/ELT:** dbt (Data Build Tool)
- **Languages:** SQL, Python
- **Version Control:** Git

## 📁 Project Structure
├── models/          # dbt SQL models
├── analyses/        # Analytical queries
├── seeds/           # Source data
├── tests/           # Data tests
├── dbt_project.yml  # dbt configuration
└── profiles.yml     # Database configuration

## 🚀 Project Setup

1. Clone the repository
2. Install dependencies: `pip install dbt-postgres`
3. Configure PostgreSQL connection in `profiles.yml`
4. Load data: `dbt seed`
5. Run models: `dbt run`
6. Execute tests: `dbt test`
7. Run analyses: files in the `analyses/` folder

## 📈 Results

Detailed analysis results are available in the `analyses/` folder:
- `monthly_revenue_growth.sql` - revenue dynamics
- `agent_performance_ranking.sql` - agent performance
- `agents_above_avg_discount.sql` - discount analysis

echo "=== Финальная проверка задания ==="

echo -e "\n1. Проверка структуры витрины данных:"
PGPASSWORD=postgres psql -U postgres -d gyp_sales -h localhost -c "
SELECT 
    'raw_analytics.fct_sales содержит:' as check_item,
    COUNT(*)::text as count
FROM raw_analytics.fct_sales
UNION ALL
SELECT 
    'Уникальных продуктов:',
    COUNT(DISTINCT product_name)::text
FROM raw_analytics.fct_sales
UNION ALL
SELECT 
    'Уникальных агентов:',
    COUNT(DISTINCT sales_agent_name)::text
FROM raw_analytics.fct_sales
UNION ALL
SELECT 
    'Записей с N/A в стране:',
    COUNT(CASE WHEN country = 'N/A' THEN 1 END)::text
FROM raw_analytics.fct_sales
UNION ALL
SELECT 
    'Общий доход компании ($):',
    SUM(total_company_revenue)::numeric(10,2)::text
FROM raw_analytics.fct_sales
UNION ALL
SELECT 
    'Общая сумма скидок ($):',
    SUM(discount_amount)::numeric(10,2)::text
FROM raw_analytics.fct_sales;
"

echo -e "\n2. Проверка расчетных полей:"
PGPASSWORD=postgres psql -U postgres -d gyp_sales -h localhost -c "
SELECT 
    reference_id,
    product_name,
    sales_agent_name,
    total_amount::numeric(10,2),
    total_rebill_amount::numeric(10,2),
    returned_amount::numeric(10,2),
    total_company_revenue::numeric(10,2) as calculated_revenue,
    days_between_return_and_purchase
FROM raw_analytics.fct_sales
WHERE days_between_return_and_purchase IS NOT NULL
LIMIT 3;
"

echo -e "\n3. Проверка аналитических запросов (фрагменты):"
echo "=== Анализ 1: Рост дохода ==="
PGPASSWORD=postgres psql -U postgres -d gyp_sales -h localhost -c "
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', order_date_kyiv) as month,
        SUM(total_company_revenue) as monthly_revenue
    FROM raw_analytics.fct_sales
    WHERE order_date_kyiv IS NOT NULL
    GROUP BY DATE_TRUNC('month', order_date_kyiv)
)
SELECT 
    TO_CHAR(month, 'YYYY-MM') as year_month,
    monthly_revenue::numeric(10,2) as monthly_revenue
FROM monthly_revenue
ORDER BY month DESC
LIMIT 3;
"

echo -e "\n=== Анализ 2: Топ агентов ==="
PGPASSWORD=postgres psql -U postgres -d gyp_sales -h localhost -c "
SELECT 
    sales_agent_name,
    COUNT(*) as total_sales,
    SUM(total_company_revenue)::numeric(10,2) as total_revenue
FROM raw_analytics.fct_sales
WHERE sales_agent_name != 'N/A'
GROUP BY sales_agent_name
ORDER BY total_revenue DESC
LIMIT 3;
"
