CREATE OR REPLACE PROCEDURE `${project_id}.${dataset_id}.populate_ga_logistic_features_FL`(
  start_date STRING, 
  end_date STRING
)
BEGIN
  -- 1. Handle NULL parameters by setting default table suffixes
  IF start_date IS NULL THEN
    SET start_date = '20260801';
  END IF;
  
  IF end_date IS NULL THEN
    SET end_date = '20261231';
  END IF;

  -- 2. Truncate the existing table to ensure a clean load
  TRUNCATE TABLE `your_dataset.ga_logistic_features`;

  -- 3. Load the data into the partitioned table
  INSERT INTO `your_dataset.ga_logistic_features`
  SELECT
    PARSE_DATE('%Y%m%d', date) AS visit_date,
    IF(totals.transactions IS NULL, 0, 1) AS label,
    IFNULL(totals.pageviews, 0) AS pageviews,
    IFNULL(totals.hits, 0) AS hits,
    IFNULL(totals.bounces, 0) AS bounces,
    IFNULL(totals.timeOnSite, 0) AS time_on_site,
    visitNumber AS visit_number,
    IFNULL(device.operatingSystem, "Unknown") AS os,
    device.isMobile AS is_mobile,
    IFNULL(geoNetwork.country, "Unknown") AS country,
    IFNULL(channelGrouping, "Unknown") AS channel_grouping
  FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  WHERE
    _TABLE_SUFFIX BETWEEN start_date AND end_date;

END;