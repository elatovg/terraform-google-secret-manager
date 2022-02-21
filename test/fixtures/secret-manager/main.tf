data "google_project" "project" {
  project_id = var.project_id
}

module "example" {
  source     = "../../../examples/simple"
  project_id = data.google_project.project.project_id
}
