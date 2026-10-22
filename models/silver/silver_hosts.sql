-- Select one consistent host record from the current monthly data.
WITH ranked_hosts AS (
    SELECT
        host_id,
        host_name,
        host_since,
        host_is_superhost,
        host_neighbourhood,
        scraped_date,
        ROW_NUMBER() OVER (
            PARTITION BY host_id
            ORDER BY scraped_date DESC, listing_id
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
    scraped_date
FROM ranked_hosts
WHERE row_num = 1