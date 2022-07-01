provider "google" {
  project = var.google_provider_project
  region  = var.google_provider_region
  zone    = var.google_provider_zone
}

resource "google_compute_instance" "google_vault" {
  name         = "vault-enterprise-${count.index}"
  hostname     = "google_vault-${count.index}"
  machine_type = var.google_instance_machine_type
  count        = var.google_instance_count
  zone         = var.google_instance_zones[count.index]
  boot_disk {
    initialize_params {
      image = var.google_instance_image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"
  }

  metadata_startup_script = "sudo apt-get update && sudo apt-get install gpg -y && wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null && echo 'deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main' | sudo tee /etc/apt/sources.list.d/hashicorp.list && sudo apt install vault-enterprise -y"
  tags                    = var.google_instance_tags
}

resource "google_compute_firewall" "vault-server" {
  name    = "default-allow-vault-terraform"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = var.vault_tcp_ports
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["vault"]
}
