output "google_vault_adddresses" {
  value = formatlist(
    "%s: %s",
    google_compute_instance.google_vault[*].hostname,
    google_compute_instance.google_vault[*].network_interface.0.access_config.0.nat_ip
  )
}
