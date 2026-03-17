variable "location" {
        description = "Azure region"
        type = string
}

variable "hub_rg_name" {
        description = "Name of the hub resource group"
        type = string
}

variable "hub_name" {
        description = "Name of the hub"
        type = string
}

variable "hub_cidr" {
        description = "CIDR block for the hub VNET"
        type = string
}

variable "firewall_subnet_cidr" {
     description = "CIDR for Azure Firewall subnet"
     type        = string
     default     = "10.0.0.0/26"
}

variable "jumpbox_subnet_cidr" {
        description = "CIDR for jumpbox subnet"
        type = string
        default = "10.0.3.0/24"
}

variable "admin_username" {
        description = "Admin username for the jumpbox"
        type = string
        default = "azureuser"
}

variable "admin_public_key" {
        description = "Admin public key"
        type = string
}

variable "spoke_vnet_ids" {
	description = "Map of spoke names to VNET IDs"
	type = map(string)
	default = {}
}


