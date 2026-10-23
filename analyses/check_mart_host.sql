-- Check host totals and identify unmapped host locations.
SELECT
    reporting_month,
    COUNT(*) AS host_lga_groups,
    SUM(distinct_hosts) AS total_hosts,
    SUM(distinct_hosts) FILTER (
        WHERE host_neighbourhood_lga = 'UNKNOWN'
    ) AS unmapped_hosts
FROM {{ ref('dm_host_neighbourhood') }}
GROUP BY reporting_month
ORDER BY reporting_month