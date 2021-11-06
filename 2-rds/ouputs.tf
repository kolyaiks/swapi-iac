output "db_instance_address" {
  value = module.db.db_instance_address
}

output "db_user" {
  value = var.db_user
}

output "db_password" {
  value = var.db_password
}