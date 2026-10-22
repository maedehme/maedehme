-- Standardise suburb and LGA names for consistent joins.
SELECT DISTINCT
    UPPER(NULLIF(TRIM(lga_name), '')) AS lga_name,
    UPPER(NULLIF(TRIM(suburb_name), '')) AS suburb_name
FROM {{ source('bronze', 'lga_suburb') }}