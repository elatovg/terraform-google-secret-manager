resource "random_id" "random_suffix" {
  byte_length = 2
}
resource "google_kms_key_ring" "key_ring_east" {
  name     = "key-ring-east-${random_id.random_suffix.hex}"
  location = "us-east1"
  project  = var.project_id
}

resource "google_kms_crypto_key" "crypto_key_east" {
  name     = "crypto-key-${random_id.random_suffix.hex}"
  key_ring = google_kms_key_ring.key_ring_east.id
}

resource "google_kms_key_ring" "key_ring_central" {
  name     = "key-ring-central-${random_id.random_suffix.hex}"
  location = "us-central1"
  project  = var.project_id
}

resource "google_kms_crypto_key" "crypto_key_central" {
  name     = "crypto-key-${random_id.random_suffix.hex}"
  key_ring = google_kms_key_ring.key_ring_central.id
}

resource "google_pubsub_topic" "secret_topic_1" {
  project = var.project_id
  name    = "topic-1-${random_id.random_suffix.hex}"
}

resource "google_pubsub_topic" "secret_topic_2" {
  project = var.project_id
  name    = "topic-2-${random_id.random_suffix.hex}"
}

module "secret-manager" {
  source     = "../../"
  project_id = var.project_id
  secrets = [
    {
      name                  = "secret_1"
      automatic_replication = null
      user_managed_replication = [
        {
          location     = "us-east1"
          kms_key_name = google_kms_crypto_key.crypto_key_east.id
        },
        {
          location     = "us-central1"
          kms_key_name = google_kms_crypto_key.crypto_key_central.id
        }
      ]
      labels = {
        key1 : "value1",
        key2 : "value2"
      }
      topics = [
        {
          name = google_pubsub_topic.secret_topic_1.id
        },
        {
          name = google_pubsub_topic.secret_topic_2.id
        }
      ]
      rotation = {
        next_rotation_time = "2024-10-02T15:01:23Z"
        rotation_period    = "31536000s"
      }
      secret_data = "my_secret"
    },
    {
      name                     = "secret_2"
      automatic_replication    = true
      user_managed_replication = null
      labels                   = null
      topics                   = null
      rotation                 = null
      secret_data              = "my_secret2"
    },
    {
      name                  = "secret_3"
      automatic_replication = null
      user_managed_replication = [
        {
          location     = "us-central1"
          kms_key_name = google_kms_crypto_key.crypto_key_central.id
        },
      ]
      labels      = null
      topics      = null
      rotation    = null
      secret_data = "my_secret2"
    }
  ]
  add_kms_permissions = [
    google_kms_crypto_key.crypto_key_east.id,
    google_kms_crypto_key.crypto_key_central.id
  ]
  add_pubsub_permissions = [
    google_pubsub_topic.secret_topic_1.id,
    google_pubsub_topic.secret_topic_2.id
  ]
}