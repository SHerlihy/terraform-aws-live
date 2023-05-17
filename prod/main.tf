## Create local variable and get image id from the base image
## Retrieve metadata from the production image channel
#data "hcp_packer_image" "ubuntu-aws-eu-west" {
#  bucket_name    = "learn-packer-ubuntu"
#  channel        = "production"
#  cloud_provider = "aws"
#  region         = "eu-west-2"
#}

provider "aws" {
  region = "eu-west-2"
}

//module "lb_http" {
//  source = "../modules/load_balancer"
//
//  http_open             = var.http_open
//  lb_security_group_ids = [aws_security_group.alb.id]
//  subnet_ids = [aws.aws_subnets.default.ids]
//
//}


variable "http_open" {
  default = 8080
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

module "security_group_http_ingress" {
  source = "github.com/SHerlihy/terraform-aws-modules//security_groups/single_ingress_all_egress"

  name      = "http_in_all_out"
  open_port = var.http_open
}

module "lb_http" {
  source = "github.com/SHerlihy/terraform-aws-modules//load_balancer"

  open_port          = var.http_open
  subnet_ids         = data.aws_subnets.default.ids
  security_group_ids = [module.security_group_http_ingress.module_security_group_id]
}

resource "aws_launch_template" "launch_1" {
  image_id = "ami-04798a7880b63c836"
  #  image_id        = data.hcp_packer_image.ubuntu-aws-eu-west.cloud_image_id 
  instance_type          = "t2.micro"
  vpc_security_group_ids = [module.security_group_http_ingress.module_security_group_id]

  # user_data = filebase64("./user_data.sh")
}


resource "aws_autoscaling_group" "group_1" {
  vpc_zone_identifier = data.aws_subnets.default.ids

  target_group_arns = [module.lb_http.target_group_arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  launch_template {
    id      = aws_launch_template.launch_1.id
    version = "$Latest"
  }

  tag {
    key                 = "name"
    value               = "terr_asg_example"
    propagate_at_launch = true
  }
}
