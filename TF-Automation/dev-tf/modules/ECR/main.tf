module "ecr" {
  source      = "./modules/ecr"
  repo_name   = "go-my-app-repo"
  environment = "Production"
}