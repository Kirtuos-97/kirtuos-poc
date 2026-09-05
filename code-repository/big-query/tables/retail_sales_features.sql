CREATE OR REPLACE TABLE `${project_id}.${dataset_id}.retail_sales_features` (
  order_date DATE NOT NULL,
  bottles_sold INT64,
  sale_dollars FLOAT64,
  pack INT64,
  bottle_volume_ml INT64,
  state_bottle_cost FLOAT64,
  state_bottle_retail FLOAT64,
  retail_markup FLOAT64,
  category_name STRING,
  vendor_name STRING,
  county STRING,
  order_month INT64,
  day_of_week INT64
)
PARTITION BY DATE_TRUNC(order_date, MONTH)
CLUSTER BY category_name, county
OPTIONS(
  description = "Retail wholesale transactions formatted for Linear Regression demand modeling"
);