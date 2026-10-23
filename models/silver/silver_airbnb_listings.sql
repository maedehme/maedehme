-- Read the reporting month recorded by the Airflow load.
WITH load_metadata AS (
    SELECT
        source_filename,
        reporting_month
    FROM {{ source('bronze', 'load_metadata') }}
    WHERE table_name = 'airbnb_listings'
),

-- Convert raw fields while preserving the original scrape date.
cleaned AS (
    SELECT
        NULLIF(TRIM(raw.listing_id), '')::BIGINT AS listing_id,
        NULLIF(TRIM(raw.scrape_id), '')::BIGINT AS scrape_id,
        NULLIF(TRIM(raw.scraped_date), '')::DATE AS scraped_date,
        NULLIF(TRIM(raw.host_id), '')::BIGINT AS host_id,
        NULLIF(TRIM(raw.host_name), '') AS host_name,

        TO_DATE(
            NULLIF(TRIM(raw.host_since), ''),
            'DD/MM/YYYY'
        ) AS host_since,

        CASE LOWER(TRIM(raw.host_is_superhost))
            WHEN 't' THEN TRUE
            WHEN 'f' THEN FALSE
            ELSE NULL
        END AS host_is_superhost,

        UPPER(NULLIF(TRIM(raw.host_neighbourhood), ''))
            AS host_neighbourhood,

        UPPER(NULLIF(TRIM(raw.listing_neighbourhood), ''))
            AS listing_neighbourhood,

        NULLIF(TRIM(raw.property_type), '') AS property_type,
        NULLIF(TRIM(raw.room_type), '') AS room_type,
        NULLIF(TRIM(raw.accommodates), '')::INTEGER AS accommodates,

        NULLIF(
            REGEXP_REPLACE(TRIM(raw.price), '[$,]', '', 'g'),
            ''
        )::NUMERIC AS price,

        CASE LOWER(TRIM(raw.has_availability))
            WHEN 't' THEN TRUE
            WHEN 'f' THEN FALSE
            ELSE NULL
        END AS has_availability,

        NULLIF(TRIM(raw.availability_30), '')::INTEGER
            AS availability_30,

        NULLIF(TRIM(raw.number_of_reviews), '')::INTEGER
            AS number_of_reviews,

        NULLIF(TRIM(raw.review_scores_rating), '')::NUMERIC
            AS review_scores_rating,

        NULLIF(TRIM(raw.review_scores_accuracy), '')::NUMERIC
            AS review_scores_accuracy,

        NULLIF(TRIM(raw.review_scores_cleanliness), '')::NUMERIC
            AS review_scores_cleanliness,

        NULLIF(TRIM(raw.review_scores_checkin), '')::NUMERIC
            AS review_scores_checkin,

        NULLIF(TRIM(raw.review_scores_communication), '')::NUMERIC
            AS review_scores_communication,

        NULLIF(TRIM(raw.review_scores_value), '')::NUMERIC
            AS review_scores_value,

        metadata.source_filename,
        metadata.reporting_month

    FROM {{ source('bronze', 'airbnb_listings') }} AS raw
    CROSS JOIN load_metadata AS metadata
)

SELECT
    *,

    -- Use the source reporting period as the monthly effective timestamp.
    reporting_month::TIMESTAMP AS snapshot_updated_at,

    -- Flag missing dates and dates outside the source reporting month.
    (
        scraped_date IS NULL
        OR DATE_TRUNC('month', scraped_date)::DATE <> reporting_month
    ) AS scraped_date_month_mismatch,

    CASE
        WHEN has_availability IS TRUE
        THEN 30 - availability_30
        ELSE NULL
    END AS number_of_stays,

    CASE
        WHEN has_availability IS TRUE
        THEN (30 - availability_30) * price
        ELSE NULL
    END AS estimated_revenue

FROM cleaned