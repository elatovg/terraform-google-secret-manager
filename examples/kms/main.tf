resource "google_kms_key_ring" "key_ring" {
  name     = "key-ring-crqjhk"
  location = var.region
  project  = var.project_id
}

resource "google_kms_crypto_key" "crypto_key" {
  name     = "crypto-key-ra8hst"
  key_ring = google_kms_key_ring.key_ring.id
}

resource "google_project_service_identity" "secretmanager_identity" {
  provider = google-beta
  project  = var.project_id
  service  = "secretmanager.googleapis.com"
}

resource "google_kms_crypto_key_iam_member" "sm_sa_encrypter_decrypter" {
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.secretmanager_identity.email}"
  crypto_key_id = google_kms_crypto_key.crypto_key.id
}

module "secretmanager" {
  source     = "../../"
  project_id = var.project_id
  secrets = [
    {
      name                  = "secret-1"
      automatic_replication = null
      user_managed_replication = [
        {
          location     = var.region
          kms_key_name = google_kms_crypto_key.crypto_key.id
        },
      ]
      labels      = null
      topics      = null
      rotation    = null
      secret_data = "secret information"
    },
  ]
  add_kms_permissions    = []
  add_pubsub_permissions = []
  depends_on = [
    google_kms_crypto_key_iam_member.sm_sa_encrypter_decrypter
  ]
}