terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 4.0"                              
    }
  }
}
  provider "azurerm" {
    features {}
    
  } 

# Create a management group
  resource "azurerm_management_group" "mg1" {
    display_name = var.mg_display_name
    name         = var.mg_name

  }

# Task 2: Assign VM Contributor role to Helpdesk group at MG scope

resource "azurerm_role_assignment" "helpdesk_vm_contributor" {
    scope = azurerm_management_group.mg1.id
    role_definition_name = "Virtual Machine Contributor"
    principal_id = var.helpdesk_object_id
}
