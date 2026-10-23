{{ config(materialized='view') }}

-- Map host suburbs to LGAs without multiplying fact rows.
WITH suburb_mapping AS (
    SELECT
        suburb_name,
        MIN(lga_name) AS lga_name
    FROM {{ ref('silver_lga_suburb') }}
    WHERE suburb_name IS NOT NULL
    GROUP BY suburb_name
    HAVING COUNT(DISTINCT lga_name) = 1
),

host_listings AS (
    SELECT
        facts.reporting_month,
        facts.host_id,
        facts.has_availability,
        facts.estimated_revenue,
        COALESCE(mapping.lga_name, 'UNKNOWN')
            AS host_neighbourhood_lga
    FROM {{ ref('fact_listing_month') }} AS facts
    JOIN {{ ref('dim_host') }} AS hosts
        ON facts.host_key = hosts.host_key
    LEFT JOIN suburb_mapping AS mapping
        ON hosts.host_neighbourhood = mapping.suburb_name
)

-- Aggregate revenue by the host's home LGA and reporting month.
SELECT
    host_neighbourhood_lga,
    reporting_month,
    COUNT(DISTINCT host_id) AS distinct_hosts,

    ROUND(
        AVG(estimated_revenue) FILTER (
            WHERE has_availability IS TRUE
        ), 2
    ) AS average_estimated_revenue,

    ROUND(
        COALESCE(
            SUM(estimated_revenue) FILTER (
                WHERE has_availability IS TRUE
            ), 0
        ) / NULLIF(COUNT(DISTINCT host_id), 0),
        2
    ) AS estimated_revenue_per_host

FROM host_listings
GROUP BY host_neighbourhood_lga, reporting_month
ORDER BY host_neighbourhood_lga, reporting_month