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

resource "azurerm_firewall_policy" "fw_policy" {
	name = "fw-policy"
	resource_group_name = azurerm_resource_group.hub.name
	location = azurerm_resource_group.hub.location
	sku = var.firewall_sku_tier
	threat_intelligence_mode = "Alert"
	
	threat_intelligence_allowlist {
	fqdns = []
	ip_addresses = []
	}
}

resource "azurerm_firewall_policy_rule_collection_group" "network" {
	name = "rcg-network-rules"
	firewall_policy_id = azurerm_firewall_policy.fw_policy.id
	priority = 200

	network_rule_collection {
		name = "only-rdp"
		priority = 100
		action = "Allow"

		rule {
			name = "allow-rdp"
			protocols = ["TCP"]
			source_addresses = ["*"]
			destination_addresses = ["*"]
			destination_ports = ["3389"]	
		}
		
	}

	network_rule_collection {
                name = "allow-spoke-to-spoke"
                priority = 110
                action = "Allow"

                rule {
                        name = "spoke1-to-spoke2"
                        protocols = ["Any"]
                        source_addresses = ["10.1.0.0/16"]
                        destination_addresses = ["10.2.0.0/16"]
                        destination_ports = ["*"]
                }
		rule {
                        name = "spoke2-to-spoke3"
                        protocols = ["Any"]
                        source_addresses = ["10.2.0.0/16"]
                        destination_addresses = ["10.1.0.0/16"]
                        destination_ports = ["*"]
                }

        }	
}

resource "azurerm_firewall_policy_rule_collection_group" "application" {
        name = "rcg-application-rules"
        firewall_policy_id = azurerm_firewall_policy.fw_policy.id
        priority = 300

        application_rule_collection {
                name = "allow-web"
                priority = 100
                action = "Allow"

                rule {
                        name = "allow-azure-service"
                        protocols {
			type = "Https"
			port = 443
			}
                        source_addresses = ["*"]
                        destination_fqdns = [
       			"*.microsoft.com",
        		"*.azure.com",
        		"*.windows.net",
        		"*.windowsupdate.com"
      			]
                }

        }
}

resource "azurerm_firewall_policy_rule_collection_group" "dnat" {
        name = "rcg-dnat-rules"
        firewall_policy_id = azurerm_firewall_policy.fw_policy.id
        priority = 200

        nat_rule_collection {
                name = "inbound-rdp"
                priority = 100
                action = "Dnat"

                rule {
                        name = "jumpbox-rdp"
                        protocols = ["TCP"]
                        source_addresses = ["*"]
                        destination_address = azurerm_public_ip.fw_ip.ip_address
			destination_ports = ["3389"]
			translated_address = "10.0.3.4"
			translated_port = "3389"
                }

        }
}

resource "azurerm_firewall" "hub" {
	name = "${var.hub_name}-fw"
	location = azurerm_resource_group.hub.location
	resource_group_name = azurerm_resource_group.hub.name
	sku_name = "AZFW_VNet"
	sku_tier = var.firewall_sku_tier
	
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
	firewall_policy_id = azurerm_firewall_policy.fw_policy.id
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
       private_ip_address_allocation = "Static"
	private_ip_address = "10.0.3.4"
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

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
	for_each = var.spoke_vnet_ids

     name = "${var.hub_name}-to-${each.key}"
     resource_group_name        = azurerm_resource_group.hub.name
     virtual_network_name       = azurerm_virtual_network.hub.name
     remote_virtual_network_id  = each.value
     allow_forwarded_traffic    = true
     allow_gateway_transit      = true
}
