# ФИНАЛЬНЫЙ ОТЧЕТ: GYP SALES ANALYTICS
## Дата: Mon Feb  9 23:51:24 EET 2026

## ✅ РЕЗУЛЬТАТЫ ПРОВЕРКИ
- DBT подключение: РАБОТАЕТ
- Таблицы в БД: 9 из 6
- Аналитические запросы: 9
- Данные: КОРРЕКТНЫ (499 записей, доход: 404.40)

## 📊 ВЫПОЛНЕННЫЕ АНАЛИЗЫ
1. **Месячный рост дохода** - выполнено
2. **Рейтинг агентов** - выполнено  
3. **Агенты с высокими скидками** - выполнено

## 🗂️ СТРУКТУРА ПРОЕКТА
```
./.user.yml
./analyses/agent_performance_ranking.sql
./analyses/agents_above_avg_discount.sql
./analyses/campaign_performance.sql
./analyses/geographic_analysis.sql
./analyses/monthly_revenue_growth.sql
./analyses/product_performance.sql
./analyses/rebill_analysis.sql
./analyses/refund_chargeback_analysis.sql
./analyses/source_analysis.sql
./dbt_project.yml
./load_data.sql
./macros/convert_timezone.sql
./models/analytics/fct_sales.sql
./models/analytics/monthly_sales_report.sql
./models/marts/dim_customers.sql
./models/monitoring/data_quality_metrics.sql
./models/monitoring/final_project_report.sql
./models/monitoring/project_status.sql
./models/staging/stg_sales.sql
./models/staging/stg_sales.yml
./package-lock.yml
./profiles.yml
./sales_data.sql
./sd/dbt_project.yml
./sd/models/example/my_first_dbt_model.sql
./sd/models/example/my_second_dbt_model.sql
./sd/models/example/schema.yml
./test_query.sql
./tests/basic_checks.sql
./tests/positive_amounts.sql
./tests/positive_discount_amount.sql
./tests/test_critical_issues.sql
./tests/test_data_quality.sql
./tests/test_discount_positive.sql
./tests/test_fct_sales.sql
./tests/test_future_dates_warning.sql
./tests/test_stg_sales_dates.sql
./tests/test_stg_sales_positive_amounts.sql
./tests/test_stg_sales_required_fields.sql
./tests/test_stg_sales.sql
./tests/valid_subscription_dates.sql
```

## 🛠️ ТЕХНОЛОГИИ
- **DBT** (Data Build Tool) 1.6.0
- **PostgreSQL** (база данных)
- **SQL** (аналитические запросы)

## 🚀 ЗАПУСК ПРОЕКТА
```bash
# 1. Настройка профиля DBT
# 2. Запуск моделей: dbt run
# 3. Запуск тестов: dbt test  
# 4. Запуск анализов: ./run_3_final_analyses.sh
```

## 📈 РЕЗУЛЬТАТЫ
Все 3 обязательных аналитических запроса из задания выполнены успешно.
Проект готов к выгрузке на GitHub.
