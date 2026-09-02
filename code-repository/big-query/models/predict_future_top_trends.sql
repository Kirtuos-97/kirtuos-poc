create or replace model `{project_id}.{dataset_id}.predict_future_top_trends`
options(
  model_type='ARIMA_PLUS',
  time_series_timestamp_col='refresh_date',
  time_series_data_col='score',
  time_series_id_col='term',
  data_frequency='DAILY'
) as 
SELECT
  refresh_date,
  term,
  score
FROM
  `${project_id}.${dataset_id}.google_trends_wb`;