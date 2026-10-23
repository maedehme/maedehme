{% snapshot snapshot_listings %}

{{
    config(
        target_schema='silver_snapshots',
        unique_key='listing_id',
        strategy='timestamp',
        updated_at='scraped_date'
    )
}}

-- Preserve listing dimension attributes using the source observation date.
SELECT
    listing_id,
    host_id,
    listing_neighbourhood,
    property_type,
    room_type,
    accommodates,
    scraped_date
FROM {{ ref('silver_listings') }}

{% endsnapshot %}