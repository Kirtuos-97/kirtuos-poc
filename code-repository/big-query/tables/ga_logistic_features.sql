CREATE OR REPLACE TABLE `${project_id}.${dataset_id}.ga_logistic_features` (
  visit_date DATE,
  label INT64,
  pageviews INT64,
  hits INT64,
  bounces INT64,
  time_on_site INT64,
  visit_number INT64,
  os STRING,
  is_mobile BOOLEAN,
  country STRING,
  channel_grouping STRING
)
PARTITION BY DATE_TRUNC(visit_date, MONTH);