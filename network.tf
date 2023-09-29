# Create a VPC
module "nginx_app_vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  name            = "new-nginx-app-vpc"
  cidr            = "10.1.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24"]
  private_subnets = ["10.1.103.0/24", "10.1.104.0/24"]

  tags = {
    Terraform = "true"
  }
}
