provider "aws" {
  region = "eu-west-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "initial_app" {
  source = "../composites/initial-app"

  http_open       = 80
  subnet_ids      = data.aws_subnets.default.ids
  instance_type   = "t2.micro"
}
