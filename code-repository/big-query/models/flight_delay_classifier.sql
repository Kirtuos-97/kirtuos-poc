CREATE OR REPLACE MODEL `${project_id}.${ml_dataset_id}.flight_delay_classifier`
OPTIONS(
  model_type = 'BOOSTED_TREE_CLASSIFIER',
  input_label_cols = ['is_severely_delayed'],
  max_iterations = 25,
  tree_method = 'HIST',
  subsample = 0.85,
  early_stop = TRUE,
  min_rel_progress = 0.005,
  auto_class_weights = TRUE
) AS
SELECT
  -- Categorical & Spatial Features
  airline,
  departure_airport,
  departure_state,
  arrival_airport,
  arrival_state,
  
  -- Extracted Temporal Features
  EXTRACT(HOUR FROM departure_schedule_timestamp) AS scheduled_departure_hour,
  EXTRACT(DAYOFWEEK FROM flight_date) AS day_of_week,
  EXTRACT(MONTH FROM flight_date) AS flight_month,
  
  -- Target Label
  IF(departure_delay >= 30.0, 1, 0) AS is_severely_delayed
FROM
  `${project_id}.${dataset_id}.airline_ontime_data`
WHERE
  departure_delay IS NOT NULL
  AND departure_schedule_timestamp IS NOT NULL
  -- Temporal Training Boundary: 2006 to 2010
  AND EXTRACT(YEAR FROM flight_date) BETWEEN 2006 AND 2010
  -- Deterministic sample for efficient slot usage
  AND MOD(ABS(FARM_FINGERPRINT(CONCAT(airline, CAST(flight_date AS STRING), CAST(departure_schedule_timestamp AS STRING)))), 10) <= 2;

-- deploy boosted tree classifier 2006_2010 v2