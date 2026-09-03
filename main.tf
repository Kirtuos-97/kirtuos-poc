provider "google" {
  project = var.project_id
  region  = "asia-south1"
}

#dataset for raw tables and procedures
resource "google_bigquery_dataset" "poc_dataset" {
  dataset_id                 = "poc_dataset"
  location                   = "US"
  delete_contents_on_destroy = true
}

#dataset for analytics
resource "google_bigquery_dataset" "ml_analytics" {
  dataset_id = "ml_analytics"
  location="US"
  delete_contents_on_destroy = true
}

#--------------------------------------------------
# --- Dynamic Tables (SQL DDL) ---
#--------------------------------------------------
locals {
  table_files = fileset("${path.module}/code-repository/big-query/tables", "*.sql")
}

resource "google_bigquery_job" "execute_table_ddl" {
  for_each = local.table_files

  # Generates a unique Job ID based on the filename and file content
  job_id   = "table_ddl_${replace(each.value, ".sql", "")}_${md5(file("${path.module}/code-repository/big-query/tables/${each.value}"))}"
  location = google_bigquery_dataset.poc_dataset.location

  query {
    query = templatefile("${path.module}/code-repository/big-query/tables/${each.value}", {
      project_id = var.project_id
      dataset_id = google_bigquery_dataset.poc_dataset.dataset_id
    })
    use_legacy_sql = false
    # Disable default dispositions for DDL execution
    create_disposition = ""
    write_disposition  = ""
    
  }
}

#--------------------------------------------------
# --- Dynamic Procedures (SQL DDL) ---
#--------------------------------------------------

locals {
  procedure_files = fileset("${path.module}/code-repository/big-query/procedures", "*.sql")
}

resource "google_bigquery_job" "execute_procedure_ddl" {
  for_each = local.procedure_files

  # Generates a unique Job ID based on the filename and file content
  job_id   = "proc_ddl_${replace(each.value, ".sql", "")}_${md5(file("${path.module}/code-repository/big-query/procedures/${each.value}"))}"
  location = google_bigquery_dataset.poc_dataset.location

  query {
    query = templatefile("${path.module}/code-repository/big-query/procedures/${each.value}", {
      project_id = var.project_id
      dataset_id = google_bigquery_dataset.poc_dataset.dataset_id
    })
    use_legacy_sql = false
    # Disable default dispositions for DDL execution
    create_disposition = ""
    write_disposition  = ""
  }

  # Forces Terraform to create tables before compiling procedures
  depends_on = [google_bigquery_job.execute_table_ddl]
}

#--------------------------------------------------
# --- Dynamic ML Models (SQL DDL) ---
#--------------------------------------------------

locals {
  model_files = fileset("${path.module}/code-repository/big-query/models", "*.sql")
}

resource "google_bigquery_job" "execute_model_ddl" {
  for_each = local.model_files

  # Generates a unique Job ID based on the filename and file content
  job_id   = "model_ddl_${replace(each.value, ".sql", "")}_${md5(file("${path.module}/code-repository/big-query/models/${each.value}"))}"
  location = google_bigquery_dataset.poc_dataset.location

  query {
    query = templatefile("${path.module}/code-repository/big-query/models/${each.value}", {
      project_id = var.project_id
      ml_dataset_id = google_bigquery_dataset.ml_analytics.dataset_id
      dataset_id=google_bigquery_dataset.poc_dataset.dataset_id
    })
    use_legacy_sql     = false
    
    # REQUIRED FOR DDL: Disable default dispositions
    create_disposition = ""
    write_disposition  = ""
  }

  # Ensure tables exist and data is populated before training the model
  depends_on = [
    google_bigquery_job.execute_table_ddl,
    google_bigquery_job.execute_procedure_ddl
  ]
}

#--------------------------------------------------
# --- Dynamic Cloud Workflows (yaml.tftpl) ---
#--------------------------------------------------

resource "google_workflows_workflow" "parallel_bq_workflow" {
  name            = "parallel-bq-workflow"
  region          = "asia-south1"
  description     = "Workflow to run two BigQuery stored procedures in parallel"
  service_account = "bq-pipeline-sa@kirtuos-poc.iam.gserviceaccount.com"
  source_contents = templatefile("${path.module}/code-repository/cloud-workflows/parallel-bq-workflow.yaml.tftpl", {
    project_id = var.project_id
    dataset_id = google_bigquery_dataset.poc_dataset.dataset_id
  })

  depends_on = [google_bigquery_job.execute_procedure_ddl]
}

#--------------------------------------------------
# --- Cloud Scheduler Jobs ---
#--------------------------------------------------

resource "google_cloud_scheduler_job" "daily_bq_trigger" {
  name             = "bq-workflow-daily-trigger"
  region           = "asia-south1"
  schedule         = "0 6 * * *"
  time_zone        = "Asia/Kolkata"
  description      = "Triggers the BigQuery parallel workflow every day at 6 AM"

  http_target {
    http_method = "POST"
    uri         = "https://workflowexecutions.googleapis.com/v1/${google_workflows_workflow.parallel_bq_workflow.id}/executions"

    oauth_token {
      service_account_email = "bq-pipeline-sa@kirtuos-poc.iam.gserviceaccount.com"
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
    }
  }

  depends_on = [google_workflows_workflow.parallel_bq_workflow]
}
