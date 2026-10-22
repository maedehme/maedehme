-- Check row count and listing uniqueness for the initial month.
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT listing_id) AS distinct_listings,
    COUNT(*) FILTER (WHERE listing_id IS NULL) AS missing_listing_ids,
    MIN(reporting_month) AS first_month,
    MAX(reporting_month) AS last_month
FROM {{ ref('silver_airbnb_listings') }}