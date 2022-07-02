#### GENERIC

variable "ssh_user" {
  default = "chris"
}

variable "ssh_pub_key_file" {
  default = "/Users/chris/.ssh/id_rsa.pub"
}

variable "ssh_priv_key_file" {
  default = "/Users/chris/.ssh/id_rsa"
}

variable "vault_tcp_ports" {
  type    = list(string)
  default = ["8200", "8201"]
}

variable "vault_instance_count" {
  default = 3
}


#### GOOGLE

variable "google_provider_project" {
  default = "projectname"
}

variable "google_instance_machine_type" {
  default = "e2-micro"
}

variable "google_instance_image" {
  default = "ubuntu-os-cloud/ubuntu-minimal-2204-lts"
}

variable "google_instance_tags" {
  default = ["vault"]
}

#### AZURE

variable "azure_resource_group_name" {
  default = "resourcegroupname"
}

variable "azure_resource_group_location" {
  default = "resourcegrouplocation"
}

variable "azure_instance_machine_type" {
  default = "Standard_B1s"
}

variable "azure_instance_image_offer" {
  default = "0001-com-ubuntu-server-focal"
}

variable "azure_instance_image_publisher" {
  default = "Canonical"
}

variable "azure_instance_image_sku" {
  default = "20_04-lts-gen2"
}
variable "azure_instance_image_version" {
  default = "latest"
}


#### AWS

variable "aws_instance_type" {
  default = "t2.micro"
}
