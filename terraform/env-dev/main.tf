module "this-poc" {
  source               = "../modules/terraform-ci-poc"
  repository_uri       = "653090749433.dkr.ecr.eu-west-1.amazonaws.com/terraform-ci-poc"
  private_subnet_count = "3"
}
