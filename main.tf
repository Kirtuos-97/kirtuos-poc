provider "google" {
  project = var.project_id
  region  = "asia-south1"
}

resource "google_bigquery_dataset" "poc_dataset" {
  dataset_id                 = "poc_dataset"
  location                   = "US"
  delete_contents_on_destroy = true
}

# --- Dynamic Tables ---
locals {
  # Scans the 'tables' folder for all .json files
  table_files = fileset("${path.module}/tables", "*.json")
}

resource "google_bigquery_table" "dynamic_tables" {
  for_each = local.table_files

  dataset_id = google_bigquery_dataset.poc_dataset.dataset_id
  
  # Removes the .json extension to generate the table name (e.g., "shakespeare_sample")
  table_id   = replace(each.value, ".json", "")
  
  # Reads the specific JSON file for this loop iteration
  schema     = file("${path.module}/tables/${each.value}")
}

# --- Dynamic Procedures ---
locals {
  # Scans the 'procedures' folder for all .sql files
  procedure_files = fileset("${path.module}/procedures", "*.sql")
}

resource "google_bigquery_routine" "dynamic_procedures" {
  for_each = local.procedure_files

  dataset_id      = google_bigquery_dataset.poc_dataset.dataset_id
  
  # Removes the .sql extension to generate the procedure name (e.g., "populate_public_data")
  routine_id      = replace(each.value, ".sql", "")
  
  routine_type    = "PROCEDURE"
  language        = "SQL"
  
  # Reads the specific SQL file for this loop iteration
  definition_body = file("${path.module}/procedures/${each.value}")
}