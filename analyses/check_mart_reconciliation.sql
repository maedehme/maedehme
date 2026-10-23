-- Compare monthly fact totals with both listing-based marts.
WITH totals AS (
    SELECT
        'Fact' AS source_name,
        months.full_date AS reporting_month,
        COUNT(*) AS total_listings,
        COUNT(*) FILTER (
            WHERE facts.has_availability IS TRUE
        ) AS active_listings,
        COUNT(*) FILTER (
            WHERE facts.has_availability IS FALSE
        ) AS inactive_listings,
        COALESCE(SUM(facts.number_of_stays) FILTER (
            WHERE facts.has_availability IS TRUE
        ), 0) AS total_stays
    FROM {{ ref('fact_listing_month') }} AS facts
    JOIN {{ ref('dim_date') }} AS months
        ON facts.reporting_month_key = months.date_key
    GROUP BY months.full_date

    UNION ALL

    SELECT
        'Listing neighbourhood',
        reporting_month,
        SUM(total_listings),
        SUM(active_listings),
        SUM(inactive_listings),
        SUM(total_number_of_stays)
    FROM {{ ref('dm_listing_neighbourhood') }}
    GROUP BY reporting_month

    UNION ALL

    SELECT
        'Property type',
        reporting_month,
        SUM(total_listings),
        SUM(active_listings),
        SUM(inactive_listings),
        SUM(total_number_of_stays)
    FROM {{ ref('dm_property_type') }}
    GROUP BY reporting_month
)

SELECT *
FROM totals
ORDER BY reporting_month, source_name