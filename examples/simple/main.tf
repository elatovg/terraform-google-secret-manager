module "secretmanager" {
  source     = "../../"
  project_id = var.project_id
  secrets = [
    {
      name                     = "secret-1"
      automatic_replication    = true
      user_managed_replication = null
      labels                   = null
      topics                   = null
      rotation                 = null
      secret_data              = "secret information"
    },
  ]
}