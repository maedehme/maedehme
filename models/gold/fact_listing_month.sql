{{
    config(
        materialized='incremental',
        unique_key='listing_month_key',
        incremental_strategy='delete+insert'
    )
}}

-- Store one fact row per listing and source reporting month.
WITH monthly_listings AS (
    SELECT *
    FROM {{ ref('silver_airbnb_listings') }}
)

SELECT
    MD5(
        listings.listing_id::TEXT
        || '|'
        || TO_CHAR(listings.reporting_month, 'YYYY-MM')
    ) AS listing_month_key,

    listing_dim.listing_key,
    hosts.host_key,
    lga.lga_key,
    dates.date_key,

    TO_CHAR(
        listings.reporting_month, 'YYYYMMDD'
    )::INTEGER AS reporting_month_key,

    listings.listing_id,
    listings.host_id,
    listings.price,
    listings.has_availability,
    listings.availability_30,
    listings.number_of_stays,
    listings.estimated_revenue,
    listings.number_of_reviews,
    listings.review_scores_rating,
    listings.review_scores_accuracy,
    listings.review_scores_cleanliness,
    listings.review_scores_checkin,
    listings.review_scores_communication,
    listings.review_scores_value

FROM monthly_listings AS listings

-- Match the listing version valid for the source reporting month.
LEFT JOIN {{ ref('dim_listing') }} AS listing_dim
    ON listings.listing_id = listing_dim.listing_id
    AND listings.snapshot_updated_at >= listing_dim.valid_from
    AND (
        listings.snapshot_updated_at < listing_dim.valid_to
        OR listing_dim.valid_to IS NULL
    )

-- Match the host version valid for the source reporting month.
LEFT JOIN {{ ref('dim_host') }} AS hosts
    ON listings.host_id = hosts.host_id
    AND listings.snapshot_updated_at >= hosts.valid_from
    AND (
        listings.snapshot_updated_at < hosts.valid_to
        OR hosts.valid_to IS NULL
    )

LEFT JOIN {{ ref('dim_lga') }} AS lga
    ON listings.listing_neighbourhood = lga.lga_name

-- Preserve the original observation date separately.
LEFT JOIN {{ ref('dim_date') }} AS dates
    ON listings.scraped_date = dates.full_date