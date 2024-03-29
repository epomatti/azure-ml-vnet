variable "location" {
  type    = string
  default = "eastus2"
}

variable "workload" {
  type    = string
  default = "litware"
}

variable "allowed_ip_address" {
  type = string
}

### AML ###
variable "mlw_instance_create_flag" {
  type = bool
}

variable "mlw_instance_vm_size" {
  type = string
}

variable "mlw_instance_ssh_public_key_rel_path" {
  type = string
}

### MSSQL ###
variable "mssql_sku" {
  type = string
}

variable "mssql_max_size_gb" {
  type = number
}

variable "mssql_admin_login" {
  type = string
}

variable "mssql_admin_login_password" {
  type = string
}

### Virtual Machine ###
variable "vm_size" {
  type = string
}

variable "vm_image_sku" {
  type = string
}

variable "vm_password" {
  type      = string
  sensitive = true
}

### Entra ID ###
variable "entraid_tenant_domain" {
  type = string
}

variable "entraid_data_scientist_username" {
  type = string
}

variable "entraid_data_scientist_password" {
  type      = string
  sensitive = true
}
