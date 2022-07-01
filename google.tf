provider "google" {
  project = var.google_provider_project
  # region  = var.google_provider_region
}

data "google_compute_regions" "available" {
}

resource "random_shuffle" "google_regions" {
  input        = data.google_compute_regions.available.names
  result_count = 1
}

data "google_compute_zones" "available" {
  region = random_shuffle.google_regions.result[0]
}

resource "random_shuffle" "google_zones" {
  input = data.google_compute_zones.available.names
}
resource "google_compute_instance" "google_vault" {
  name         = "google-vault-${count.index}"
  hostname     = "google-vault-${count.index}.google.cloud"
  machine_type = var.google_instance_machine_type
  count        = var.google_instance_count
  zone         = random_shuffle.google_zones.result[count.index]
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

  metadata_startup_script = file("${path.module}/install.sh")
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
  target_tags   = var.google_instance_tags
}
