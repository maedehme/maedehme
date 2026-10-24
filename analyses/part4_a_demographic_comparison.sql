-- Rank LGAs by revenue per active listing-month.
WITH performance AS (
    SELECT
        lga_key,
        AVG(estimated_revenue) FILTER (
            WHERE has_availability IS TRUE
        ) AS average_revenue
    FROM {{ ref('fact_listing_month') }}
    GROUP BY lga_key
),

ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            ORDER BY average_revenue DESC, lga_key
        ) AS top_rank,
        ROW_NUMBER() OVER (
            ORDER BY average_revenue ASC, lga_key
        ) AS bottom_rank
    FROM performance
    WHERE average_revenue IS NOT NULL
      AND lga_key IS NOT NULL
),

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
    lga.lga_name AS "LGA",
    lga.median_age_persons AS "Median age",
    lga.average_household_size AS "Household size",
    lga.median_tot_hhd_inc_weekly AS "Weekly household income",

    ROUND(
        100.0 * (lga.age_0_4 + lga.age_5_14)
        / NULLIF(lga.population_total, 0), 2
    ) AS "Under 15 %",

    ROUND(
        100.0 * (
            lga.age_15_19 + lga.age_20_24 + lga.age_25_34
        ) / NULLIF(lga.population_total, 0), 2
    ) AS "Age 15-34 %",

    ROUND(
        100.0 * (
            lga.age_35_44 + lga.age_45_54 + lga.age_55_64
        ) / NULLIF(lga.population_total, 0), 2
    ) AS "Age 35-64 %",

    ROUND(
        100.0 * (
            lga.age_65_74 + lga.age_75_84 + lga.age_85_plus
        ) / NULLIF(lga.population_total, 0), 2
    ) AS "Age 65+ %"

FROM selected
JOIN {{ ref('dim_lga') }} AS lga
    ON selected.lga_key = lga.lga_key

ORDER BY
    CASE WHEN selected.performance_group = 'Top 3' THEN 0 ELSE 1 END,
    selected.group_rank