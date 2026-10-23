SELECT
    source_filename,
    reporting_month,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE scraped_date_month_mismatch
    ) AS mismatched_dates
FROM {{ ref('silver_airbnb_listings') }}
GROUP BY source_filename, reporting_month