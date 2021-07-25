provider "google" {
  project = "linnify-learning"
}

resource "google_project_service" "cloud_sql" {
  service = "sqladmin.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}


resource "google_sql_database" "database" {
  name     = var.db_configuration.name
  instance = google_sql_database_instance.database_instance.name
  depends_on = [google_project_service.cloud_sql]
}

resource "google_sql_database_instance" "database_instance" {
  name = var.db_instance_configuration.name
  database_version = var.db_instance_configuration.version
  region = var.db_instance_configuration.region
  settings{
    tier = var.db_instance_configuration.tier
    backup_configuration {
      enabled = var.db_instance_configuration.backup_configuration_enabled
    }
    disk_size = var.db_instance_configuration.disk_size
    disk_type = var.db_instance_configuration.disk_type
  }
  deletion_protection = false
}

resource "google_pubsub_topic" "hello_topic" {
  name = var.pub_sub.name
}

resource "google_cloud_tasks_queue" "cloud_task_queue" {
  name = var.task_queue.name
  location = "europe-west1"
  rate_limits {
    max_concurrent_dispatches = var.task_queue.concurrent_dispatches
  }
  retry_config {
    max_attempts = var.task_queue.retry_attempts
  }
}

resource "google_project_service" "cloud_function" {
  service = "cloudfunctions.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "cloud_build" {
  service = "cloudbuild.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_storage_bucket" "trial_bucket_terraform" {
  name = var.bucket.name
}

resource "google_storage_bucket_object" "function_archive" {
  name = "index.zip"
  bucket = google_storage_bucket.trial_bucket_terraform.name
  source = "./user-code.zip"
}

resource "google_cloudfunctions_function" "hello_world_function" {
  name = var.function_config.name
  description = var.function_config.description
  runtime = var.function_config.runtime
  region = var.function_config.region
  available_memory_mb   = 128
  entry_point = "hello_pubsub"
  event_trigger {
    event_type = var.function_config.event_type
    resource = google_pubsub_topic.hello_topic.name
  }
  source_archive_bucket = google_storage_bucket.trial_bucket_terraform.name
  source_archive_object = google_storage_bucket_object.function_archive.name
  depends_on = [google_pubsub_topic.hello_topic]
}
