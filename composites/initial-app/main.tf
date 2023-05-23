terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

// terraform restriction: no variable sources, may need to us some wrapper script or terragrunt in future
module "security_group_http_ingress" {
  source = "github.com/SHerlihy/terraform-aws-modules//security_groups/single_ingress_all_egress?ref=v0.0.1"

  name      = "http_in_all_out"
  open_port = var.http_open
}

module "lb_http" {
  source = "github.com/SHerlihy/terraform-aws-modules//load_balancer?ref=v0.0.1"

  open_port          = var.http_open
  subnet_ids         = var.subnet_ids
  security_group_ids = [module.security_group_http_ingress.module_security_group_id]
}

resource "aws_launch_template" "launch_1" {
  image_id = "ami-04798a7880b63c836"
  #  image_id        = data.hcp_packer_image.ubuntu-aws-eu-west.cloud_image_id 
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.security_group_http_ingress.module_security_group_id]

  # user_data = filebase64("./user_data.sh")
}


resource "aws_autoscaling_group" "group_1" {
  vpc_zone_identifier = var.subnet_ids

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
