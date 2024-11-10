variable "vbname" {
  default = "free"
}
variable "enable_public_ip" {
  type = bool
}

###create a resource group 
resource "azurerm_resource_group" "test4" {
  name     = "rg-${var.vbname}"
  location = "Central India"
}

###create a virtual netowrk
resource "azurerm_virtual_network" "vnet" {
  name                = "$vnet-var.vbname"
  location            = azurerm_resource_group.test4.location
  resource_group_name = azurerm_resource_group.test4.name
  address_space       = ["10.0.1.0/16"]
}

###create a subnet
resource "azurerm_subnet" "snet" {
  name                 = "$snet-var.vbname"
  resource_group_name  = azurerm_resource_group.test4.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

###create a public IP
resource "azurerm_public_ip" "pip" {
  count               = var.enable_public_ip ? 1 : 0
  name                = "$pip-{var.vbname}"
  location            = azurerm_resource_group.test4.location
  resource_group_name = azurerm_resource_group.test4.name
  allocation_method   = "Static"
}

###create a network interface
resource "azurerm_network_interface" "nic" {
  name                = "$nic-{var.vbname}"
  location            = azurerm_resource_group.test4.location
  resource_group_name = azurerm_resource_group.test4.name

  ip_configuration {
    name                          = "configuration1"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.enable_public_ip ? azurerm_public_ip.pip[0].id : null
  }
}

###create a virtual machine
resource "azurerm_virtual_machine" "vm" {
  name                  = "$vm-{var.vbname}"
  location              = azurerm_resource_group.test4.location
  resource_group_name   = azurerm_resource_group.test4.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}
