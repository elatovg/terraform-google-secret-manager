resource "random_id" "random_topic_id_suffix" {
  byte_length = 2
}

resource "google_pubsub_topic" "secret" {
  project = var.project_id
  name    = "topic-${random_id.random_topic_id_suffix.hex}"
}

resource "google_project_service_identity" "secretmanager_identity" {
  provider = google-beta
  project  = var.project_id
  service  = "secretmanager.googleapis.com"
}

resource "google_pubsub_topic_iam_member" "sm_sa_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_project_service_identity.secretmanager_identity.email}"
  topic   = google_pubsub_topic.secret.name
}

module "secret-manager" {
  source     = "../../"
  project_id = var.project_id
  secrets = [
    {
      name                     = "secret-1"
      automatic_replication    = true
      user_managed_replication = null
      labels                   = null
      topics = [
        {
          name = google_pubsub_topic.secret.id
        }
      ]
      rotation = {
        next_rotation_time = "2024-10-02T15:01:23Z"
        rotation_period    = "31536000s"
      }
      secret_data = "secret information"
    },
  ]
  add_kms_permissions    = []
  add_pubsub_permissions = []
  depends_on = [
    google_pubsub_topic_iam_member.sm_sa_publisher
  ]
}