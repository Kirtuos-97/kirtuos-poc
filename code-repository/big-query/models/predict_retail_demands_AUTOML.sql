CREATE OR REPLACE MODEL `${project_id}.${ml_dataset_id}.predict_retail_demands_AUTOML`
OPTIONS(
  model_type = 'AUTOML_REGRESSOR',
  input_label_cols = ['bottles_sold'],
  
  -- Minimum compute budget for Vertex AI backend is 1.0 hour
  budget_hours = 1.0,
  
  -- Optimization objective: RMSE heavily penalizes the bulk-order forecast misses
  optimization_objective = 'MINIMIZE_RMSE'
) AS
SELECT
  bottles_sold,          
  pack,                  
  bottle_volume_ml,      
  state_bottle_cost,     
  state_bottle_retail,   
  retail_markup,         
  category_name,         
  county,                
  order_month,           
  day_of_week            
FROM
  `${project_id}.${dataset_id}.retail_sales_features`
WHERE
  -- Train strictly on historical data prior to your holdout window
  EXTRACT(YEAR FROM order_date) BETWEEN 2015 AND 2023;