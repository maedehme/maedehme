-- Measure each host's portfolio within the same reporting month.
WITH host_month_portfolios AS (
    SELECT
        reporting_month_key,
        host_id,
        COUNT(DISTINCT listing_id) AS listing_count,
        COUNT(DISTINCT lga_key) AS lga_count,
        COUNT(*) FILTER (
            WHERE lga_key IS NULL
        ) AS missing_lga_rows

    FROM {{ ref('fact_listing_month') }}
    WHERE host_id IS NOT NULL

    GROUP BY
        reporting_month_key,
        host_id

    HAVING COUNT(DISTINCT listing_id) > 1
),

classified AS (
    SELECT
        *,
        CASE
            WHEN missing_lga_rows > 0 THEN 'Unknown LGA'
            WHEN lga_count = 1 THEN 'Same LGA'
            ELSE 'Multiple LGAs'
        END AS portfolio_type
    FROM host_month_portfolios
),

summary AS (
    SELECT
        portfolio_type,
        COUNT(*) AS host_months,
        COUNT(DISTINCT host_id) AS distinct_hosts,
        AVG(listing_count) AS average_listings,
        AVG(lga_count) AS average_lgas
    FROM classified
    GROUP BY portfolio_type
)

SELECT
    portfolio_type AS "Portfolio",
    host_months AS "Host-months",
    distinct_hosts AS "Distinct hosts",

    ROUND(
        100.0 * host_months
        / NULLIF(SUM(host_months) OVER (), 0),
        2
    ) AS "Host-month %",

    ROUND(average_listings, 2) AS "Avg listings",
    ROUND(average_lgas, 2) AS "Avg LGAs"

FROM summary
ORDER BY portfolio_type