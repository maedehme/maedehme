-- Select one consistent host record from the current monthly batch.
WITH ranked_hosts AS (
    SELECT
        host_id,
        host_name,
        host_since,
        host_is_superhost,
        host_neighbourhood,
        scraped_date,
        snapshot_updated_at,

        ROW_NUMBER() OVER (
            PARTITION BY host_id
            ORDER BY scraped_date ASC, listing_id ASC
        ) AS row_num

    FROM {{ ref('silver_airbnb_listings') }}
    WHERE host_id IS NOT NULL
)

SELECT
    host_id,
    host_name,
    host_since,
    host_is_superhost,
    host_neighbourhood,
    scraped_date,
    snapshot_updated_at
FROM ranked_hosts
WHERE row_num = 1