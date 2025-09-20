variable "rg_name" {
  type        = string
  description = "Resource group name to manage"
}

variable "location" {
  type        = string
  description = "Azure region for the resource group (e.g., East US)"
}

variable "tag_key" {
  type        = string
  description = "Tag key to enforce"
  default     = "Cost Center"
}

variable "tag_value" {
  type        = string
  description = "Tag value to enforce"
  default     = "000"
}