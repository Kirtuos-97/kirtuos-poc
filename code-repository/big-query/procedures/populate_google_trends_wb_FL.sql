CREATE OR REPLACE PROCEDURE `${project_id}.${dataset_id}.populate_google_trends_wb_FL`()
BEGIN
  
  --truncate table
  TRUNCATE TABLE `${project_id}.${dataset_id}.google_trends_wb`;

  --load full data of 1 year
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
    AND refresh_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 365 DAY);

END;