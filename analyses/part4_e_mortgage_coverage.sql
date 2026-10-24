-- Identify hosts with one listing and one consistent LGA
-- across the full reporting period.
WITH host_portfolios AS (
    SELECT
        host_id,
        MIN(lga_key) AS lga_key,
        COUNT(DISTINCT listing_id) AS listing_count,
        COUNT(DISTINCT lga_key) AS lga_count,
        COUNT(DISTINCT reporting_month_key) AS observed_months,

        COUNT(*) FILTER (
            WHERE lga_key IS NULL
        ) AS missing_lga_rows,

        COUNT(*) FILTER (
            WHERE has_availability IS NULL
               OR (
                   has_availability IS TRUE
                   AND estimated_revenue IS NULL
               )
        ) AS missing_revenue_rows,

        SUM(
            CASE
                WHEN has_availability IS TRUE
                THEN estimated_revenue
                ELSE 0
            END
        ) AS period_revenue

    FROM {{ ref('fact_listing_month') }}
    WHERE host_id IS NOT NULL
    GROUP BY host_id
),

-- Compare observed revenue with the annualised Census mortgage.
eligible_hosts AS (
    SELECT
        hosts.host_id,
        hosts.lga_key,
        hosts.observed_months,
        hosts.period_revenue,
        lga.lga_name,
        lga.median_mortgage_repay_monthly * 12 AS annual_mortgage

    FROM host_portfolios AS hosts
    JOIN {{ ref('dim_lga') }} AS lga
        ON hosts.lga_key = lga.lga_key

    WHERE hosts.listing_count = 1
      AND hosts.lga_count = 1
      AND hosts.missing_lga_rows = 0
      AND hosts.missing_revenue_rows = 0
      AND lga.median_mortgage_repay_monthly > 0
),

summary AS (
    SELECT
        lga_name,
        annual_mortgage,
        COUNT(*) AS eligible_hosts,

        COUNT(*) FILTER (
            WHERE period_revenue >= annual_mortgage
        ) AS covering_hosts,

        COUNT(*) FILTER (
            WHERE observed_months = 12
        ) AS hosts_with_12_months,

        AVG(period_revenue) AS average_period_revenue

    FROM eligible_hosts
    GROUP BY lga_name, annual_mortgage
),

coverage AS (
    SELECT
        *,
        100.0 * covering_hosts
        / NULLIF(eligible_hosts, 0) AS coverage_pct
    FROM summary
)

SELECT
    DENSE_RANK() OVER (
        ORDER BY coverage_pct DESC
    ) AS "Rank",

    lga_name AS "LGA",
    eligible_hosts AS "Single-listing hosts",
    covering_hosts AS "Covering mortgage",
    ROUND(coverage_pct, 2) AS "Coverage %",
    ROUND(annual_mortgage, 2) AS "Annual mortgage",
    ROUND(average_period_revenue, 2) AS "Avg period revenue",
    hosts_with_12_months AS "Hosts with 12 months"

FROM coverage
ORDER BY coverage_pct DESC, eligible_hosts DESC, lga_name