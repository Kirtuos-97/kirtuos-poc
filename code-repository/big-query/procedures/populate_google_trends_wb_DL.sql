CREATE OR REPLACE PROCEDURE `${project_id}.${dataset_id}.populate_google_trends_wb_DL`()
BEGIN
  DECLARE max_partition_date DATE;

  -- 1. Fetch the maximum valid partition date from INFORMATION_SCHEMA
  SET max_partition_date = (
    SELECT 
      PARSE_DATE('%Y%m%d', MAX(partition_id))
    FROM 
      `${project_id}.${dataset_id}.INFORMATION_SCHEMA.PARTITIONS`
    WHERE 
      table_name = 'google_trends_wb'
      AND partition_id NOT IN ('__NULL__', '__UNPARTITIONED__')
  );

  -- 2. Fallback for the very first run (if the table is completely empty)
  IF max_partition_date IS NULL THEN
    SET max_partition_date = DATE_SUB(CURRENT_DATE(), INTERVAL 365 DAY);
  END IF;

  -- 3. Insert only the new delta records
  INSERT INTO `${project_id}.${dataset_id}.google_trends_wb` (
    refresh_date, term, rank, score, week, country_name, country_code, region_name, region_code
  )
  SELECT 
    refresh_date, term, rank, score, week, country_name, country_code, region_name, region_code
  FROM 
    `bigquery-public-data.google_trends.international_top_terms`
  WHERE 
    country_code = 'IN'
    AND region_name = 'West Bengal'
    AND refresh_date > max_partition_date
    AND refresh_date <= CURRENT_DATE();
END;