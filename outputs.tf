output "google_vault_adddresses" {
  value = formatlist(
    "%s: %s",
    google_compute_instance.google_vault[*].hostname,
    google_compute_instance.google_vault[*].network_interface.0.access_config.0.nat_ip
  )
}

output "azure_vault_adddresses" {
  value = formatlist(
    "%s: %s",
    azurerm_linux_virtual_machine.azure_vault[*].name,
    azurerm_linux_virtual_machine.azure_vault[*].public_ip_address
  )
}
