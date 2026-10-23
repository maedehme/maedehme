-- Validate LGA uniqueness and Census matching.
SELECT
    COUNT(*) AS total_lgas,
    COUNT(DISTINCT lga_code) AS distinct_lga_codes,
    COUNT(*) FILTER (
        WHERE population_total IS NULL
    ) AS missing_population,
    COUNT(*) FILTER (
        WHERE median_age_persons IS NULL
    ) AS missing_median_age
FROM {{ ref('dim_lga') }}