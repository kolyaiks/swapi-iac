variable "asg_desired_capacity" {
  type = number
  description = "Worker nodes quantity"
  default = 1
}

variable "instance_type" {
  type = string
  description = "Worker node instance type"
  default = "t2.small"
}