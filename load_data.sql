-- Создаем схему raw если не существует
CREATE SCHEMA IF NOT EXISTS raw;

-- Удаляем таблицу если существует
DROP TABLE IF EXISTS raw.sales;

-- Создаем таблицу
CREATE TABLE raw.sales (
    id INTEGER PRIMARY KEY,
    reference_id TEXT,
    country TEXT,
    product_code TEXT,
    product_name TEXT,
    subscription_start_date DATE,
    subscription_deactivation_date DATE,
    subscription_duration_months REAL,
    order_date_kyiv DATE,
    return_date_kyiv DATE,
    last_rebill_date_kyiv DATE,
    has_chargeback BOOLEAN,
    has_refund BOOLEAN,
    sales_agent_name TEXT,
    source TEXT,
    campaign_name TEXT,
    total_amount REAL,
    discount_amount REAL,
    number_of_rebills INTEGER,
    original_amount REAL,
    returned_amount REAL,
    total_rebill_amount REAL,
    created_at TIMESTAMP
);

-- Копируем данные из CSV
\copy raw.sales FROM 'sales_data.csv' WITH CSV HEADER;

-- Проверяем
SELECT COUNT(*) as total_records FROM raw.sales;
SELECT '✅ Данные загружены в raw.sales' as status;
