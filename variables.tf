#### GENERIC

variable "ssh_user" {
  default = "chris"
}

variable "ssh_pub_key_file" {
  default = "/Users/chris/.ssh/id_rsa.pub"
}

variable "vault_tcp_ports" {
  type    = list(string)
  default = ["8200", "8201"]
}

#### GOOGLE

variable "google_provider_project" {
  default = "chrisvmcloud"
}

variable "google_provider_region" {
  default = "europe-central2"
}

variable "google_provider_zone" {
  default = "europe-central2-a"
}

variable "google_instance_zones" {
  type    = list(string)
  default = ["europe-central2-a", "europe-central2-b", "europe-central2-c"]
}

variable "google_instance_machine_type" {
  default = "f1-micro"
}

variable "google_instance_count" {
  default = 3
}

variable "google_instance_image" {
  default = "ubuntu-os-cloud/ubuntu-minimal-2204-lts"
}

variable "google_instance_tags" {
  default = ["vault"]
}
