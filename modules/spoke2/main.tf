resource "azurerm_resource_group" "spoke" {
	name = var.spoke_rg_name
	location = var.location
}

resource "azurerm_virtual_network" "spoke" {
	name = "${var.spoke_name}-vnet"
	address_space = [var.spoke_cidr]
	location = azurerm_resource_group.spoke.location
	resource_group_name = azurerm_resource_group.spoke.name
}

resource "azurerm_subnet" "spoke" {
	name = "${var.spoke_name}-subnet"
	resource_group_name = azurerm_resource_group.spoke.name
	virtual_network_name = azurerm_virtual_network.spoke.name
	address_prefixes = [var.spoke_subnet_cidr]
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
     name = "${var.spoke_name}-to-${var.hub_vnet_name}"
     resource_group_name        = azurerm_resource_group.spoke.name
     virtual_network_name       = azurerm_virtual_network.spoke.name
     remote_virtual_network_id  = var.hub_vnet_id
     allow_forwarded_traffic    = true
     allow_gateway_transit      = true
}

resource "azurerm_route_table" "spoke" {
        name = "${var.spoke_name}-rt"
        location = azurerm_resource_group.spoke.location
        resource_group_name = azurerm_resource_group.spoke.name

        route {
                name = "to-internet-via-firewall"
                address_prefix = "0.0.0.0/0"
                next_hop_type = "VirtualAppliance"
                next_hop_in_ip_address = var.firewall_private_ip
        }


}

resource "azurerm_subnet_route_table_association" "spoke" {
        subnet_id = azurerm_subnet.spoke.id
        route_table_id = azurerm_route_table.spoke.id
}
