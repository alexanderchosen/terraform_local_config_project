# Terraform Local Infrastructure Configuration Generator
A Terraform project that generates a local application configuration bundle — `config/`, `secrets/`, and `reports/` — entirely on disk, using the `local` and `random` providers. No cloud account or credentials required to run this.

## What it does

Running `terraform apply` produces:

```
project/
├── config/
│   ├── app.conf
│   └── database.conf
├── secrets/
│   └── db_password.txt
└── reports/
    └── deployment_report.txt
```

## File-by-file breakdown

### `providers.tf`

Declares which Terraform providers this project needs, and pins their version ranges:

- **`hashicorp/local`** — lets Terraform create and read files on the local filesystem. This is the mechanism behind every generated file in `config/`, `secrets/`, and `reports/`.
- **`hashicorp/random`** — lets Terraform generate random values (a password, a hex suffix, a 3-digit number) without any external service call.

Both provider blocks are left empty (`provider "local" {}`) because neither needs credentials, a region, or any other configuration — unlike a cloud provider block, which would need an access key and region.

### `variables.tf`

Declares the project's **inputs** — the contract for what values this configuration accepts, their types, and (where sensible) defaults.Contains things like `username`, `environment`, `db_user`, `db_port`, and `file_content`. No actual values live here — only names, types, and descriptions.

### `terraform.tfvars`

Supplies the **actual values** for the variables declared in `variables.tf`. `terraform.tfvars` is Terraform's default variable
filename, so it's loaded automatically on `plan`/`apply` — no `-var-file` flag needed. Keeping this separate from `variables.tf` means the same variable *contract* could be reused with different value files for different environments.

### `data.tf`

Declares a **data source** — something Terraform *reads*, not creates. `data "local_file" "config_header"` reads `templates/header.txt`, a static banner file checked into the repo.
This is different from a `resource "local_file"` block: a `resource` is created and destroyed by Terraform; a `data` source is expected to already exist and is only ever read.

### `templates/footer.txt`

The plain-text file the data source above reads. A short "auto-generated, do not edit manually" banner that gets prepended into the generated config files.

### `locals.tf`

Holds **computed values** — things built by combining variables and resource attributes, rather than supplied directly by the user:

- `filename` — `${var.username}_${random_id.random_suffix.hex}_${var.environment}`, a unique composed identifier.
- `user_id` — the first 3 letters of `var.username` joined with a 3-digit random number from `random_integer.random_numbers.result`.
- `app_name` — `var.username` combined with `local.user_id`.
- `db_name` — `local.app_name` with `"DB"` appended.

Locals exist because these values depend on resources that only get their real values *during* apply (like the random suffix) — they can't be plain variable defaults, since a variable default has to be knowable before any provider even runs.


## Concept-to-code map

| Requirement | Where it's implemented |
|---|---|
| Input variables | `variables.tf` |
| `.tfvars` values | `terraform.tfvars` |
| Variable referencing | `var.username`, `var.environment`, etc. throughout `locals.tf` / `main.tf` |
| Resource attributes | `random_password.db_password.result`, `random_id.random_suffix.hex`, `random_integer.random_numbers.result` |
| Implicit dependency | `local_file.db_password_file` references `random_password.db_password.result` directly — Terraform infers ordering |
| Explicit dependency | `local_file.deployment_report` — `depends_on = [local_file.db_password_file]` |
| Multiple providers | `hashicorp/local` + `hashicorp/random` (`providers.tf`) |
| Locals | `locals.tf` — `filename`, `user_id`, `app_name`, `db_name`, `db_user` |
| Lifecycle rules | see relevant `resource` blocks in `main.tf` |
| Data source | `data "local_file" "page_footer"` (`data.tf`) |


## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Submission

- Terraform apply screenshot: `screenshots/terraform-apply.png`
- Terraform plan screenshot: `screenshots/terraform_plan.png`
- Terraform app_config screenshot: `screenshots/terraform-plan.png`
- My locals file screenshot: `screenshots/locals.tf.png`
- My database config screenshot: `screenshots/database_conf.png`

