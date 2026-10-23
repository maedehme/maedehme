{% snapshot snapshot_hosts %}

{{
    config(
        target_schema='silver_snapshots_v2',
        unique_key='host_id',
        strategy='timestamp',
        updated_at='snapshot_updated_at'
    )
}}

-- Preserve host versions using the source reporting month.
-- Retain the original scrape date for traceability.
SELECT
    host_id,
    host_name,
    host_since,
    host_is_superhost,
    host_neighbourhood,
    scraped_date,
    snapshot_updated_at
FROM {{ ref('silver_hosts') }}

{% endsnapshot %}