variable "project_id" {
  type        = string
  description = "The project ID to manage the Pub/Sub resources"
}

variable "secrets" {
  type = list(object({
    name                  = string
    automatic_replication = bool
    user_managed_replication = list(object({
      location     = string
      kms_key_name = string
    }))
    labels = map(string)
    topics = list(object({
      name = string
    }))
    rotation = object({
      next_rotation_time = string
      rotation_period    = string
    })
    secret_data = string
  }))
  description = "The list of the secrets"
  default     = []
}

variable "add_kms_permissions" {
  type = list(string)
}

variable "add_pubsub_permissions" {
  type = list(string)
}