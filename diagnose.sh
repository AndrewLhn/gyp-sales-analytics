#!/bin/bash

echo "=== ДИАГНОСТИКА ПРОБЛЕМЫ SEED ==="
echo ""

echo "1. Проверка подключения к БД:"
psql -U postgres -d sales_analytics -c "SELECT 'Connected' as status;" 2>/dev/null && echo "✅ Подключение OK" || echo "❌ Ошибка подключения"
echo ""

echo "2. Проверка существующих таблиц:"
psql -U postgres -d sales_analytics -c "\dt" 2>/dev/null || echo "Не удалось получить список таблиц"
echo ""

echo "3. Проверка CSV файла:"
echo "   Количество столбцов: $(head -1 seeds/sales_data.csv | tr ',' '\n' | wc -l)"
echo "   Столбцы: $(head -1 seeds/sales_data.csv)"
echo ""

echo "4. Проверка dbt кэша:"
if [ -d "target/" ]; then
    echo "   Папка target существует"
    find target/ -name "*.sql" | head -3
else
    echo "   Папка target не существует"
fi
echo ""

echo "5. Попытка создания таблицы вручную:"
psql -U postgres -d sales_analytics << 'SQL'
DROP TABLE IF EXISTS test_table;
CREATE TABLE test_table (id INT, name VARCHAR(50));
INSERT INTO test_table VALUES (1, 'test');
SELECT * FROM test_table;
DROP TABLE test_table;
SQL
echo ""

echo "Диагностика завершена."
