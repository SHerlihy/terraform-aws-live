variable "http_open" {
  type = number
}

variable "subnet_ids" {
  type = list(string)
}

variable "instance_type" {
  default = "t2.micro"
}

