output "spoke_resource_group_name" {
	description = "Name of the resource group"
	value = azurerm_resource_group.spoke.name
}

output "spoke_vnet_id" {
	description = "Vnet ID of the spoke"
	value = azurerm_virtual_network.spoke.id
}

output "spoke_vnet_name" {
	description = "Name of the VNET spoke"
	value = azurerm_virtual_network.spoke.name
}

output "spoke_subnet_id" {
	description = "Subnet Id of the spoke"
	value = azurerm_subnet.spoke.id
}

