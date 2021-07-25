variable "db_configuration" {
  type = object({name=string})
  default = {
    "name" = "radu-db"
  }
}


variable "db_instance_configuration" {
  type = object({name=string, tier=string, version=string, region=string, backup_configuration_enabled=bool, disk_size=number, disk_type=string})
  default = {
    "name" = "radu-instance-db"
    "tier" = "db-f1-micro"
    "version" = "POSTGRES_13"
    "region" = "europe-west1"
    "backup_configuration_enabled" = false
    "disk_size" = 10
    "disk_type" = "PD_SSD"
  }
}

variable "pub_sub" {
  type = object({name=string})
  default = {
    "name" = "say-hello-world"
  }
}

variable "task_queue" {
  type = object({name=string, location=string, retry_attempts=number, concurrent_dispatches=number})
  default = {
    name = "radu-queue"
    location = "europe-west1"
    retry_attempts = 5
    concurrent_dispatches =2
  }
}

variable "bucket" {
  type = object({name=string,})
  default = {
    name = "trial_bucket_terraform"
  }
}

variable "function_config" {
  type = object({name=string, description=string, runtime=string, region=string, event_type=string})
  default = {
    name = "hello_world",
    description="Pub Sub Function",
    runtime = "python37"
    region = "europe-west1"
    event_type= "google.pubsub.topic.publish"
  }
}