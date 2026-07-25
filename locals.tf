locals {
  filename = "${var.username}_${random_id.random_suffix.hex}_${var.environment}"
  user_id = "${substr(var.username, 0, 3)}${random_integer.random_numbers.result}"
  app_name = "${var.username}_${local.user_id}"
  db_name = "${local.app_name}DB"
  db_user = "${var.username}DB"
}