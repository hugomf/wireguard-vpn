provider "azurerm" {
  features {}
  subscription_id = "90304110-f6ea-4939-a0a9-3cd8ca58309f"
}

resource "azurerm_resource_group" "vpn_rg" {
  name     = "wireguard-vpn-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vpn-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vpn_rg.location
  resource_group_name = azurerm_resource_group.vpn_rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "vpn-subnet"
  resource_group_name  = azurerm_resource_group.vpn_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "vpn-nsg"
  location            = azurerm_resource_group.vpn_rg.location
  resource_group_name = azurerm_resource_group.vpn_rg.name

  security_rule {
    name                       = "Allow-WireGuard"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "51820"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_public_ip" "public_ip" {
  name                = "vpn-public-ip"
  location            = azurerm_resource_group.vpn_rg.location
  resource_group_name = azurerm_resource_group.vpn_rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "vpn-nic"
  location            = azurerm_resource_group.vpn_rg.location
  resource_group_name = azurerm_resource_group.vpn_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vpn_vm" {
  name                = "wireguard-vpn-vm"
  resource_group_name = azurerm_resource_group.vpn_rg.name
  location            = azurerm_resource_group.vpn_rg.location
  # size                = "Standard_B1s"
  size                = "Standard_D2ps_v5" # ARM-compatible VM size

  admin_username      = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    # sku       = "20_04-lts-gen2"
    sku       = "20_04-lts-arm64"
    version   = "latest"
  }
}

output "public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
  description = "The public IP address of the VPN VM."
}
