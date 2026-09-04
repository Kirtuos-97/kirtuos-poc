CREATE OR REPLACE PROCEDURE `${project_id}.${dataset_id}.populate_airline_ontime_data_FL`(
  start_year INT64,
  end_year INT64
)
BEGIN
  DECLARE effective_start_year INT64;
  DECLARE effective_end_year INT64;
  DECLARE qualifying_rows INT64;

  -- Default to 2003-2012 if both parameters are NULL
  IF start_year IS NULL AND end_year IS NULL THEN
    SET effective_start_year = 2003;
    SET effective_end_year = 2012;
  ELSE
    SET effective_start_year = COALESCE(start_year, 2003);
    SET effective_end_year = COALESCE(end_year, 2012);
  END IF;

  -- Validate row count before performing any table mutation
  SET qualifying_rows = (
    SELECT COUNT(1)
    FROM `bigquery-samples.airline_ontime_data.flights`
    WHERE EXTRACT(YEAR FROM PARSE_DATE('%Y-%m-%d', `date`)) 
          BETWEEN effective_start_year AND effective_end_year
  );

  -- Throw exception if row count is zero
  IF qualifying_rows = 0 THEN
    RAISE USING MESSAGE = FORMAT(
      'No data found in bigquery-samples.airline_ontime_data.flights for year range: %d - %d', 
      effective_start_year, 
      effective_end_year
    );
  END IF;

  -- Truncate target table
  TRUNCATE TABLE `${project_id}.${dataset_id}.airline_ontime_data`;

  -- Insert transformed data
  INSERT INTO `${project_id}.${dataset_id}.airline_ontime_data` (
    flight_date,
    airline,
    airline_code,
    departure_airport,
    departure_state,
    departure_lat,
    departure_lon,
    arrival_airport,
    arrival_state,
    arrival_lat,
    arrival_lon,
    departure_schedule_timestamp,
    departure_actual_timestamp,
    departure_delay,
    arrival_schedule_timestamp,
    arrival_actual_timestamp,
    arrival_delay
  )
  SELECT
    PARSE_DATE('%Y-%m-%d', date) AS flight_date,
    airline,
    airline_code,
    departure_airport,
    departure_state,
    CAST(departure_lat AS FLOAT64) AS departure_lat,
    CAST(departure_lon AS FLOAT64) AS departure_lon,
    arrival_airport,
    arrival_state,
    CAST(arrival_lat AS FLOAT64) AS arrival_lat,
    CAST(arrival_lon AS FLOAT64) AS arrival_lon,
    
    SAFE.PARSE_TIMESTAMP(
      '%Y-%m-%d %H%M',
      CONCAT(date, ' ', LPAD(CAST(departure_schedule AS STRING), 4, '0'))
    ) AS departure_schedule_timestamp,

    SAFE.PARSE_TIMESTAMP(
      '%Y-%m-%d %H%M',
      CONCAT(date, ' ', LPAD(CAST(departure_actual AS STRING), 4, '0'))
    ) AS departure_actual_timestamp,
    
    SAFE_CAST(departure_delay AS FLOAT64) AS departure_delay,
    
    SAFE.PARSE_TIMESTAMP(
      '%Y-%m-%d %H%M',
      CONCAT(date, ' ', LPAD(CAST(arrival_schedule AS STRING), 4, '0'))
    ) AS arrival_schedule_timestamp,

    SAFE.PARSE_TIMESTAMP(
      '%Y-%m-%d %H%M',
      CONCAT(date, ' ', LPAD(CAST(arrival_actual AS STRING), 4, '0'))
    ) AS arrival_actual_timestamp,
    
    SAFE_CAST(arrival_delay AS FLOAT64) AS arrival_delay
  FROM
    `bigquery-samples.airline_ontime_data.flights`
  WHERE
    EXTRACT(YEAR FROM PARSE_DATE('%Y-%m-%d', `date`)) 
      BETWEEN effective_start_year AND effective_end_year;

END;