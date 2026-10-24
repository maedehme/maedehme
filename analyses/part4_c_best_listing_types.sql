-- Identify the five highest-revenue listing neighbourhoods.
WITH neighbourhood_revenue AS (
    SELECT
        listings.listing_neighbourhood,
        AVG(facts.estimated_revenue) AS average_revenue

    FROM {{ ref('fact_listing_month') }} AS facts
    JOIN {{ ref('dim_listing') }} AS listings
        ON facts.listing_key = listings.listing_key

    WHERE facts.has_availability IS TRUE
    GROUP BY listings.listing_neighbourhood
),

top_five AS (
    SELECT
        listing_neighbourhood,
        average_revenue,
        ROW_NUMBER() OVER (
            ORDER BY average_revenue DESC, listing_neighbourhood
        ) AS neighbourhood_rank

    FROM neighbourhood_revenue
    WHERE average_revenue IS NOT NULL
    ORDER BY average_revenue DESC, listing_neighbourhood
    LIMIT 5
),

-- Compare listing types within each selected neighbourhood.
type_performance AS (
    SELECT
        listings.listing_neighbourhood,
        listings.property_type,
        listings.room_type,
        listings.accommodates,

        COUNT(*) AS active_listing_months,
        COUNT(DISTINCT facts.listing_id) AS distinct_listings,
        SUM(facts.number_of_stays) AS total_stays,
        AVG(facts.number_of_stays) AS average_stays

    FROM {{ ref('fact_listing_month') }} AS facts
    JOIN {{ ref('dim_listing') }} AS listings
        ON facts.listing_key = listings.listing_key
    JOIN top_five
        ON listings.listing_neighbourhood =
           top_five.listing_neighbourhood

    WHERE facts.has_availability IS TRUE

    GROUP BY
        listings.listing_neighbourhood,
        listings.property_type,
        listings.room_type,
        listings.accommodates
),

-- Retain all listing types tied for the highest total stays.
ranked_types AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY listing_neighbourhood
            ORDER BY total_stays DESC NULLS LAST
        ) AS stays_rank
    FROM type_performance
    WHERE total_stays IS NOT NULL
)

SELECT
    top_five.neighbourhood_rank AS "LGA rank",
    types.listing_neighbourhood AS "LGA",
    ROUND(top_five.average_revenue, 2) AS "LGA avg revenue",
    types.property_type AS "Property type",
    types.room_type AS "Room type",
    types.accommodates AS "Capacity",
    types.distinct_listings AS "Listings",
    types.total_stays AS "Total stays",
    ROUND(types.average_stays, 2) AS "Avg stays/month"

FROM ranked_types AS types
JOIN top_five
    ON types.listing_neighbourhood =
       top_five.listing_neighbourhood

WHERE types.stays_rank = 1

ORDER BY
    top_five.neighbourhood_rank,
    types.property_type,
    types.room_type,
    types.accommodates