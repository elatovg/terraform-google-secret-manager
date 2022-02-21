# locals {
#   kms_keys = flatten([
#     for secret in var.secrets : [
#       for replication in secret.user_managed_replication : [
#         replication.kms_key_name
#       ] if lookup(replication, "kms_key_name", null) != null
#     ] if lookup(secret, "user_managed_replication", null) != null
#   ])
#   pubsub_topics = flatten([
#     for secret in var.secrets : [
#       for topic in secret.topics : [
#         topic.name
#       ] if lookup(topic, "name", null) != null
#     ] if lookup(secret, "topics", null) != null
#   ])
# }

resource "google_project_service_identity" "secretmanager_identity" {
  count    = length(var.add_kms_permissions) > 0 || length(var.add_pubsub_permissions) > 0 ? 1 : 0
  provider = google-beta
  project  = var.project_id
  service  = "secretmanager.googleapis.com"
}

resource "google_kms_crypto_key_iam_member" "sm_sa_encrypter_decrypter" {
  # for_each      = toset(var.add_kms_permissions)
  count         = var.add_kms_permissions != null ? length(var.add_kms_permissions) : 0
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.secretmanager_identity[0].email}"
  crypto_key_id = var.add_kms_permissions[count.index]
}

resource "google_pubsub_topic_iam_member" "sm_sa_publisher" {
  project = var.project_id
  # for_each = toset(var.add_pubsub_permissions)
  count  = var.add_pubsub_permissions != null ? length(var.add_pubsub_permissions) : 0
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_project_service_identity.secretmanager_identity[0].email}"
  # topic    = each.value
  topic = var.add_pubsub_permissions[count.index]
}

resource "google_secret_manager_secret" "secrets" {
  project   = var.project_id
  for_each  = { for secret in var.secrets : secret.name => secret }
  secret_id = each.value.name
  replication {
    automatic = each.value.automatic_replication != null ? each.value.automatic_replication : null
    dynamic "user_managed" {
      for_each = each.value.user_managed_replication != null ? [1] : []
      content {
        dynamic "replicas" {
          for_each = lookup(each.value, "user_managed_replication", [])
          content {
            location = replicas.value.location
            dynamic "customer_managed_encryption" {
              for_each = replicas.value.kms_key_name != null ? [replicas.value.kms_key_name] : []
              content {
                kms_key_name = customer_managed_encryption.value
              }
            }
          }
        }
      }
    }
  }
  labels = each.value.labels != null ? each.value.labels : null
  dynamic "topics" {
    for_each = lookup(each.value, "topics") == null ? [] : lookup(each.value, "topics")
    content {
      name = topics.value.name
    }
  }
  dynamic "rotation" {
    for_each = lookup(each.value, "rotation") == null ? [] : [each.value.rotation]
    content {
      next_rotation_time = rotation.value.next_rotation_time
      rotation_period    = rotation.value.rotation_period
    }
  }
  depends_on = [
    google_kms_crypto_key_iam_member.sm_sa_encrypter_decrypter,
    google_pubsub_topic_iam_member.sm_sa_publisher
  ]
}

resource "google_secret_manager_secret_version" "secret-version" {
  for_each    = { for secret in var.secrets : secret.name => secret }
  secret      = google_secret_manager_secret.secrets[each.value.name].id
  secret_data = each.value.secret_data
}