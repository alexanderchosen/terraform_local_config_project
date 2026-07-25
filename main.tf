resource "random_id" "random_suffix"{
    byte_length = 3
}

resource "random_password" "db_password"{
    length = 16
    special = true
    override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "local_file" "db_password_file"{
    filename = "${path.module}/secrets/db_password.txt"
    content = random_password.db_password.result
}

resource "random_integer" "random_numbers"{
    min = 100
    max = 999
}

resource "local_file" "deployment_report"{
    filename = "${path.module}/reports/deployment_report.txt"
    content = <<-EOT
    username: ${var.username}
    filename: ${local.filename}
    file_content: ${var.file_content}
    user_id: ${local.user_id}
    EOT

    depends_on = [
        local_file.db_password_file
  ]
}

resource "local_file" "app_config" {
  filename = "${path.module}/config/app.conf"
  content = <<-EOT
    app_name: ${local.app_name}
    environment: ${var.environment}
  EOT
}

resource "local_file" "database_config" {
  filename = "${path.module}/config/database.conf"
  content  = <<-EOT
    db_name: ${local.db_name}
    db_user: ${local.db_user}
    db_port: ${var.db_port}
  EOT
}