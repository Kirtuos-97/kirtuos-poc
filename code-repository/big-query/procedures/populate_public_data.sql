CREATE OR REPLACE PROCEDURE `${project_id}.${dataset_id}.populate_public_data`()
BEGIN
  INSERT INTO `${project_id}.${dataset_id}.shakespeare_sample` (word, word_count, corpus, corpus_date)
  SELECT word, word_count, corpus, corpus_date 
  FROM `bigquery-public-data.samples.shakespeare` 
  LIMIT 1000;
END;--procedure that loads the data