output "secret_names" {
  value = module.secretmanager.secret_names
  description = "List of secret names"
}


