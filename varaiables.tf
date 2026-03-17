variable "location" {
	description = "Azure region"
	type = string
	default = "West Europe"
}

variable "admin_username" {
	description = "Username of the admin"
	type = string
	default = "azureuser"
}

variable "admin_public_key" {
	description = "SSH public key for VM's"
	type = string
}

