provider "azurerm" {
  features {}
}

data "template_file" "vault_install" {
  template = file("${path.module}/install.sh")
}

resource "azurerm_virtual_network" "vault_virtual_network" {
  name                = "vault-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.azure_resource_group_location
  resource_group_name = var.azure_resource_group_name
}

resource "azurerm_subnet" "vault_subnet" {
  name                 = "internal"
  resource_group_name  = var.azure_resource_group_name
  virtual_network_name = azurerm_virtual_network.vault_virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "azure_vault_public_ip" {
  name                = "vault_public_ip-${count.index}"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_resource_group_location
  allocation_method   = "Dynamic"
  count               = var.vault_instance_count
}

resource "azurerm_network_interface" "vault_nic" {
  name                = "vault-nic-${count.index}"
  location            = var.azure_resource_group_location
  resource_group_name = var.azure_resource_group_name
  count               = var.vault_instance_count

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vault_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azure_vault_public_ip[count.index].id
  }
}

resource "azurerm_network_security_group" "vault_nsg" {
  name                = "vault_nsg"
  location            = var.azure_resource_group_location
  resource_group_name = var.azure_resource_group_name

  security_rule {
    name                       = "allow_vault_sg"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8200-8201"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_ssh_sg"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.vault_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.vault_nsg.id
  count                     = var.vault_instance_count
}

resource "azurerm_linux_virtual_machine" "azure_vault" {
  name                = "azure-vault-${count.index}"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_resource_group_location
  size                = var.azure_instance_machine_type
  admin_username      = var.ssh_user
  custom_data         = base64encode(data.template_file.vault_install.rendered)
  count               = var.vault_instance_count

  network_interface_ids = [
    azurerm_network_interface.vault_nic[count.index].id,
  ]

  source_image_reference {
    offer     = var.azure_instance_image_offer
    publisher = var.azure_instance_image_publisher
    sku       = var.azure_instance_image_sku
    version   = var.azure_instance_image_version
  }

  admin_ssh_key {
    username   = var.ssh_user
    public_key = file(var.ssh_pub_key_file)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

}
