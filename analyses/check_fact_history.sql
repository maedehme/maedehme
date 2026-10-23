-- Validate that each fact references the correct historical versions.
SELECT
    COUNT(*) AS total_facts,

    COUNT(*) FILTER (
        WHERE listings.listing_key IS NULL
           OR listings.listing_id IS DISTINCT FROM facts.listing_id
           OR dates.full_date < listings.valid_from
           OR (
               listings.valid_to IS NOT NULL
               AND dates.full_date >= listings.valid_to
           )
    ) AS invalid_listing_version,

    COUNT(*) FILTER (
        WHERE hosts.host_key IS NULL
           OR hosts.host_id IS DISTINCT FROM facts.host_id
           OR dates.full_date < hosts.valid_from
           OR (
               hosts.valid_to IS NOT NULL
               AND dates.full_date >= hosts.valid_to
           )
    ) AS invalid_host_version,

    COUNT(*) FILTER (
        WHERE dates.date_key IS NULL
    ) AS unmatched_observation_date

FROM {{ ref('fact_listing_month') }} AS facts

LEFT JOIN {{ ref('dim_listing') }} AS listings
    ON facts.listing_key = listings.listing_key

LEFT JOIN {{ ref('dim_host') }} AS hosts
    ON facts.host_key = hosts.host_key

LEFT JOIN {{ ref('dim_date') }} AS dates
    ON facts.date_key = dates.date_key