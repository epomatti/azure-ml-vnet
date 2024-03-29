data "azuread_client_config" "current" {}

resource "azurerm_storage_account" "default" {
  name                            = "st${var.workload}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"

  # Further controlled by network_rules below
  public_network_access_enabled = true

  network_rules {
    default_action = "Deny"
    ip_rules       = var.ip_network_rules
    bypass         = ["AzureServices"]
  }

  lifecycle {
    ignore_changes = [
      network_rules[0].private_link_access
    ]
  }
}

resource "azurerm_role_assignment" "adlsv2" {
  scope                = azurerm_storage_account.default.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_client_config.current.object_id
}
