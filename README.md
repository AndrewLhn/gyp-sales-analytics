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
