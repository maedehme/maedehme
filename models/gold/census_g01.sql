-- Retain cleaned Census G01 as Gold reference data.
{{ config(materialized='table') }}

SELECT *
FROM {{ ref('silver_census_g01') }}