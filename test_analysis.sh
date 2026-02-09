#!/bin/bash

echo "🔍 ТЕСТИРОВАНИЕ АНАЛИТИЧЕСКОГО ЗАПРОСА"
echo "====================================="

if [ -z "$1" ]; then
    echo "Использование: $0 <имя_анализа>"
    echo "Доступные анализы:"
    ls analyses/*.sql | sed 's|analyses/||;s|\.sql||' | sort
    exit 1
fi

ANALYSIS_NAME=$1
SQL_FILE="analyses/${ANALYSIS_NAME}.sql"

if [ ! -f "$SQL_FILE" ]; then
    echo "❌ Файл $SQL_FILE не найден!"
    exit 1
fi

echo "1. Проверка синтаксиса файла: $SQL_FILE"
echo "----------------------------------------"

# Компилируем
dbt compile > /dev/null 2>&1

compiled_file="target/compiled/gyp_sales_analytics/analyses/${ANALYSIS_NAME}.sql"
if [ ! -f "$compiled_file" ]; then
    echo "❌ Ошибка компиляции!"
    echo "Содержимое ошибки:"
    dbt compile 2>&1 | tail -20
    exit 1
fi

echo "✅ Файл успешно скомпилирован"

echo -e "\n2. Скомпилированный SQL:"
echo "----------------------------------------"
head -20 "$compiled_file"
if [ $(wc -l < "$compiled_file") -gt 20 ]; then
    echo "..."
fi

echo -e "\n3. Тестовый запуск (первые 5 строк):"
echo "----------------------------------------"
PGPASSWORD=postgres psql -U postgres -d gyp_sales -h localhost \
    -c "$(head -20 "$compiled_file") LIMIT 5;" 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "\n✅ Тест пройден успешно!"
else
    echo -e "\n❌ Ошибка выполнения SQL"
    echo "Попробуйте выполнить вручную:"
    echo "PGPASSWORD=postgres psql -U postgres -d gyp_sales -h localhost -f \"$compiled_file\" LIMIT 5;"
fi
