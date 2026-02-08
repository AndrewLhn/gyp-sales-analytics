# create_perfect_csv.py
import csv

print("СОЗДАНИЕ ИДЕАЛЬНОГО CSV ФАЙЛА")
print("="*70)

# 1. Создадим идеальный заголовок
header = [
    "Reference ID", "Country", "Product Code", "Product Name", 
    "Subscription Start Date", "Subscription Deactivation Date", 
    "Subscription Duration Months", "Order Date Kyiv", "Return Date Kyiv", 
    "Last Rebill Date Kyiv", "Has Chargeback", "Has Refund", 
    "Sales Agent Name", "Source", "Campaign Name", "Total Amount ($)", 
    "Discount Amount ($)", "Number Of Rebills", "Original Amount ($)", 
    "Returned Amount ($)", "Total Rebill Amount"
]

print(f"Заголовок: {len(header)} колонок")

# 2. Прочитаем первую строку данных из оригинального файла
with open('seeds/sales_data.csv', 'r', encoding='utf-8-sig') as f:
    lines = f.readlines()

print(f"\nВсего строк в оригинале: {len(lines)}")

if len(lines) > 1:
    # Возьмем вторую строку (первая - заголовок)
    data_line = lines[1].strip()
    print(f"Первая строка данных (первые 100 символов): {data_line[:100]}")
    
    # Разделим по запятой
    parts = data_line.split(',')
    print(f"Разделено на {len(parts)} частей")
    
    # Если частей меньше 21, значит разделитель не запятая
    if len(parts) < 21:
        print("⚠️  ВНИМАНИЕ: Разделитель НЕ ЗАПЯТАЯ!")
        print("Пробую другие разделители...")
        
        for delimiter in [';', '\t', '|']:
            parts = data_line.split(delimiter)
            print(f"  Разделитель '{delimiter}': {len(parts)} частей")
            
            if len(parts) == 21:
                print(f"  ✅ НАЙДЕН ПРАВИЛЬНЫЙ РАЗДЕЛИТЕЛЬ: '{delimiter}'")
                break

# 3. Создадим идеальный CSV
output_file = 'seeds/sales_data_PERFECT.csv'
print(f"\nСоздаю идеальный файл: {output_file}")

with open(output_file, 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    
    # Записываем заголовок
    writer.writerow(header)
    
    # Добавляем тестовую строку
    test_data = ['TEST001', 'US', 'test-code', 'Test Product', '2022-01-01', 
                 '', '12', '2022-01-01', '', '', 'No', 'No', 'Test Agent', 
                 'Web', 'Test Campaign', '100.00', '10.00', '1', '110.00', 
                 '', '90.00']
    writer.writerow(test_data)

print("✅ Идеальный CSV создан!")

# 4. Проверим файл
print(f"\nПРОВЕРКА СОЗДАННОГО ФАЙЛА:")
with open(output_file, 'r', encoding='utf-8') as f:
    content = f.read()
    print(f"Длина: {len(content)} символов")
    print(f"Первые 200 символов:")
    print(content[:200])