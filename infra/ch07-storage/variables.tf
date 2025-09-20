variable "subscription_id" {
    description = "Existing subscription ID"
    type        = string
  
}

variable "rg_name" {
  description = "Existing resource group name"
  type        = string
  
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
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

variable "sa_prefix" {
  description = "Prefix for the storage account name"
  type        = string
 
}

variable "file_path" {
  description = "Path to the local file to upload"
  type        = string

}