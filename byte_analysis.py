# byte_analysis.py
print("="*80)
print("ПОЛНЫЙ БАЙТОВЫЙ АНАЛИЗ ФАЙЛА")
print("="*80)

with open('seeds/sales_data.csv', 'rb') as f:
    data = f.read(500)  # первые 500 байтов

print("1. HEX представление первых 200 байтов:")
for i in range(0, min(200, len(data)), 16):
    hex_part = ' '.join(f'{b:02x}' for b in data[i:i+16])
    ascii_part = ''.join(chr(b) if 32 <= b < 127 else '.' for b in data[i:i+16])
    print(f'{i:04x}: {hex_part:48}  {ascii_part}')

print("\n2. ASCII коды первых 100 символов:")
for i in range(min(100, len(data))):
    byte = data[i]
    if 32 <= byte < 127:
        char = chr(byte)
        print(f'{i:3d}: {byte:3d} (0x{byte:02x}) -> \'{char}\'')
    else:
        print(f'{i:3d}: {byte:3d} (0x{byte:02x}) -> [НЕПЕЧАТАЕМЫЙ]')

print("\n3. Поиск разделителей в первых 300 байтах:")
first_300 = data[:300] if len(data) >= 300 else data
print(f"   Запятых (0x2c): {first_300.count(44)}")
print(f"   Точек с запятой (0x3b): {first_300.count(59)}")
print(f"   Табов (0x09): {first_300.count(9)}")
print(f"   Кавычек (0x22): {first_300.count(34)}")
print(f"   Пробелов (0x20): {first_300.count(32)}")
print(f"   Переносов строк (0x0a): {first_300.count(10)}")
print(f"   Возвратов каретки (0x0d): {first_300.count(13)}")

print("\n4. Первая строка (до переноса строки):")
# Находим первый перенос строки
try:
    newline_pos = data.index(10)  # 0x0a = \n
    first_line = data[:newline_pos]
    print(f"   Длина: {len(first_line)} байт")
    print(f"   Содержимое: {first_line.decode('utf-8', errors='ignore')}")
except ValueError:
    print("   Перенос строки не найден!")