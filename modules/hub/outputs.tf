output "hub_resource_group_name" {
	description = "Name of the hub resource group"
	value = azurerm_resource_group.hub.name
}

output "hub_vnet_id" {
	description = "ID of the hubVNET"
	value = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
	description = "Name of the hub VNET"
	value = azurerm_virtual_network.hub.name
}

output "firewall_id" {
	description = "ID of the firewall"
	value = azurerm_firewall.hub.id
}

output "firewall_ip" {
	description = "Private IP of the firewall"
	value = azurerm_firewall.hub.ip_configuration[0].private_ip_address
}

output "jumpbox_public_ip" {
	description = "Public Ip of the jumpbox"
	value = azurerm_linux_virtual_machine.jumpbox.public_ip_address
}
