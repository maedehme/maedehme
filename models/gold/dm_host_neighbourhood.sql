{{ config(materialized='view') }}

-- Read monthly measures and historical host attributes from Gold.
WITH host_listings AS (
    SELECT
        months.full_date AS reporting_month,
        facts.host_id,
        facts.has_availability,
        facts.estimated_revenue,
        hosts.host_neighbourhood_lga

    FROM {{ ref('fact_listing_month') }} AS facts

    JOIN {{ ref('dim_host') }} AS hosts
        ON facts.host_key = hosts.host_key

    JOIN {{ ref('dim_date') }} AS months
        ON facts.reporting_month_key = months.date_key
)

-- Aggregate monthly revenue and distinct hosts by host LGA.
SELECT
    host_neighbourhood_lga,
    reporting_month,
    COUNT(DISTINCT host_id) AS distinct_hosts,

    ROUND(
        AVG(estimated_revenue) FILTER (
            WHERE has_availability IS TRUE
        ),
        2
    ) AS average_estimated_revenue,

    ROUND(
        COALESCE(
            SUM(estimated_revenue) FILTER (
                WHERE has_availability IS TRUE
            ),
            0
        ) / NULLIF(COUNT(DISTINCT host_id), 0),
        2
    ) AS estimated_revenue_per_host

FROM host_listings

GROUP BY
    host_neighbourhood_lga,
    reporting_month

ORDER BY
    host_neighbourhood_lga,
    reporting_month