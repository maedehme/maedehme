-- Verify that property grouping preserves listing counts and stays.
SELECT
    reporting_month,
    COUNT(*) AS property_groups,
    SUM(total_listings) AS total_listings,
    SUM(active_listings) AS active_listings,
    SUM(inactive_listings) AS inactive_listings,
    SUM(total_number_of_stays) AS total_stays
FROM {{ ref('dm_property_type') }}
GROUP BY reporting_month
ORDER BY reporting_month