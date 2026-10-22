-- Build the host dimension with a key for each historical version.
SELECT
    dbt_scd_id AS host_key,
    host_id,
    host_name,
    host_since,
    host_is_superhost,
    host_neighbourhood,
    dbt_valid_from AS valid_from,
    dbt_valid_to AS valid_to,
    (dbt_valid_to IS NULL) AS is_current
FROM {{ ref('snapshot_hosts') }}