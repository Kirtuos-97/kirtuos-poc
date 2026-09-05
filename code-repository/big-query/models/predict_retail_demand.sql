CREATE OR REPLACE MODEL `${project_id}.${ml_dataset_id}.predict_retail_demand`
OPTIONS(
  model_type = 'LINEAR_REG',
  input_label_cols = ['bottles_sold'],
  
  -- Regularization to handle multicollinearity among pricing features
  l1_reg = 0.1,
  l2_reg = 1.0,
  
  -- Optimization
  max_iterations = 30,
  early_stop = TRUE,
  min_rel_progress = 0.001,
  
  -- Validation Split
  data_split_method = 'AUTO_SPLIT'
) AS
SELECT
  bottles_sold,          -- Label (Target)
  pack,                  -- Pack size (cases)
  bottle_volume_ml,      -- Volume per bottle
  state_bottle_cost,     -- Wholesale cost
  state_bottle_retail,   -- Retail shelf price
  retail_markup,         -- Price difference
  category_name,         -- Liquor type / category
  county,                -- Store market location
  order_month,           -- Seasonality
  day_of_week            -- Weekly replenishment cycle
FROM
  `${project_id}.${dataset_id}.retail_sales_features`
WHERE 
  bottles_sold <=50;--testing performance on the most dominant group