-- Create a daily date dimension covering all assignment months.
SELECT
    TO_CHAR(day_date, 'YYYYMMDD')::INTEGER AS date_key,
    day_date::DATE AS full_date,
    EXTRACT(YEAR FROM day_date)::INTEGER AS year,
    EXTRACT(MONTH FROM day_date)::INTEGER AS month,
    EXTRACT(DAY FROM day_date)::INTEGER AS day,
    EXTRACT(QUARTER FROM day_date)::INTEGER AS quarter,
    DATE_TRUNC('month', day_date)::DATE AS reporting_month,
    TO_CHAR(day_date, 'YYYY-MM') AS year_month
FROM GENERATE_SERIES(
    TIMESTAMP '2020-05-01',
    TIMESTAMP '2021-04-30',
    INTERVAL '1 day'
) AS dates(day_date)