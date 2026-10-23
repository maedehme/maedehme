{% snapshot snapshot_hosts %}

{{
    config(
        target_schema='silver_snapshots',
        unique_key='host_id',
        strategy='timestamp',
        updated_at='scraped_date'
    )
}}

-- Preserve host dimension attributes using the source observation date.
SELECT
    host_id,
    host_name,
    host_since,
    host_is_superhost,
    host_neighbourhood,
    scraped_date
FROM {{ ref('silver_hosts') }}

{% endsnapshot %}