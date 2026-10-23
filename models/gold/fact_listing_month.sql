-- Build monthly listing facts from the preserved snapshot versions.
WITH listing_history AS (
    SELECT *
    FROM {{ ref('snapshot_listings') }}
)

SELECT
    listings.dbt_scd_id AS listing_month_key,
    listing_dim.listing_key,
    hosts.host_key,
    lga.lga_key,
    dates.date_key,

    listings.listing_id,
    listings.host_id,
    listings.reporting_month,
    listings.scraped_date,
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

FROM listing_history AS listings

LEFT JOIN {{ ref('dim_listing') }} AS listing_dim
    ON listings.dbt_scd_id = listing_dim.listing_key

-- Match the host version observed in the same reporting month.
LEFT JOIN {{ ref('dim_host') }} AS hosts
    ON listings.host_id = hosts.host_id
    AND listings.reporting_month =
        DATE_TRUNC('month', hosts.valid_from)::DATE

LEFT JOIN {{ ref('dim_lga') }} AS lga
    ON listings.listing_neighbourhood = lga.lga_name

LEFT JOIN {{ ref('dim_date') }} AS dates
    ON listings.scraped_date = dates.full_date