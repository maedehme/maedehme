-- Check row count and listing uniqueness for the initial month.
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT listing_id) AS distinct_listings,
    COUNT(*) FILTER (WHERE listing_id IS NULL) AS missing_listing_ids,
    MIN(reporting_month) AS first_month,
    MAX(reporting_month) AS last_month
FROM {{ ref('silver_airbnb_listings') }}

-- Validate the initial listing snapshot.
SELECT
    COUNT(*) AS total_versions,
    COUNT(DISTINCT listing_id) AS distinct_listings,
    COUNT(*) FILTER (
        WHERE dbt_valid_to IS NULL
    ) AS current_versions
FROM {{ ref('snapshot_listings') }}