-- Separate listing attributes from monthly measures.
SELECT
    listing_id,
    host_id,
    listing_neighbourhood,
    property_type,
    room_type,
    accommodates,
    scraped_date,
    snapshot_updated_at
FROM {{ ref('silver_airbnb_listings') }}