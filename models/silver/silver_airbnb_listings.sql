-- Convert raw Airbnb fields to appropriate data types.
-- Preserve missing values as NULL rather than inventing values.
WITH cleaned AS (
    SELECT
        NULLIF(TRIM(listing_id), '')::BIGINT AS listing_id,
        NULLIF(TRIM(scrape_id), '')::BIGINT AS scrape_id,
        NULLIF(TRIM(scraped_date), '')::DATE AS scraped_date,
        NULLIF(TRIM(host_id), '')::BIGINT AS host_id,
        NULLIF(TRIM(host_name), '') AS host_name,

        -- Source host_since dates use day/month/year.
        TO_DATE(NULLIF(TRIM(host_since), ''), 'DD/MM/YYYY')
            AS host_since,

        CASE LOWER(TRIM(host_is_superhost))
            WHEN 't' THEN TRUE
            WHEN 'f' THEN FALSE
            ELSE NULL
        END AS host_is_superhost,

        UPPER(NULLIF(TRIM(host_neighbourhood), ''))
            AS host_neighbourhood,
        UPPER(NULLIF(TRIM(listing_neighbourhood), ''))
            AS listing_neighbourhood,
        NULLIF(TRIM(property_type), '') AS property_type,
        NULLIF(TRIM(room_type), '') AS room_type,
        NULLIF(TRIM(accommodates), '')::INTEGER AS accommodates,

        -- Remove currency symbols and thousands separators.
        NULLIF(
            REGEXP_REPLACE(TRIM(price), '[$,]', '', 'g'), ''
        )::NUMERIC AS price,

        CASE LOWER(TRIM(has_availability))
            WHEN 't' THEN TRUE
            WHEN 'f' THEN FALSE
            ELSE NULL
        END AS has_availability,

        NULLIF(TRIM(availability_30), '')::INTEGER AS availability_30,
        NULLIF(TRIM(number_of_reviews), '')::INTEGER AS number_of_reviews,
        NULLIF(TRIM(review_scores_rating), '')::NUMERIC
            AS review_scores_rating,
        NULLIF(TRIM(review_scores_accuracy), '')::NUMERIC
            AS review_scores_accuracy,
        NULLIF(TRIM(review_scores_cleanliness), '')::NUMERIC
            AS review_scores_cleanliness,
        NULLIF(TRIM(review_scores_checkin), '')::NUMERIC
            AS review_scores_checkin,
        NULLIF(TRIM(review_scores_communication), '')::NUMERIC
            AS review_scores_communication,
        NULLIF(TRIM(review_scores_value), '')::NUMERIC
            AS review_scores_value
    FROM {{ source('bronze', 'airbnb_listings') }}
)

-- Derive the reporting month and measures defined in the brief.
SELECT
    *,
    DATE_TRUNC('month', scraped_date)::DATE AS reporting_month,
    CASE
        WHEN has_availability THEN 30 - availability_30
        ELSE NULL
    END AS number_of_stays,
    CASE
        WHEN has_availability THEN (30 - availability_30) * price
        ELSE NULL
    END AS estimated_revenue
FROM cleaned