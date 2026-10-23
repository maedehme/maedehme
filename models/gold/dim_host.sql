-- Use only unambiguous suburb-to-LGA mappings.
WITH suburb_mapping AS (
    SELECT
        suburb_name,
        MIN(lga_name) AS lga_name
    FROM {{ ref('silver_lga_suburb') }}
    WHERE suburb_name IS NOT NULL
    GROUP BY suburb_name
    HAVING COUNT(DISTINCT lga_name) = 1
)

-- Enrich each historical host version with its mapped home LGA.
SELECT
    hosts.dbt_scd_id AS host_key,
    hosts.host_id,
    hosts.host_name,
    hosts.host_since,
    hosts.host_is_superhost,
    hosts.host_neighbourhood,

    COALESCE(
        mapping.lga_name,
        'UNKNOWN'
    ) AS host_neighbourhood_lga,

    hosts.dbt_valid_from AS valid_from,
    hosts.dbt_valid_to AS valid_to,
    (hosts.dbt_valid_to IS NULL) AS is_current

FROM {{ ref('snapshot_hosts') }} AS hosts

LEFT JOIN suburb_mapping AS mapping
    ON hosts.host_neighbourhood = mapping.suburb_name