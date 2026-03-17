variable "location" {
	description = "Azure region"
	type        = string
	default     = "West Europe"
}

variable "admin_username" {
	description = "Admin username for the jumpbox"
	type        = string
	default     = "azureuser"
}

variable "admin_public_key" {
	description = "Admin public key"
	type        = string
}