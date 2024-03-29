terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.96.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.47.0"
    }
  }
}

resource "random_string" "affix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

locals {
  affix                = random_string.affix.result
  ssh_public_key       = file("${path.module}/${var.mlw_instance_ssh_public_key_rel_path}")
  allowed_ip_addresses = [var.allowed_ip_address]
}

resource "azurerm_resource_group" "default" {
  name     = "rg-${var.workload}-${local.affix}"
  location = var.location
}

module "vnet" {
  source              = "./modules/vnet"
  workload            = var.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  allowed_ip_address  = var.allowed_ip_address
}

module "monitor" {
  source              = "./modules/monitor"
  workload            = var.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
}

module "storage" {
  source              = "./modules/storage"
  workload            = "${var.workload}${local.affix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  ip_network_rules    = local.allowed_ip_addresses
}

module "keyvault" {
  source               = "./modules/keyvault"
  workload             = "${var.workload}${local.affix}"
  resource_group_name  = azurerm_resource_group.default.name
  location             = azurerm_resource_group.default.location
  allowed_ip_addresses = local.allowed_ip_addresses
}

module "cr" {
  source              = "./modules/cr"
  workload            = "${var.workload}${local.affix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  allowed_ip_address  = var.allowed_ip_address
}

module "entra_service_principal" {
  source   = "./modules/entra/service-principal"
  workload = var.workload
}

module "entra_users" {
  source                  = "./modules/entra/users"
  tenant_domain           = var.entraid_tenant_domain
  data_scientist_username = var.entraid_data_scientist_username
  data_scientist_password = var.entraid_data_scientist_password
}

module "data_lake" {
  source                                 = "./modules/datalake"
  workload                               = "${var.workload}${local.affix}"
  resource_group_name                    = azurerm_resource_group.default.name
  location                               = azurerm_resource_group.default.location
  ip_network_rules                       = local.allowed_ip_addresses
  datastores_service_principal_object_id = module.entra_service_principal.service_principal_object_id
}

module "mssql" {
  source              = "./modules/mssql"
  workload            = var.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  sku                      = var.mssql_sku
  max_size_gb              = var.mssql_max_size_gb
  admin_login              = var.mssql_admin_login
  admin_login_password     = var.mssql_admin_login_password
  localfw_start_ip_address = var.allowed_ip_address
  localfw_end_ip_address   = var.allowed_ip_address
}



module "ml_workspace" {
  source              = "./modules/ml/workspace"
  workload            = "${var.workload}${local.affix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  application_insights_id = module.monitor.application_insights_id
  storage_account_id      = module.storage.storage_account_id
  key_vault_id            = module.keyvault.key_vault_id
  container_registry_id   = module.cr.id

  data_lake_id = module.data_lake.id
}

module "private_endpoints" {
  source                      = "./modules/private-endpoints"
  resource_group_name         = azurerm_resource_group.default.name
  location                    = azurerm_resource_group.default.location
  vnet_id                     = module.vnet.vnet_id
  private_endpoints_subnet_id = module.vnet.private_endpoints_subnet_id

  aml_workspace_id             = module.ml_workspace.aml_workspace_id
  container_registry_id        = module.cr.id
  keyvault_id                  = module.keyvault.key_vault_id
  aml_storage_account_id       = module.storage.storage_account_id
  data_lake_storage_account_id = module.data_lake.id
  sql_server_id                = module.mssql.server_id
}

module "ml_compute" {
  source   = "./modules/ml/compute"
  count    = var.mlw_instance_create_flag ? 1 : 0
  location = azurerm_resource_group.default.location

  machine_learning_workspace_id = module.ml_workspace.aml_workspace_id
  instance_vm_size              = var.mlw_instance_vm_size
  ssh_public_key                = local.ssh_public_key
  training_subnet_id            = module.vnet.training_subnet_id

  depends_on = [module.private_endpoints]
}

module "vm" {
  source              = "./modules/vm"
  workload            = var.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  size                = var.vm_size
  image_sku           = var.vm_image_sku
  subnet              = module.vnet.bastion_subnet_id
  password            = var.vm_password
}

module "datascientist_permissions" {
  source            = "./modules/permissions"
  user_object_id    = module.entra_users.data_scientist_user_object_id
  resource_group_id = azurerm_resource_group.default.id
}
