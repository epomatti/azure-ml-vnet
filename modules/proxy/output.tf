output "public_ip_address" {
  value = azurerm_public_ip.main.ip_address
}

output "username" {
  value = local.username
}
