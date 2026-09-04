CREATE OR REPLACE MODEL `${project_id}.${ml_dataset_id}.flight_delay_classifier_V2`
OPTIONS(
  model_type = 'BOOSTED_TREE_CLASSIFIER',
  input_label_cols = ['is_severely_delayed'],
  max_iterations = 45,
  max_tree_depth = 6,
  learn_rate = 0.08,
  l2_reg = 2.0,
  tree_method = 'HIST',
  subsample = 0.85,
  early_stop = TRUE,
  min_rel_progress = 0.005,
  -- Turn off automated 1:9 imbalance scaling
  auto_class_weights = FALSE,
  -- Apply calibrated 1:3 penalty on missed delays
  class_weights = [STRUCT('0' AS label, 1.0 AS weight), STRUCT('1' AS label, 3.0 AS weight)]
) AS
SELECT
  departure_airport,
  arrival_airport,
  CONCAT(departure_airport, '->', arrival_airport) AS route,
  departure_state,
  arrival_state,
  EXTRACT(HOUR FROM departure_schedule_timestamp) AS scheduled_departure_hour,
  EXTRACT(DAYOFWEEK FROM flight_date) AS day_of_week,
  EXTRACT(MONTH FROM flight_date) AS flight_month,
  IF(EXTRACT(HOUR FROM departure_schedule_timestamp) IN (7, 8, 9, 16, 17, 18, 19, 20), 1, 0) AS is_rush_hour,
  IF(EXTRACT(DAYOFWEEK FROM flight_date) IN (1, 6, 7), 1, 0) AS is_weekend_rush,
  IF(departure_delay >= 30.0, 1, 0) AS is_severely_delayed
FROM
  `${project_id}.${dataset_id}.airline_ontime_data`
WHERE
  departure_delay IS NOT NULL
  AND departure_schedule_timestamp IS NOT NULL
  AND EXTRACT(YEAR FROM flight_date) BETWEEN 2006 AND 2010
  AND MOD(ABS(FARM_FINGERPRINT(CONCAT(airline, CAST(flight_date AS STRING), CAST(departure_schedule_timestamp AS STRING)))), 10) <= 2;

-- deploy BTC v2 with calibrated 1:3 class weighting