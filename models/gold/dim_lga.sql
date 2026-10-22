-- Combine LGA names with Census population and economic measures.
SELECT
    codes.lga_code AS lga_key,
    codes.lga_code,
    codes.lga_name,
    population.population_male,
    population.population_female,
    population.population_total,
    population.age_0_4,
    population.age_5_14,
    population.age_15_19,
    population.age_20_24,
    population.age_25_34,
    population.age_35_44,
    population.age_45_54,
    population.age_55_64,
    population.age_65_74,
    population.age_75_84,
    population.age_85_plus,
    measures.median_age_persons,
    measures.median_mortgage_repay_monthly,
    measures.median_tot_prsnl_inc_weekly,
    measures.median_rent_weekly,
    measures.median_tot_fam_inc_weekly,
    measures.average_num_psns_per_bedroom,
    measures.median_tot_hhd_inc_weekly,
    measures.average_household_size
FROM {{ ref('silver_lga_code') }} AS codes
LEFT JOIN {{ ref('silver_census_g01') }} AS population
    ON codes.lga_code = population.lga_code
LEFT JOIN {{ ref('silver_census_g02') }} AS measures
    ON codes.lga_code = measures.lga_code