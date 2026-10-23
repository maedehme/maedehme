WITH source AS (
    SELECT *
    FROM {{ source('bronze', 'lga_suburb') }}
),

renamed AS (
    SELECT
        lga_name,
        suburb_name
    FROM source
)

SELECT *
FROM renamed