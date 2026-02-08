# direct_postgres_load.py
import psycopg2
import csv
import sys

print("ПРЯМАЯ ЗАГРУЗКА В POSTGRESQL")

# 1. Сначала прочитаем CSV
csv_file = 'seeds/sales_data.csv'
try:
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        rows = list(reader)
        
    print(f"✅ CSV прочитан: {len(rows)} строк")
    if rows:
        print(f"   Заголовок: {rows[0]}")
        print(f"   Колонок в заголовке: {len(rows[0])}")
        
except Exception as e:
    print(f"❌ Ошибка чтения CSV: {e}")
    sys.exit(1)

# 2. Подключимся к PostgreSQL
try:
    conn = psycopg2.connect(
        host="localhost",
        database="sales_analytics",
        user="postgres",
        password=""
    )
    cursor = conn.cursor()
    print("✅ Подключение к PostgreSQL успешно")
    
except Exception as e:
    print(f"❌ Ошибка подключения: {e}")
    sys.exit(1)

# 3. Создадим таблицу
try:
    cursor.execute("DROP TABLE IF EXISTS sales_data_direct;")
    
    create_table_sql = """
    CREATE TABLE sales_data_direct (
        "Reference ID" TEXT,
        "Country" TEXT,
        "Product Code" TEXT,
        "Product Name" TEXT,
        "Subscription Start Date" TEXT,
        "Subscription Deactivation Date" TEXT,
        "Subscription Duration Months" INTEGER,
        "Order Date Kyiv" TEXT,
        "Return Date Kyiv" TEXT,
        "Last Rebill Date Kyiv" TEXT,
        "Has Chargeback" TEXT,
        "Has Refund" TEXT,
        "Sales Agent Name" TEXT,
        "Source" TEXT,
        "Campaign Name" TEXT,
        "Total Amount ($)" NUMERIC,
        "Discount Amount ($)" NUMERIC,
        "Number Of Rebills" INTEGER,
        "Original Amount ($)" NUMERIC,
        "Returned Amount ($)" NUMERIC,
        "Total Rebill Amount" NUMERIC
    );
    """
    cursor.execute(create_table_sql)
    print("✅ Таблица создана")
    
except Exception as e:
    print(f"❌ Ошибка создания таблицы: {e}")
    conn.close()
    sys.exit(1)

# 4. Вставим данные (кроме заголовка)
try:
    insert_sql = """
    INSERT INTO sales_data_direct VALUES (
        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
    )
    """
    
    # Пропускаем заголовок
    for row in rows[1:]:
        if len(row) == 21:
            cursor.execute(insert_sql, row)
        else:
            print(f"⚠️  Пропущена строка с {len(row)} колонками вместо 21")
    
    conn.commit()
    print(f"✅ Данные вставлены: {len(rows)-1} строк")
    
    # Проверим
    cursor.execute("SELECT COUNT(*) FROM sales_data_direct;")
    count = cursor.fetchone()[0]
    print(f"✅ Проверка: {count} строк в таблице")
    
except Exception as e:
    print(f"❌ Ошибка вставки данных: {e}")
    conn.rollback()
finally:
    cursor.close()
    conn.close()