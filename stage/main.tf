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

module "lb_1" {
  source = "../modules/load_balancer"

  http_open             = var.http_open
  lb_security_group_ids = [aws_security_group.alb.id]

}


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

resource "aws_security_group" "http" {
  name = "allow_http"

  ingress {
    description = "allow http on ${var.http_open}"
    from_port   = var.http_open
    to_port     = var.http_open
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "launch_1" {
  image_id = "ami-04798a7880b63c836"
  #  image_id        = data.hcp_packer_image.ubuntu-aws-eu-west.cloud_image_id 
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.http.id]

  # user_data = filebase64("./user_data.sh")
}


resource "aws_security_group" "alb" {
  name = "lb_1_security_group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_autoscaling_group" "group_1" {
  vpc_zone_identifier = data.aws_subnets.default.ids

  target_group_arns = [module.lb_1.target_group_arn]
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

output "alb_dns" {
  value = module.lb_1.load_balancer_dns
  }
