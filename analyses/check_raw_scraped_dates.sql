-- Inspect source date strings before any date conversion.
SELECT
    scraped_date AS raw_scraped_date,
    COUNT(*) AS total_rows
FROM {{ source('bronze', 'airbnb_listings') }}
GROUP BY scraped_date
ORDER BY scraped_date