variable "instance_type" {
  description = "This is the instance type"
  type = string
  default = "t2.micro"
}

variable "instance_name" {
  description = "This is the instance name"
  type = string
  default = "learn-terraform-on-aws"
}