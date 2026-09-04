CREATE OR REPLACE TABLE `${project_id}.${dataset_id}.airline_ontime_data` (
  flight_date DATE NOT NULL,
  airline STRING,
  airline_code STRING,
  departure_airport STRING,
  departure_state STRING,
  departure_lat FLOAT64,
  departure_lon FLOAT64,
  arrival_airport STRING,
  arrival_state STRING,
  arrival_lat FLOAT64,
  arrival_lon FLOAT64,
  departure_schedule_timestamp TIMESTAMP,
  departure_actual_timestamp TIMESTAMP,
  departure_delay FLOAT64,
  arrival_schedule_timestamp TIMESTAMP,
  arrival_actual_timestamp TIMESTAMP,
  arrival_delay FLOAT64
)
PARTITION BY DATE_TRUNC(flight_date, MONTH)
CLUSTER BY airline, departure_airport, arrival_airport
OPTIONS(
  description = "Aviation on-time performance telemetry partitioned monthly by flight_date"
);

-- deploy airline_ontime_data table v1