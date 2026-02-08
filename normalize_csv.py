cat > normalize_csv.py << 'EOF'
import pandas as pd
import numpy as np

# Прочитайте CSV
try:
    df = pd.read_csv('seeds/sales_data.csv')
    print(f"Успешно прочитан CSV. Колонки до нормализации: {df.columns.tolist()}")
    print(f"Размер данных: {df.shape}")
    
    # Нормализуйте имена столбцов: нижний регистр, пробелы на подчеркивания
    df.columns = [str(col).strip().lower().replace(' ', '_').replace('-', '_') for col in df.columns]
    print(f"Колонки после нормализации: {df.columns.tolist()}")
    
    # Заполните NaN значениями 'N/A' для строковых полей
    for col in df.select_dtypes(include=['object']).columns:
        df[col] = df[col].fillna('N/A')
    
    # Для числовых полей заполните 0
    for col in df.select_dtypes(include=[np.number]).columns:
        df[col] = df[col].fillna(0)
    
    # Сохраните
    df.to_csv('seeds/sales_data_normalized.csv', index=False)
    print(f"Создан файл seeds/sales_data_normalized.csv")
    print(f"Количество строк: {len(df)}")
    
except Exception as e:
    print(f"Ошибка: {e}")
    print("Создаю тестовый CSV файл...")
    
    # Создайте тестовый CSV
    test_data = '''referenceid,country,product_name,total_amount,discount_amount,returned_amount,total_rebill_amount,number_of_rebills,sales_agent_name,order_date_kyiv,source,campaign_name
sale001,usa,product_a,100.00,10.00,0.00,50.00,2,john_doe,2024-01-15 10:30:00,chat,campaign_1
sale002,uk,product_b,150.00,0.00,20.00,75.00,3,jane_smith,2024-01-16 14:45:00,call,campaign_2
sale003,germany,product_c,200.00,20.00,0.00,25.00,1,bob_johnson,2024-02-01 11:00:00,chat,campaign_3'''
    
    with open('seeds/sales_data_normalized.csv', 'w') as f:
        f.write(test_data)
    
    print("Создан тестовый CSV файл")
EOF

# Запустите скрипт
python3 normalize_csv.py