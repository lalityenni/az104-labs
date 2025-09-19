variable "mg_name" {
  type        = string
  description = "The name of the management group"
  
}

variable "mg_display_name" {
  type        = string
  description = "The display name of the management group"      
  
}

variable "helpdesk_object_id" {
  type        = string
  description = "The object ID of the Helpdesk user or group in Azure AD"
  
}