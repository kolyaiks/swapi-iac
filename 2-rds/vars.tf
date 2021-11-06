variable "db_publicly_accessible" {
  type = bool
  description = "Is DB publicly accessible?"
  default = true
}

variable "db_instance_type" {
  description = "RDS instance type"
  type = string
  default = "db.t3.micro"
}

variable "db_skip_final_snapshot" {
  type = bool
  description = "Skip creating final snapshot before delete RDS?"
  default = true
}

variable "db_multi_az" {
  type = bool
  description = "Create instances in different AZs?"
  default = false
}

variable "db_user" {
  type =string
  description = "DB user"
  default = "user"
}

variable "db_password" {
  type = string
  description = "DB password"
  default = "password"
}