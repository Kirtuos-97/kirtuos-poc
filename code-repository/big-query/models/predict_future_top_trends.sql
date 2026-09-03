CREATE OR REPLACE MODEL `${project_id}.${dataset_id}.predict_future_top_trends`
OPTIONS(
  model_type = 'ARIMA_PLUS',
  time_series_timestamp_col = 'refresh_date',
  time_series_data_col = 'score',
  time_series_id_col = 'term',
  data_frequency = 'DAILY',
  holiday_region = 'IN',
  auto_arima_max_order = 7, -- allows engine to explore more
  clean_spikes_and_dips = TRUE, -- removes viral short lived trends
  adjust_step_changes = TRUE --detects permenant increase to a new baseline instead of continuos growth
) AS
SELECT
  refresh_date,
  term,
  score
FROM
  `${project_id}.${dataset_id}.google_trends_wb`
WHERE
  term IN (
    SELECT term
    FROM `${project_id}.${dataset_id}.google_trends_wb`
    GROUP BY term
    HAVING COUNT(DISTINCT refresh_date) >= 100
    --select only those terms which appear more than 100 times, helps to remove sudden spikes
  );