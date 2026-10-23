-- Build one dimension row for each historical listing version.
SELECT
    dbt_scd_id AS listing_key,
    listing_id,
    host_id,
    listing_neighbourhood,
    property_type,
    room_type,
    accommodates,
    dbt_valid_from AS valid_from,
    dbt_valid_to AS valid_to,
    (dbt_valid_to IS NULL) AS is_current
FROM {{ ref('snapshot_listings') }}