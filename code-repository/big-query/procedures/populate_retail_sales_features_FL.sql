CREATE OR REPLACE PROCEDURE `${project_id}.${dataset_id}.populate_retail_sales_features_FL`(
  start_year INT64,
  end_year INT64
)
BEGIN
  -- Default to 2015-2023 if NULL
  IF start_year IS NULL THEN
    SET start_year = 2015;
  END IF;
  
  IF end_year IS NULL THEN
    SET end_year = 2026;
  END IF;

  TRUNCATE TABLE `${project_id}.${dataset_id}.retail_sales_features`;

  INSERT INTO `${project_id}.${dataset_id}.retail_sales_features` (
    order_date,
    bottles_sold,
    sale_dollars,
    pack,
    bottle_volume_ml,
    state_bottle_cost,
    state_bottle_retail,
    retail_markup,
    category_name,
    vendor_name,
    county,
    order_month,
    day_of_week
  )
  SELECT
    date AS order_date,
    bottles_sold,
    sale_dollars,
    pack,
    bottle_volume_ml,
    state_bottle_cost,
    state_bottle_retail,
    ROUND(state_bottle_retail - state_bottle_cost, 2) AS retail_markup,
    IFNULL(category_name, 'Other') AS category_name,
    IFNULL(vendor_name, 'Other') AS vendor_name,
    IFNULL(county, 'Unknown') AS county,
    EXTRACT(MONTH FROM date) AS order_month,
    EXTRACT(DAYOFWEEK FROM date) AS day_of_week
  FROM
    `bigquery-public-data.iowa_liquor_sales.sales`
  WHERE
    EXTRACT(YEAR FROM date) BETWEEN start_year AND end_year
    AND bottles_sold > 0
    AND sale_dollars > 0
    AND state_bottle_cost > 0
    AND state_bottle_retail > 0
    AND category_name IS NOT NULL;
END;