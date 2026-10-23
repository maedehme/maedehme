{{ config(materialized='view') }}

-- Aggregate monthly metrics by property type, room type and capacity.
WITH monthly AS (
    SELECT
        listings.property_type,
        listings.room_type,
        listings.accommodates,
        facts.reporting_month,
        COUNT(*) AS total_listings,
        COUNT(*) FILTER (
            WHERE facts.has_availability IS TRUE
        ) AS active_listings,
        COUNT(*) FILTER (
            WHERE facts.has_availability IS FALSE
        ) AS inactive_listings,

        MIN(facts.price) FILTER (
            WHERE facts.has_availability IS TRUE
        ) AS minimum_price,
        MAX(facts.price) FILTER (
            WHERE facts.has_availability IS TRUE
        ) AS maximum_price,
        (
            PERCENTILE_CONT(0.5) WITHIN GROUP (
                ORDER BY facts.price
            ) FILTER (WHERE facts.has_availability IS TRUE)
        )::NUMERIC AS median_price,
        AVG(facts.price) FILTER (
            WHERE facts.has_availability IS TRUE
        ) AS average_price,

        COUNT(DISTINCT facts.host_id) AS distinct_hosts,
        COUNT(DISTINCT facts.host_id) FILTER (
            WHERE hosts.host_is_superhost IS TRUE
        ) AS superhosts,

        AVG(facts.review_scores_rating) FILTER (
            WHERE facts.has_availability IS TRUE
        ) AS average_review_score,

        COALESCE(SUM(facts.number_of_stays) FILTER (
            WHERE facts.has_availability IS TRUE
        ), 0) AS total_number_of_stays,

        AVG(facts.estimated_revenue) FILTER (
            WHERE facts.has_availability IS TRUE
        ) AS average_estimated_revenue

    FROM {{ ref('fact_listing_month') }} AS facts
    JOIN {{ ref('dim_listing') }} AS listings
        ON facts.listing_key = listings.listing_key
    JOIN {{ ref('dim_host') }} AS hosts
        ON facts.host_key = hosts.host_key
    GROUP BY
        listings.property_type,
        listings.room_type,
        listings.accommodates,
        facts.reporting_month
),

-- Calculate previous-month counts within each property group.
previous_month AS (
    SELECT
        *,
        LAG(active_listings) OVER (
            PARTITION BY property_type, room_type, accommodates
            ORDER BY reporting_month
        ) AS previous_active_listings,
        LAG(inactive_listings) OVER (
            PARTITION BY property_type, room_type, accommodates
            ORDER BY reporting_month
        ) AS previous_inactive_listings,
        LAG(reporting_month) OVER (
            PARTITION BY property_type, room_type, accommodates
            ORDER BY reporting_month
        ) AS previous_reporting_month
    FROM monthly
)

SELECT
    property_type,
    room_type,
    accommodates,
    reporting_month,
    total_listings,
    active_listings,
    inactive_listings,
    ROUND(
        100.0 * active_listings / NULLIF(total_listings, 0), 2
    ) AS active_listings_rate,
    minimum_price,
    maximum_price,
    ROUND(median_price, 2) AS median_price,
    ROUND(average_price, 2) AS average_price,
    distinct_hosts,
    ROUND(
        100.0 * superhosts / NULLIF(distinct_hosts, 0), 2
    ) AS superhost_rate,
    ROUND(average_review_score, 2) AS average_review_score,

    -- Only compare consecutive calendar months.
    CASE
        WHEN previous_reporting_month =
            (reporting_month - INTERVAL '1 month')::DATE
        THEN ROUND(
            100.0 * (active_listings - previous_active_listings)
            / NULLIF(previous_active_listings, 0), 2
        )
    END AS active_listings_percentage_change,

    CASE
        WHEN previous_reporting_month =
            (reporting_month - INTERVAL '1 month')::DATE
        THEN ROUND(
            100.0 * (inactive_listings - previous_inactive_listings)
            / NULLIF(previous_inactive_listings, 0), 2
        )
    END AS inactive_listings_percentage_change,

    total_number_of_stays,
    ROUND(average_estimated_revenue, 2) AS average_estimated_revenue
FROM previous_month
ORDER BY property_type, room_type, accommodates, reporting_month