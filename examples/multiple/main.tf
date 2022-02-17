module "secretmanager" {
  source                 = "../../"
  project_id             = var.project_id
  secrets                = var.secrets
  add_kms_permissions    = var.add_kms_permissions
  add_pubsub_permissions = var.add_pubsub_permissions
  depends_on = [
    var.add_kms_permissions,
    var.add_pubsub_permissions
  ]
}