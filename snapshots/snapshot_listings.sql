{% snapshot snapshot_listings %}

{{
    config(
        target_schema='snapshots',
        unique_key='listing_id',
        strategy='timestamp',
        updated_at='scraped_date'
    )
}}

-- Preserve listing versions using the source scrape date.
SELECT *
FROM {{ ref('silver_airbnb_listings') }}

{% endsnapshot %}