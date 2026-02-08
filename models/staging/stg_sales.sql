{{ config(
    materialized='table',
    schema='staging'
) }}

SELECT * FROM raw.sales
