-- Verify that aggregation preserves all monthly listings.
SELECT
    reporting_month,
    COUNT(*) AS neighbourhoods,
    SUM(total_listings) AS total_listings,
    SUM(active_listings) AS active_listings,
    SUM(inactive_listings) AS inactive_listings,
    SUM(total_number_of_stays) AS total_stays
FROM {{ ref('dm_listing_neighbourhood') }}
GROUP BY reporting_month
ORDER BY reporting_month