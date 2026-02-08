# create_perfect_sales_data.py
import re

# Читаем оригинальный файл
with open('seeds/sales_data.csv', 'r', encoding='utf-8-sig') as f:
    content = f.read()

print(f"Размер оригинального файла: {len(content)} символов")

# Удаляем ВСЕ кавычки
content = content.replace('"', '')

# Заменяем точки с запятой на запятые (если есть)
content = content.replace(';', ',')

# Удаляем лишние пробелы в начале/конце строк
lines = [line.strip() for line in content.split('\n') if line.strip()]

print(f"Получено строк: {len(lines)}")

# Анализируем первую строку (заголовок)
if lines:
    header = lines[0]
    print(f"\nЗаголовок: {len(header)} символов")
    print(f"Запятых в заголовке: {header.count(',')}")
    
    # Разбиваем заголовок
    header_parts = header.split(',')
    print(f"Разбито на {len(header_parts)} частей")
    print(f"Первые 5 частей: {header_parts[:5]}")
    
    # Проверяем, что заголовок имеет 21 часть (20 запятых)
    if len(header_parts) != 21:
        print(f"⚠️  ВНИМАНИЕ: Заголовок должен иметь 21 колонку, но имеет {len(header_parts)}")
        
        # Попробуем найти правильный разделитель
        for delimiter in [',', ';', '\t', '|']:
            parts = header.split(delimiter)
            if len(parts) == 21:
                print(f"✅ Найден правильный разделитель: '{delimiter}'")
                # Переразбиваем все строки с этим разделителем
                lines = [line.replace(delimiter, ',') for line in lines]
                break

# Создаем НОВЫЙ файл
output_file = 'seeds/sales_data_PERFECT.csv'
with open(output_file, 'w', newline='', encoding='utf-8') as f:
    for i, line in enumerate(lines):
        # Убедимся, что в конце строки нет запятой
        line = line.rstrip(',')
        f.write(line)
        if i < len(lines) - 1:
            f.write('\n')

print(f"\n✅ Новый файл создан: {output_file}")

# Проверяем
with open(output_file, 'r') as f:
    new_lines = f.readlines()
    print(f"Строк в новом файле: {len(new_lines)}")
    
    if new_lines:
        first_line = new_lines[0].strip()
        print(f"Запятых в новом заголовке: {first_line.count(',')}")
        print(f"Первые 100 символов нового заголовка: {first_line[:100]}")