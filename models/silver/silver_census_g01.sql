-- Prepare population totals and age groups for LGA analysis.
SELECT
    REPLACE(UPPER(TRIM(lga_code_2016)), 'LGA', '') AS lga_code,
    NULLIF(TRIM(tot_p_m), '')::INTEGER AS population_male,
    NULLIF(TRIM(tot_p_f), '')::INTEGER AS population_female,
    NULLIF(TRIM(tot_p_p), '')::INTEGER AS population_total,
    NULLIF(TRIM(age_0_4_yr_p), '')::INTEGER AS age_0_4,
    NULLIF(TRIM(age_5_14_yr_p), '')::INTEGER AS age_5_14,
    NULLIF(TRIM(age_15_19_yr_p), '')::INTEGER AS age_15_19,
    NULLIF(TRIM(age_20_24_yr_p), '')::INTEGER AS age_20_24,
    NULLIF(TRIM(age_25_34_yr_p), '')::INTEGER AS age_25_34,
    NULLIF(TRIM(age_35_44_yr_p), '')::INTEGER AS age_35_44,
    NULLIF(TRIM(age_45_54_yr_p), '')::INTEGER AS age_45_54,
    NULLIF(TRIM(age_55_64_yr_p), '')::INTEGER AS age_55_64,
    NULLIF(TRIM(age_65_74_yr_p), '')::INTEGER AS age_65_74,
    NULLIF(TRIM(age_75_84_yr_p), '')::INTEGER AS age_75_84,
    NULLIF(TRIM(age_85ov_p), '')::INTEGER AS age_85_plus
FROM {{ source('bronze', 'census_g01') }}