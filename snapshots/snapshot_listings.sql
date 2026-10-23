{% snapshot snapshot_listings %}

{{
    config(
        target_schema='silver_snapshots_v2',
        unique_key='listing_id',
        strategy='timestamp',
        updated_at='snapshot_updated_at'
    )
}}

-- Preserve listing versions using the source reporting month.
-- Retain the original scrape date for traceability.
SELECT
    listing_id,
    host_id,
    listing_neighbourhood,
    property_type,
    room_type,
    accommodates,
    scraped_date,
    snapshot_updated_at
FROM {{ ref('silver_listings') }}

{% endsnapshot %}