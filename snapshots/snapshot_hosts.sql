{% snapshot snapshot_hosts %}

{{
    config(
        target_schema='snapshots',
        unique_key='host_id',
        strategy='timestamp',
        updated_at='scraped_date'
    )
}}

-- Preserve host versions using the source scrape date.
SELECT *
FROM {{ ref('silver_hosts') }}

{% endsnapshot %}