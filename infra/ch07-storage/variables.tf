variable "rg_name" {
  description = "Existing resource group name"
  type        = string
  default     = "kml_rg_main-4d4afa1b899b4e7d"
}

variable "location" {
  description = "Azure region (should match RG)"
  type        = string
  default     = "East US"
}

variable "vnet_rg_name" {
  description = "Resource group of the existing VNet"
  type        = string
  default     = "kml_rg_main-4d4afa1b899b4e7d"

}

variable "vnet_name" {
  description = "Existing VNet name"
  type        = string
  default     = "vnet1"
}

variable "subnet_name" {
  description = "Existing subnet name (must have Microsoft.Storage service endpoint enabled)"
  type        = string
  default     = "subnet1"
}

variable "storage_account_name" {
  description = "Globally unique SA name (lowercase, no dashes). Leave empty to auto-generate."
  type        = string
  default     = "stkml"
}