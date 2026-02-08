-- Простой тестовый запрос
SELECT 
    schemaname as schema,
    tablename as table
FROM pg_tables 
WHERE tablename LIKE '%sales%'
ORDER BY schemaname, tablename;
