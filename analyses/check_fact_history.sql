SELECT
    COUNT(*) AS total_facts,

    COUNT(*) FILTER (
        WHERE listings.listing_key IS NULL
           OR facts.listing_id IS DISTINCT FROM listings.listing_id
           OR months.full_date < listings.valid_from
           OR (
               listings.valid_to IS NOT NULL
               AND months.full_date >= listings.valid_to
           )
    ) AS invalid_listing_version,

    COUNT(*) FILTER (
        WHERE hosts.host_key IS NULL
           OR facts.host_id IS DISTINCT FROM hosts.host_id
           OR months.full_date < hosts.valid_from
           OR (
               hosts.valid_to IS NOT NULL
               AND months.full_date >= hosts.valid_to
           )
    ) AS invalid_host_version,

    COUNT(*) FILTER (
        WHERE months.date_key IS NULL
    ) AS missing_reporting_month

FROM {{ ref('fact_listing_month') }} AS facts

LEFT JOIN {{ ref('dim_listing') }} AS listings
    ON facts.listing_key = listings.listing_key

LEFT JOIN {{ ref('dim_host') }} AS hosts
    ON facts.host_key = hosts.host_key

LEFT JOIN {{ ref('dim_date') }} AS months
    ON facts.reporting_month_key = months.date_key