-- Validate fact grain and dimension relationships.
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT listing_month_key) AS unique_fact_keys,
    COUNT(DISTINCT (listing_id, reporting_month))
        AS unique_listing_months,
    COUNT(*) FILTER (WHERE listing_key IS NULL) AS missing_listing,
    COUNT(*) FILTER (WHERE host_key IS NULL) AS missing_host,
    COUNT(*) FILTER (WHERE lga_key IS NULL) AS missing_lga,
    COUNT(*) FILTER (WHERE date_key IS NULL) AS missing_date
FROM {{ ref('fact_listing_month') }}