CREATE OR REPLACE TABLE `${project_id}.${dataset_id}.google_trends_wb` (
  refresh_date DATE,
  term STRING,
  rank INT64,
  score INT64,
  week DATE,
  country_name STRING,
  country_code STRING,
  region_name STRING,
  region_code STRING
)
PARTITION BY refresh_date
OPTIONS(
  partition_expiration_days = 365,
  description = "Google Trends data for West Bengal, India, with a rolling 365-day retention"
);