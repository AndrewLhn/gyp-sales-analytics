import pandas as pd
import numpy as np
import sqlite3
import os
from datetime import datetime
import re

def fix_and_load():
    print("ИСПРАВЛЕНИЕ И ЗАГРУЗКА ДАННЫХ")
    print("=" * 70)
    
    input_file = "sales_data.csv"
    db_file = "gyp_sales.db"
    
    print(f"📁 Обработка файла: {input_file}")
    print(f"🗄️  База данных: {db_file}")
    
    # 1. Чтение файла напрямую с правильным разделителем
    print("\n1. Чтение файла...")
    
    try:
        # Читаем файл с разделителем ';'
        df = pd.read_csv(input_file, sep=';', encoding='utf-8')
        print(f"✅ Файл прочитан с encoding=utf-8")
    except:
        try:
            df = pd.read_csv(input_file, sep=';', encoding='latin-1')
            print(f"✅ Файл прочитан с encoding=latin-1")
        except Exception as e:
            print(f"❌ Ошибка чтения файла: {e}")
            return
    
    print(f"   Строк: {len(df)}, Колонок: {len(df.columns)}")
    print(f"   Колонки: {list(df.columns)[:10]}...")
    
    # Показываем первые строки
    print("\nПервые 3 строки данных:")
    print(df.head(3).to_string())
    
    # 2. Очистка данных
    print("\n2. Очистка данных...")
    
    # Удаляем возможные невидимые символы из названий колонок
    df.columns = [col.strip() for col in df.columns]
    
    # Заменяем пустые строки на NaN
    df = df.replace(['', ' ', 'NULL', 'null', 'NaN', 'nan'], np.nan)
    
    # Удаляем возможные пробелы в начале и конце строк
    df = df.map(lambda x: x.strip() if isinstance(x, str) else x)
    
    # Специальная обработка для конкретных колонок
    
    # 1. Колонка Country должна остаться текстом
    if 'Country' in df.columns:
        df['Country'] = df['Country'].astype(str)
    
    # 2. Обработка числовых колонок
    numeric_columns = [
        'Total Amount ($)', 'Discount Amount ($)', 'Number Of Rebills',
        'Original Amount ($)', 'Returned Amount ($)', 'Total Rebill Amount',
        'Subscription Duration Months'
    ]
    
    for col in numeric_columns:
        if col in df.columns:
            try:
                # Заменяем запятые на точки для десятичных разделителей
                df[col] = df[col].astype(str).str.replace(',', '.', regex=False)
                # Удаляем символы валюты и лишние символы
                df[col] = df[col].str.replace(r'[\$,€£¥]', '', regex=True)
                # Преобразуем в числовой формат
                df[col] = pd.to_numeric(df[col], errors='coerce')
                print(f"   Преобразована числовая колонка: {col}")
            except Exception as e:
                print(f"   Ошибка в колонке {col}: {e}")
    
    # 3. Обработка дат
    date_columns = [
        'Subscription Start Date', 'Subscription Deactivation Date',
        'Order Date Kyiv', 'Return Date Kyiv', 'Last Rebill Date Kyiv'
    ]
    
    # Сначала преобразуем русские названия месяцев
    month_dict = {
        'январь': 'January', 'февраль': 'February', 'март': 'March',
        'апрель': 'April', 'май': 'May', 'июнь': 'June',
        'июль': 'July', 'август': 'August', 'сентябрь': 'September',
        'октябрь': 'October', 'ноябрь': 'November', 'декабрь': 'December'
    }
    
    for col in date_columns:
        if col in df.columns:
            try:
                # Преобразуем русские названия месяцев
                df[col] = df[col].astype(str).apply(
                    lambda x: next((x.lower().replace(ru, en) for ru, en in month_dict.items() if ru in x.lower()), x)
                    if isinstance(x, str) else x
                )
                
                # Парсим даты
                df[col] = pd.to_datetime(df[col], errors='coerce')
                print(f"   Преобразована дата: {col}")
            except Exception as e:
                print(f"   Ошибка в колонке {col}: {e}")
    
    # 4. Логические колонки
    bool_columns = ['Has Chargeback', 'Has Refund']
    
    for col in bool_columns:
        if col in df.columns:
            try:
                df[col] = df[col].astype(str).str.lower()
                df[col] = df[col].isin(['true', '1', 'yes', 'да', 'y'])
                print(f"   Преобразована логическая колонка: {col}")
            except Exception as e:
                print(f"   Ошибка в колонке {col}: {e}")
    
    print(f"✅ Данные очищены")
    print(f"   Итоговый размер: {len(df)} строк, {len(df.columns)} колонок")
    
    # 3. Подключение к базе данных SQLite
    print("\n3. Подключение к базе данных...")
    
    try:
        # Подключаемся к базе данных
        conn = sqlite3.connect(db_file)
        cursor = conn.cursor()
        
        print(f"✅ Подключение к базе данных успешно: {db_file}")
        
        # 4. Создание таблицы с правильными типами данных
        print("\n4. Создание таблицы sales...")
        
        # Создаем новую таблицу с правильной структурой
        cursor.execute("DROP TABLE IF EXISTS sales")
        
        create_table_query = '''
        CREATE TABLE sales (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
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
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        '''
        
        cursor.execute(create_table_query)
        print("✅ Таблица sales создана")
        
        # 5. Загрузка данных в базу
        print("\n5. Загрузка данных в базу...")
        
        # Сопоставляем колонки DataFrame с колонками в базе
        column_mapping = {
            'Reference ID': 'reference_id',
            'Country': 'country',
            'Product Code': 'product_code',
            'Product Name': 'product_name',
            'Subscription Start Date': 'subscription_start_date',
            'Subscription Deactivation Date': 'subscription_deactivation_date',
            'Subscription Duration Months': 'subscription_duration_months',
            'Order Date Kyiv': 'order_date_kyiv',
            'Return Date Kyiv': 'return_date_kyiv',
            'Last Rebill Date Kyiv': 'last_rebill_date_kyiv',
            'Has Chargeback': 'has_chargeback',
            'Has Refund': 'has_refund',
            'Sales Agent Name': 'sales_agent_name',
            'Source': 'source',
            'Campaign Name': 'campaign_name',
            'Total Amount ($)': 'total_amount',
            'Discount Amount ($)': 'discount_amount',
            'Number Of Rebills': 'number_of_rebills',
            'Original Amount ($)': 'original_amount',
            'Returned Amount ($)': 'returned_amount',
            'Total Rebill Amount': 'total_rebill_amount'
        }
        
        # Переименовываем колонки
        df_db = df.rename(columns=column_mapping)
        
        # Оставляем только колонки, которые есть в таблице
        db_columns = list(column_mapping.values())
        df_db = df_db[[col for col in db_columns if col in df_db.columns]]
        
        # Конвертируем даты в строки для SQLite
        date_cols = ['subscription_start_date', 'subscription_deactivation_date', 
                    'order_date_kyiv', 'return_date_kyiv', 'last_rebill_date_kyiv']
        
        for col in date_cols:
            if col in df_db.columns:
                df_db[col] = pd.to_datetime(df_db[col]).dt.strftime('%Y-%m-%d')
        
        # Вставляем данные
        columns = ', '.join(df_db.columns)
        placeholders = ', '.join(['?' for _ in df_db.columns])
        insert_query = f"INSERT INTO sales ({columns}) VALUES ({placeholders})"
        
        # Преобразуем DataFrame в список кортежей
        data_tuples = [tuple(x) for x in df_db.to_numpy()]
        
        # Выполняем вставку
        cursor.executemany(insert_query, data_tuples)
        conn.commit()
        
        print(f"✅ Загружено {len(df_db)} записей в базу данных")
        
        # 6. Проверка загрузки
        print("\n6. Проверка загрузки...")
        
        # Считаем количество записей в таблице
        cursor.execute("SELECT COUNT(*) FROM sales")
        count = cursor.fetchone()[0]
        print(f"   Всего записей в таблице sales: {count}")
        
        # Показываем структуру таблицы
        cursor.execute("PRAGMA table_info(sales)")
        columns_info = cursor.fetchall()
        print(f"\n   Структура таблицы sales ({len(columns_info)} колонок):")
        for col in columns_info:
            print(f"   - {col[1]:25} ({col[2]:10})")
        
        # Показываем пример данных
        print(f"\n   Пример данных (первые 3 записи):")
        cursor.execute("""
            SELECT 
                id, reference_id, country, 
                product_name, total_amount, 
                subscription_start_date
            FROM sales 
            LIMIT 3
        """)
        rows = cursor.fetchall()
        for i, row in enumerate(rows):
            print(f"   Запись {i+1}: ID={row[0]}, Ref={row[1]}, Country={row[2]}, Product={row[3][:20]}, Amount={row[4]}, Date={row[5]}")
        
        # Проверяем типы данных
        print(f"\n   Проверка типов данных:")
        cursor.execute("""
            SELECT 
                COUNT(*) as total,
                COUNT(country) as country_not_null,
                COUNT(DISTINCT country) as unique_countries,
                MIN(total_amount) as min_amount,
                MAX(total_amount) as max_amount,
                AVG(total_amount) as avg_amount
            FROM sales
        """)
        stats = cursor.fetchone()
        print(f"   Всего записей: {stats[0]}")
        print(f"   Записей с указанной страной: {stats[1]}")
        print(f"   Уникальных стран: {stats[2]}")
        print(f"   Мин. сумма: {stats[3]:.2f}")
        print(f"   Макс. сумма: {stats[4]:.2f}")
        print(f"   Средняя сумма: {stats[5]:.2f}")
        
        # Закрываем соединение
        conn.close()
        print(f"\n✅ Процесс завершен успешно!")
        print(f"   Файл базы данных: {os.path.abspath(db_file)}")
        
    except Exception as e:
        print(f"❌ Ошибка при работе с базой данных: {str(e)}")
        import traceback
        traceback.print_exc()
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    fix_and_load()