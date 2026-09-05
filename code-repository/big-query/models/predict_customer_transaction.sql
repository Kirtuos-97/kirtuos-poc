--LOGISTIC_REG
CREATE OR REPLACE MODEL `${project_id}.${ml_dataset_id}.predict_customer_transaction`
OPTIONS(
  model_type = 'LOGISTIC_REG',
  input_label_cols = ['label'],
  auto_class_weights = TRUE,
  data_split_method = 'AUTO_SPLIT'
) AS
SELECT
  label,
  pageviews,
  hits,
  bounces,
  time_on_site,
  visit_number,
  os,
  is_mobile,
  country,
  channel_grouping
FROM
  `${project_id}.${dataset_id}.ga_logistic_features`
WHERE
  visit_date between '2016-08-01' and '2016-12-31'
  ;