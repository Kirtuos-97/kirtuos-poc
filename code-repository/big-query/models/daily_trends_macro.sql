CREATE OR REPLACE MODEL `${project_id}.${ml_dataset_id}.daily_trends_macro_forecast`
OPTIONS(
  model_type = 'ARIMA_PLUS',
  time_series_timestamp_col = 'refresh_date',
  time_series_data_col = 'total_daily_score',
  data_frequency = 'DAILY',
  clean_spikes_and_dips = TRUE,
  adjust_step_changes = TRUE
) AS
SELECT
  refresh_date,
  SUM(score) AS total_daily_score
FROM
  `${project_id}.${dataset_id}.google_trends_wb`
GROUP BY
  refresh_date;

-- deploy macro model v1