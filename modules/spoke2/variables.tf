variable "location" {
	description = "Azure region"
	type = string
}

variable "spoke_rg_name" {
	description = "Spoke resource group name"
	type = string
}

variable "spoke_name" {
	description = "Name of the spoke"
	type = string
}


variable "spoke_cidr" {
     description = "CIDR block for the spoke VNET"
     type        = string
}

variable "spoke_subnet_cidr" {
     description = "CIDR for spoke subnet"
     type        = string
}

variable "hub_rg_name" {
     description = "Name of the hub resource group"
     type        = string
}

variable "hub_vnet_name" {
     description = "Name of the hub VNET"
     type        = string
}

variable "hub_vnet_id" {
     description = "ID of the hub VNET"
     type        = string
}
