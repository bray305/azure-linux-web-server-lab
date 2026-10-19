terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}
variable "resource_group_name" {
  type    = string
  default = "rg-terraform-lab-02"
}
variable "location" {
  type    = string
  default = "eastus"
}

resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "Learning"
    Project     = "Terraform-Lab-02"
    Owner       = "Braynon"
    Purpose     = "Cloud engineering practice"
  }
}

resource "azurerm_virtual_network" "lab" {
  name                = "vnet-terraform-lab-02"
  location            = var.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = ["10.20.0.0/16"]

}
resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.20.1.0/24"]
}
resource "azurerm_network_security_group" "app" {
  name                = "nsg-app"
  location            = var.location
  resource_group_name = azurerm_resource_group.lab.name
}
resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}
resource "azurerm_network_security_rule" "ssh" {
  name                        = "Allow-SSH-MyIP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "198.160.135.170/32"
  destination_address_prefix  = "10.20.1.0/24"
  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.app.name
}
resource "azurerm_network_security_rule" "http" {
  name                        = "Allow-HTTP-MyIP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "198.160.135.170/32"
  destination_address_prefix  = "10.20.1.0/24"
  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.app.name
}
resource "azurerm_public_ip" "app" {
  name                = "pip-app"
  location            = var.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"

}

resource "azurerm_network_interface" "app" {
  name                = "nic-app"
  location            = var.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app.id
  }
}
resource "azurerm_linux_virtual_machine" "app" {
  name                = "vm-app"
  resource_group_name = azurerm_resource_group.lab.name
  location            = var.location
  size                = "Standard_D2s_v4"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.app.id
  ]
  disable_password_authentication = true
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("C:/Users/brayn/.ssh/azure_lab.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

output "resource_group_name" {
  value = azurerm_resource_group.lab.name
}

