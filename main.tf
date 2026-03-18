module "hub" {
	source = "./modules/hub"

	location = var.location
	hub_rg_name = "rg_hub"
	hub_name = "hub"
	hub_cidr = "10.0.0.0/16"
	admin_username = var.admin_username
	admin_public_key = var.admin_public_key
	spoke_vnet_ids = {
		"spoke1" = module.spoke.spoke_vnet_id
       		"spoke2" = module.spoke2.spoke_vnet_id
	}
}

module "spoke" {
	source = "./modules/spoke"

	location = var.location
	spoke_rg_name = "rg-spoke"
	spoke_name = "spoke1"
	spoke_cidr = "10.1.0.0/16"
	spoke_subnet_cidr = "10.1.0.0/24"
	hub_rg_name = module.hub.hub_resource_group_name
	hub_vnet_name = module.hub.hub_vnet_name
	hub_vnet_id = module.hub.hub_vnet_id
	firewall_private_ip = module.hub.firewall_ip
}

module "spoke2" {
        source = "./modules/spoke2"

        location = var.location
        spoke_rg_name = "rg-spoke2"
        spoke_name = "spoke2"
        spoke_cidr = "10.2.0.0/16"
        spoke_subnet_cidr = "10.2.0.0/24"
        hub_rg_name = module.hub.hub_resource_group_name
        hub_vnet_name = module.hub.hub_vnet_name
        hub_vnet_id = module.hub.hub_vnet_id
	firewall_private_ip = module.hub.firewall_ip
}
