
resource "azurerm_resource_group" "example10" {
  name     = "${var.prefix}-resources"
  location = "Eastus"
}

resource "azurerm_virtual_network" "main008" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example10.location
  resource_group_name = azurerm_resource_group.example10.name
}

resource "azurerm_subnet" "internal000" {
  name                 = "internali"
  resource_group_name  = azurerm_resource_group.example10.name
  virtual_network_name = azurerm_virtual_network.main008.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main0009" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.example10.location
  resource_group_name = azurerm_resource_group.example10.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal000.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "mainvm009" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.example10.location
  resource_group_name   = azurerm_resource_group.example10.name
  network_interface_ids = [azurerm_network_interface.main0009.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

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
  tags = {
    environment = "staging"
  }
}

