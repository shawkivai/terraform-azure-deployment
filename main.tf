# Configure the Azure provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "rg-${var.project_name}-MAS"
  location = var.region
}

# Create a virtual network
resource "azurerm_virtual_network" "example" {
  name                = "${var.project_name}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Create a subnet
resource "azurerm_subnet" "example" {
  name                 = "${var.project_name}-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a public IP address
resource "azurerm_public_ip" "example" {
  name                = "${var.project_name}-public-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
}

# Create a network interface
resource "azurerm_network_interface" "example" {
  name                      = "${var.project_name}-network-interface"
  location                  = azurerm_resource_group.example.location
  resource_group_name       = azurerm_resource_group.example.name


  ip_configuration {
    name                          = "${var.project_name}-ip-configuration"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

# Create a virtual machine
resource "azurerm_virtual_machine" "example" {
  name                  = "vm-${var.vm_name}-${var.vm_postfix}"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = var.vm_size

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.vm_name}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "vm-${var.vm_name}-${var.vm_postfix}"
    admin_username = var.admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
     ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = file("~/.ssh/vm-azure-ssh-key.pub")
    }
  }

  tags = {
    environment = var.enverionment
    project     = var.project_name
  }
}

resource "azurerm_private_dns_zone" "example" {
  name                = "example.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "exampleVnetZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.example.id
  resource_group_name   = azurerm_resource_group.example.name
}
resource "azurerm_mysql_flexible_server" "example" {
  name                = "db-${var.project_name}-eu2-mas"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location  
  administrator_login    = var.db_username
  administrator_password = var.db_password
  sku_name   = "B_Standard_B1ms"
  backup_retention_days  = 7
  private_dns_zone_id    = azurerm_private_dns_zone.example.id

  depends_on = [azurerm_private_dns_zone_virtual_network_link.example]
  tags = {
    environment = "production"
  }
}