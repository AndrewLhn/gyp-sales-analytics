#!/bin/bash
echo "🔍 ФИНАЛЬНАЯ ПРОВЕРКА ПРОЕКТА GYP SALES ANALYTICS"
echo "================================================="

ERRORS=0

# 1. Проверка подключения
echo -e "\n1. 🔗 ПРОВЕРКА ПОДКЛЮЧЕНИЯ"
if dbt debug 2>&1 | grep -q "SUCCESS"; then
    echo "   ✅ Подключение к БД успешно"
else
    echo "   ❌ Ошибка подключения"
    ERRORS=$((ERRORS + 1))
fi

# 2. Проверка таблиц
echo -e "\n2. 🗄️  ПРОВЕРКА ТАБЛИЦ"
TABLE_COUNT=$(PGPASSWORD=postgres psql -U postgres -d gyp_sales -h localhost -t -c "
SELECT COUNT(*) 
FROM pg_tables 
WHERE schemaname IN ('raw_analytics', 'raw', 'raw_monitoring') 
  AND tablename IN ('fct_sales', 'dim_customers', 'monthly_sales_report');" 2>/dev/null | tr -d ' ')

if [ "$TABLE_COUNT" -ge 3 ]; then
    echo "   ✅ Основные таблицы существуют ($TABLE_COUNT из 3)"
else
    echo "   ❌ Не все таблицы созданы"
    ERRORS=$((ERRORS + 1))
fi

# 3. Проверка анализов
echo -e "\n3. 📊 ПРОВЕРКА АНАЛИТИЧЕСКИХ ЗАПРОСОВ"
ANALYSIS_COUNT=$(ls analyses/*.sql 2>/dev/null | wc -l | tr -d ' ')
if [ "$ANALYSIS_COUNT" -ge 3 ]; then
    echo "   ✅ Аналитические запросы созданы ($ANALYSIS_COUNT)"
else
    echo "   ❌ Мало аналитических запросов"
    ERRORS=$((ERRORS + 1))
fi

# 4. Проверка данных
echo -e "\n4. 📈 ПРОВЕРКА ДАННЫХ"
DATA_CHECK=$(PGPASSWORD=postgres psql -U postgres -d gyp_sales -h localhost -t -c "
SELECT CASE 
    WHEN COUNT(*) > 0 AND SUM(total_amount) > 0 THEN 'OK'
    ELSE 'ERROR'
END
FROM raw_analytics.fct_sales;" 2>/dev/null | tr -d ' ')

if [ "$DATA_CHECK" = "OK" ]; then
    echo "   ✅ Данные корректны"
else
    echo "   ❌ Проблемы с данными"
    ERRORS=$((ERRORS + 1))
fi

# Итог
echo -e "\n================================================="
if [ "$ERRORS" -eq 0 ]; then
    echo "🎉 ПРОЕКТ РАБОТОСПОСОБЕН! Все проверки пройдены."
    echo ""
    echo "ЧТО ВЫПОЛНЕНО:"
    echo "✅ Создана витрина данных fct_sales"
    echo "✅ Написаны аналитические запросы"
    echo "✅ Выполнены 3 обязательных анализа"
    echo "✅ Данные доступны и корректны"
else
    echo "⚠️  Найдено $ERRORS проблем. Требуется доработка."
fi
echo "================================================="
