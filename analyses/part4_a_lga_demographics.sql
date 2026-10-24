-- Calculate revenue per active listing-month across the full period.
WITH lga_performance AS (
    SELECT
        lga_key,
        COUNT(DISTINCT reporting_month_key) AS reporting_months,

        COUNT(*) FILTER (
            WHERE has_availability IS TRUE
        ) AS active_listing_months,

        AVG(estimated_revenue) FILTER (
            WHERE has_availability IS TRUE
        ) AS revenue_per_active_listing

    FROM {{ ref('fact_listing_month') }}
    GROUP BY lga_key
),

-- Rank LGAs from highest and lowest revenue.
ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            ORDER BY revenue_per_active_listing DESC, lga_key
        ) AS top_rank,

        ROW_NUMBER() OVER (
            ORDER BY revenue_per_active_listing ASC, lga_key
        ) AS bottom_rank

    FROM lga_performance
    WHERE revenue_per_active_listing IS NOT NULL
      AND lga_key IS NOT NULL
),

-- Keep the top three and bottom three LGAs.
selected AS (
    SELECT
        *,
        CASE
            WHEN top_rank <= 3 THEN 'Top 3'
            ELSE 'Bottom 3'
        END AS performance_group,

        CASE
            WHEN top_rank <= 3 THEN top_rank
            ELSE bottom_rank
        END AS group_rank

    FROM ranked
    WHERE top_rank <= 3 OR bottom_rank <= 3
)

SELECT
    selected.performance_group AS "Group",
    selected.group_rank AS "Rank",
    lga.lga_name AS "LGA",
    selected.reporting_months AS "Months",
    selected.active_listing_months AS "Active listing-months",

    ROUND(
        selected.revenue_per_active_listing, 2
    ) AS "Avg monthly revenue"

FROM selected

JOIN {{ ref('dim_lga') }} AS lga
    ON selected.lga_key = lga.lga_key

ORDER BY
    CASE
        WHEN selected.performance_group = 'Top 3' THEN 0
        ELSE 1
    END,
    selected.group_rank