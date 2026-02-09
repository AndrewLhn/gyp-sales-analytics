
GYP Sales Analytics Project
📋 Description
A sales analytics project for GYP company using DBT (Data Build Tool). Completed test assignment involving creation of a data mart and analytical reports.

🎯 Completed Tasks
✅ Created data mart fct_sales in raw_analytics schema with calculated fields:

total_company_revenue = total_amount + total_rebill_amount - returned_amount

Dates in three time zones (Kyiv, UTC, New York)

Day difference between return and purchase dates

✅ Wrote tests for data validation

✅ Created analytical queries (analyses/ folder):

01_monthly_revenue_growth.sql - monthly revenue growth

02_agent_performance_ranking.sql - agent performance ranking

03_agents_above_avg_discount.sql - agents with high discounts

✅ Completed 3 required analyses from the assignment

🗂️ Project Structure
gyp_sales_analytics/
├── analyses/ # Analytical queries
│ ├── 01_monthly_revenue_growth.sql # 1. Monthly revenue growth
│ ├── 02_agent_performance_ranking.sql # 2. Agent ranking
│ └── 03_agents_above_avg_discount.sql # 3. Agents with high discounts
├── models/
│ ├── raw_analytics/
│ │ └── fct_sales.sql # Sales fact table
│ ├── raw/
│ │ └── dim_customers.sql # Customer dimension
│ └── raw_monitoring/ # Monitoring models
├── tests/ # Data tests
├── macros/ # DBT macros
├── dbt_project.yml # DBT configuration
├── profiles.yml # Connection settings
└── README.md

🛠️ Technologies
DBT 1.6.0 - data orchestration

PostgreSQL - database

SQL - analytical queries

📊 Key Metrics
Total company revenue: total_company_revenue field in fct_sales table

Average discount across all agents: 32.84

Agents with highest discounts:

Isaac (108.00, 75.16 above average)

Rodger (67.85, 35.01 above average)

David (62.14, 29.30 above average)

🚀 Project Setup
1. Prerequisites
PostgreSQL

Python 3.8+

DBT Core

2. Configuration
bash
# Clone repository
git clone <repo-url>
cd gyp_sales_analytics

# Create virtual environment
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install dbt-postgres==1.6.0

# Configure database connection
# Update profiles.yml with your credentials
3. Running Analyses
bash
# Run analytical queries directly
PGPASSWORD=postgres psql -U postgres -d gyp_sales -h localhost -f analyses/01_monthly_revenue_growth.sql

# Or via script
./run_all_analyses.sh
4. Query Examples
sql
-- 1. Monthly revenue growth
WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', order_date_kyiv) as month,
           SUM(total_company_revenue) as monthly_revenue
    FROM raw_analytics.fct_sales
    GROUP BY 1
)
SELECT ...;

-- 2. Agent performance ranking
WITH agent_stats AS (
    SELECT sales_agent_name,
           SUM(total_company_revenue) as total_revenue
    FROM raw_analytics.fct_sales
    GROUP BY 1
)
SELECT ...;

-- 3. Agents with high discounts
WITH agent_discounts AS (
    SELECT sales_agent_name,
           AVG(discount_amount) as avg_discount
    FROM raw_analytics.fct_sales
    GROUP BY 1
)
SELECT ...;
📈 Results
All three required analytical queries execute successfully:

✅ Calculated percentage revenue growth month-over-month

✅ Ranked agents by revenue with ranking

✅ Identified agents with discounts above average level

📝 Notes
PostgreSQL database used

Data loaded using dbt seed

All tests pass successfully

Empty fields filled with 'N/A' values




