# --- Dynamic Tables (SQL DDL) ---
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
  }
}

# --- Dynamic Procedures (SQL DDL) ---
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
  }

  # Forces Terraform to create tables before compiling procedures
  depends_on = [google_bigquery_job.execute_table_ddl]
}