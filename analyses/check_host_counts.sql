-- Compare distinct fact hosts with the hosts represented in the mart.
WITH fact_counts AS (
    SELECT
        reporting_month_key,
        COUNT(DISTINCT host_id) AS fact_hosts
    FROM {{ ref('fact_listing_month') }}
    GROUP BY reporting_month_key
),

mart_counts AS (
    SELECT
        reporting_month,
        SUM(distinct_hosts) AS mart_hosts,
        SUM(
            CASE
                WHEN host_neighbourhood_lga = 'UNKNOWN'
                THEN distinct_hosts
                ELSE 0
            END
        ) AS unmapped_hosts
    FROM {{ ref('dm_host_neighbourhood') }}
    GROUP BY reporting_month
)

SELECT
    months.full_date AS reporting_month,
    facts.fact_hosts,
    mart.mart_hosts,
    mart.mart_hosts - facts.fact_hosts AS host_count_difference,
    mart.unmapped_hosts

FROM fact_counts AS facts

JOIN {{ ref('dim_date') }} AS months
    ON facts.reporting_month_key = months.date_key

LEFT JOIN mart_counts AS mart
    ON months.full_date = mart.reporting_month

ORDER BY reporting_month