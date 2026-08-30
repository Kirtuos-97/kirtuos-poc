CREATE OR REPLACE TABLE `${project_id}.${dataset_id}.shakespeare_sample` (
  word STRING NOT NULL,
  word_count INT64 NOT NULL,
  corpus STRING NOT NULL,
  corpus_date INT64 NOT NULL
);--table query