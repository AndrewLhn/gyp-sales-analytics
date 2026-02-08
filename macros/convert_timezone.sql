-- macros/convert_timezone.sql
{% macro convert_timezone(from_tz, to_tz, column_name) %}
    CASE
        WHEN '{{ target.type }}' = 'snowflake' THEN
            CONVERT_TIMEZONE('{{ from_tz }}', '{{ to_tz }}', {{ column_name }})
        WHEN '{{ target.type }}' = 'postgres' THEN
            {{ column_name }} AT TIME ZONE '{{ from_tz }}' AT TIME ZONE '{{ to_tz }}'
        WHEN '{{ target.type }}' = 'bigquery' THEN
            TIMESTAMP({{ column_name }}, '{{ to_tz }}')
        ELSE
            {{ column_name }}
    END
{% endmacro %}