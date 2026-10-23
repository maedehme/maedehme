-- Validate the Gold Census reference tables.
SELECT
    'census_g01' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT lga_code) AS unique_lga_codes,
    COUNT(*) FILTER (
        WHERE lga_code IS NULL
    ) AS missing_lga_codes
FROM {{ ref('census_g01') }}

UNION ALL

SELECT
    'census_g02' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT lga_code) AS unique_lga_codes,
    COUNT(*) FILTER (
        WHERE lga_code IS NULL
    ) AS missing_lga_codes
FROM {{ ref('census_g02') }}