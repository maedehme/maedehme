SELECT
    months.full_date AS reporting_month,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT facts.listing_month_key) AS unique_fact_keys
FROM {{ ref('fact_listing_month') }} AS facts
JOIN {{ ref('dim_date') }} AS months
    ON facts.reporting_month_key = months.date_key
GROUP BY months.full_date
ORDER BY months.full_date