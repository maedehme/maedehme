-- Calculate one revenue measure per LGA across the 12 months.
WITH lga_revenue AS (
    SELECT
        lga_key,
        AVG(estimated_revenue) FILTER (
            WHERE has_availability IS TRUE
        ) AS revenue_per_active_listing
    FROM {{ ref('fact_listing_month') }}
    GROUP BY lga_key
),

-- Keep LGAs with both Census age and revenue data.
paired_data AS (
    SELECT
        lga.lga_name,
        lga.median_age_persons,
        revenue.revenue_per_active_listing
    FROM lga_revenue AS revenue
    JOIN {{ ref('dim_lga') }} AS lga
        ON revenue.lga_key = lga.lga_key
    WHERE lga.median_age_persons IS NOT NULL
      AND revenue.revenue_per_active_listing IS NOT NULL
)

-- Give each LGA equal weight in the Pearson correlation.
SELECT
    COUNT(*) AS lgas_compared,
    ROUND(
        CORR(
            median_age_persons::DOUBLE PRECISION,
            revenue_per_active_listing::DOUBLE PRECISION
        )::NUMERIC,
        4
    ) AS pearson_correlation
FROM paired_data