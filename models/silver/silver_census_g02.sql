-- Standardise LGA codes and convert Census measures to numeric types.
SELECT
    REPLACE(UPPER(TRIM(lga_code_2016)), 'LGA', '') AS lga_code,
    NULLIF(TRIM(median_age_persons), '')::NUMERIC
        AS median_age_persons,
    NULLIF(TRIM(median_mortgage_repay_monthly), '')::NUMERIC
        AS median_mortgage_repay_monthly,
    NULLIF(TRIM(median_tot_prsnl_inc_weekly), '')::NUMERIC
        AS median_tot_prsnl_inc_weekly,
    NULLIF(TRIM(median_rent_weekly), '')::NUMERIC
        AS median_rent_weekly,
    NULLIF(TRIM(median_tot_fam_inc_weekly), '')::NUMERIC
        AS median_tot_fam_inc_weekly,
    NULLIF(TRIM(average_num_psns_per_bedroom), '')::NUMERIC
        AS average_num_psns_per_bedroom,
    NULLIF(TRIM(median_tot_hhd_inc_weekly), '')::NUMERIC
        AS median_tot_hhd_inc_weekly,
    NULLIF(TRIM(average_household_size), '')::NUMERIC
        AS average_household_size
FROM {{ source('bronze', 'census_g02') }}