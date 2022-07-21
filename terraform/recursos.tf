resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "mySubnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "myNic" {
  count = length(var.vms)
  name                = "vnic-${var.vms[count.index]}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig-${var.vms[count.index]}"
    subnet_id                     = azurerm_subnet.mySubnet.id
    private_ip_address_allocation = "Dynamic" #"Static"
    #private_ip_address = "10.0.1.${count.index + 10}"
    public_ip_address_id = azurerm_public_ip.myPublicIp1[count.index].id
  }
}



resource "azurerm_public_ip" "myPublicIp1" {
  count = length(var.vms)
  name="vmip1-${var.vms[count.index]}"
  location=azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Dynamic"
  sku="Basic"
}

resource "azurerm_network_security_group" "mySecGroup" {
  count = length(var.vms)
  name="sshtraffic-${var.vms[count.index]}"
  location=azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule = [{
    access                                     = "Allow"
    description                                = "SSH Rule"
    destination_address_prefix                 = "*"
    destination_address_prefixes               = []
    destination_port_range                     = "22"
    destination_port_ranges                    = []
    direction                                  = "Inbound"
    name                                       = "SSH Rule"
    priority                                   = 1001
    protocol                                   = "Tcp"
    source_address_prefix                      = "*"
    source_address_prefixes                    = []
    source_port_range                          = "*"
    source_port_ranges                         = []
    source_application_security_group_ids      = []
    destination_application_security_group_ids = []
  }]
}

resource "azurerm_network_interface_security_group_association" "mySecGroupAssociation1" {
  count = length(var.vms)
  network_interface_id = azurerm_network_interface.myNic[count.index].id
  network_security_group_id = azurerm_network_security_group.mySecGroup[count.index].id
}

resource "azurerm_linux_virtual_machine" "vm" {
  count = length(var.vms)
  name                = "vm2-${var.vms[count.index]}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size #"Standard_F2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.myNic[count.index].id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("C:/Users/polor/Documents/Documentos/UNIR/azure/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  plan {
    name      = "centos-8-stream-free"
    product   = "centos-8-stream-free"
    publisher = "cognosys"
  }


  source_image_reference {
    publisher = "cognosys"
    offer     = "centos-8-stream-free"
    sku       = "centos-8-stream-free"
    version   = "22.03.28"
  }
}