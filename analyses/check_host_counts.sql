-- Compare host counts between the fact table and host mart.
SELECT
    (
        SELECT COUNT(DISTINCT host_id)
        FROM {{ ref('fact_listing_month') }}
    ) AS fact_hosts,
    (
        SELECT SUM(distinct_hosts)
        FROM {{ ref('dm_host_neighbourhood') }}
    ) AS mart_hosts