provider "google" {
  project = var.project_id
  region  = "asia-south1"
}

resource "google_bigquery_dataset" "poc_dataset" {
  dataset_id                 = "poc_dataset"
  location                   = "asia-south1"
  delete_contents_on_destroy = true
}

resource "google_bigquery_table" "shakespeare_sample" {
  dataset_id = google_bigquery_dataset.poc_dataset.dataset_id
  table_id   = "shakespeare_sample"

  schema = <<EOF
[
  {"name": "word", "type": "STRING", "mode": "REQUIRED"},
  {"name": "word_count", "type": "INTEGER", "mode": "REQUIRED"},
  {"name": "corpus", "type": "STRING", "mode": "REQUIRED"},
  {"name": "corpus_date", "type": "INTEGER", "mode": "REQUIRED"}
]
EOF
}

resource "google_bigquery_routine" "populate_data" {
  dataset_id      = google_bigquery_dataset.poc_dataset.dataset_id
  routine_id      = "populate_public_data"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = <<-EOT
    INSERT INTO `${var.project_id}.${google_bigquery_dataset.poc_dataset.dataset_id}.${google_bigquery_table.shakespeare_sample.table_id}` (word, word_count, corpus, corpus_date)
    SELECT word, word_count, corpus, corpus_date 
    FROM `bigquery-public-data.samples.shakespeare` 
    LIMIT 1000;
  EOT
}