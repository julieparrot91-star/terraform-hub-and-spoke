resource "azurerm_resource_group" "hub" {
	name = var.hub_rg_name
	location = var.location
}

resource "azurerm_virtual_network" "hub" {
	name = "${var.hub_name}-vnet"
	address_space = [var.hub_cidr]
	location = azurerm_resource_group.hub.location
	resource_group_name = azurerm_resource_group.hub.name
}

resource "azurerm_subnet" "azure_firewall" {
	name = "AzureFirewallSubnet"
	resource_group_name = azurerm_resource_group.hub.name
	virtual_network_name = azurerm_virtual_network.hub.name
	address_prefixes = [var.firewall_subnet_cidr]
}

resource "azurerm_subnet" "azure_firewall_mgmt" {
	name = "AzureFirewallManagementSubnet"
	resource_group_name = azurerm_resource_group.hub.name
	virtual_network_name = azurerm_virtual_network.hub.name
	address_prefixes = ["10.0.2.0/24"]
}


resource "azurerm_public_ip" "fw_mgmt_ip" {
     name                = "${var.hub_name}-fw-mgmt-pip"
     location            = azurerm_resource_group.hub.location
     resource_group_name = azurerm_resource_group.hub.name
     allocation_method   = "Static"
     sku                 = "Standard"
}

resource "azurerm_firewall" "hub" {
	name = "${var.hub_name}-fw"
	location = azurerm_resource_group.hub.location
	resource_group_name = azurerm_resource_group.hub.name
	sku_name = "AZFW_VNet"
	sku_tier = "Basic"
	
	ip_configuration {
		name = "configuration"
		subnet_id = azurerm_subnet.azure_firewall.id
		public_ip_address_id = azurerm_public_ip.fw_ip.id
	}

	management_ip_configuration {
		name = "management"
		subnet_id = azurerm_subnet.azure_firewall_mgmt.id
		public_ip_address_id = azurerm_public_ip.fw_mgmt_ip.id
	}
}

resource "azurerm_public_ip" "fw_ip" {
     name                = "${var.hub_name}-fw-pip"
     location            = azurerm_resource_group.hub.location
     resource_group_name = azurerm_resource_group.hub.name
     allocation_method   = "Static"
     sku                 = "Standard"
}

resource "azurerm_subnet" "jumpbox" {
	name = "jumpbox_subnet"
	resource_group_name = azurerm_resource_group.hub.name
	virtual_network_name = azurerm_virtual_network.hub.name
	address_prefixes = [var.jumpbox_subnet_cidr]
}

resource "azurerm_network_interface" "jumpbox" {
     name                = "${var.hub_name}-jumpbox-nic"
     location            = azurerm_resource_group.hub.location
     resource_group_name = azurerm_resource_group.hub.name

     ip_configuration {
       name                          = "internal"
       subnet_id                     = azurerm_subnet.jumpbox.id
       private_ip_address_allocation = "Dynamic"
     }
   }

resource "azurerm_linux_virtual_machine" "jumpbox" {
	name = "${var.hub_name}-jumpbox-vm"
	location = azurerm_resource_group.hub.location
     	resource_group_name = azurerm_resource_group.hub.name
	priority = "Spot"
	eviction_policy = "Deallocate"
	size = "Standard_D2ls_v5"
	admin_username = var.admin_username

	network_interface_ids = [azurerm_network_interface.jumpbox.id]

	os_disk {
		caching = "ReadWrite"
		storage_account_type = "Standard_LRS"
	}

	source_image_reference {
		publisher = "Canonical"
		offer = "0001-com-ubuntu-server-jammy"
		sku = "22_04-lts"
		version = "latest"
	}
	
	admin_ssh_key {
		username = var.admin_username
		public_key = var.admin_public_key
	}
}

