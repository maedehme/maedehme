-- Standardise LGA codes and names from the raw mapping.
SELECT DISTINCT
    NULLIF(TRIM(lga_code), '') AS lga_code,
    UPPER(NULLIF(TRIM(lga_name), '')) AS lga_name
FROM {{ source('bronze', 'lga_code') }}