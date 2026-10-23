-- Retain cleaned Census G02 as Gold reference data.
{{ config(materialized='table') }}

SELECT *
FROM {{ ref('silver_census_g02') }}