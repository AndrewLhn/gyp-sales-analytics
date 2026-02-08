{{ config(
    materialized='table',
    schema='raw_staging'
) }}

SELECT * FROM raw.sales
