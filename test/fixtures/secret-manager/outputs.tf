output "project_id" {
  value       = var.project_id
  description = "The project ID"
}

output "project_number" {
  value       = data.google_project.project.number
  description = "The project Number"
}

output "secret_names" {
  value       = module.example.secret_names
  description = "The names of the Secrets created"
}