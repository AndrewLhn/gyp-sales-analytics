import psycopg2
import sqlite3
import pandas as pd
import numpy as np
import os
from datetime import datetime

def load_to_postgres():
    print("ЗАГРУЗКА ДАННЫХ В POSTGRESQL")
    print("=" * 60)
    
    # 1. Подключение к SQLite
    print("1. Подключение к SQLite...")
    sqlite_conn = sqlite3.connect('gyp_sales.db')
    
    # Читаем данные из SQLite
    df = pd.read_sql_query("SELECT * FROM sales", sqlite_conn)
    print(f"   Прочитано {len(df)} записей из SQLite")
    
    # 2. Преобразование данных
    print("2. Преобразование данных...")
    
    # Заменяем NaN на None для всех колонок
    df = df.replace({np.nan: None})
    
    # Преобразуем даты из строк в datetime объекты
    date_columns = [
        'subscription_start_date', 'subscription_deactivation_date',
        'order_date_kyiv', 'return_date_kyiv', 'last_rebill_date_kyiv',
        'created_at'
    ]
    
    for col in date_columns:
        if col in df.columns:
            try:
                df[col] = pd.to_datetime(df[col], errors='coerce')
                print(f"   Преобразована дата: {col}")
            except Exception as e:
                print(f"   Ошибка в колонке {col}: {e}")
    
    # Преобразуем булевы значения
    bool_columns = ['has_chargeback', 'has_refund']
    for col in bool_columns:
        if col in df.columns:
            df[col] = df[col].astype('bool', errors='ignore')
    
    print(f"✅ Данные преобразованы")
    
    # 3. Подключение к PostgreSQL
    print("3. Подключение к PostgreSQL...")
    
    # Параметры подключения к PostgreSQL (как в profiles.yml)
    pg_params = {
        'host': 'localhost',
        'database': 'gyp_sales',
        'user': 'postgres',
        'password': 'postgres',
        'port': 5432
    }
    
    try:
        pg_conn = psycopg2.connect(**pg_params)
        pg_conn.autocommit = False
        pg_cursor = pg_conn.cursor()
        print("✅ Подключение к PostgreSQL успешно")
        
        # 4. Создание схемы raw если не существует
        print("4. Создание схемы raw...")
        pg_cursor.execute("CREATE SCHEMA IF NOT EXISTS raw;")
        pg_conn.commit()
        print("✅ Схема raw создана или уже существует")
        
        # 5. Создание таблицы в схеме raw
        print("5. Создание таблицы raw.sales...")
        
        create_table_sql = '''
        DROP TABLE IF EXISTS raw.sales;
        
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
        '''
        
        pg_cursor.execute(create_table_sql)
        pg_conn.commit()
        print("✅ Таблица raw.sales создана")
        
        # 6. Загрузка данных
        print("6. Загрузка данных в PostgreSQL...")
        
        # Подготавливаем данные для вставки
        data_tuples = []
        for _, row in df.iterrows():
            # Преобразуем даты в строки для PostgreSQL
            row_tuple = []
            for val in row:
                if isinstance(val, pd.Timestamp):
                    row_tuple.append(val.strftime('%Y-%m-%d') if pd.notna(val) else None)
                elif pd.isna(val):
                    row_tuple.append(None)
                else:
                    row_tuple.append(val)
            data_tuples.append(tuple(row_tuple))
        
        # SQL для вставки
        insert_sql = '''
        INSERT INTO raw.sales VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 
                                 %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 
                                 %s, %s, %s)
        '''
        
        # Выполняем вставку
        pg_cursor.executemany(insert_sql, data_tuples)
        pg_conn.commit()
        
        print(f"✅ Загружено {len(df)} записей в PostgreSQL")
        
        # 7. Проверка
        print("7. Проверка загрузки...")
        pg_cursor.execute("SELECT COUNT(*) FROM raw.sales")
        count = pg_cursor.fetchone()[0]
        print(f"   Всего записей в raw.sales: {count}")
        
        # Покажем несколько записей
        pg_cursor.execute("""
            SELECT 
                id, reference_id, country, 
                product_name, total_amount, 
                subscription_start_date
            FROM raw.sales 
            LIMIT 3
        """)
        rows = pg_cursor.fetchall()
        print(f"\n   Пример данных (первые 3 записи):")
        for i, row in enumerate(rows):
            print(f"   Запись {i+1}: ID={row[0]}, Ref={row[1]}, Country={row[2]}, Product={row[3][:20]}, Amount={row[4]}, Date={row[5]}")
        
        # Закрываем соединения
        pg_cursor.close()
        pg_conn.close()
        sqlite_conn.close()
        
        print("\n✅ Процесс завершен успешно!")
        print(f"   Данные загружены в схему: raw")
        print(f"   Таблица: sales")
        print(f"   Записей: {count}")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")
        import traceback
        traceback.print_exc()
        if 'pg_conn' in locals():
            pg_conn.rollback()
            pg_conn.close()
        sqlite_conn.close()

if __name__ == "__main__":
    load_to_postgres()
