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


  resource "azurerm_management_group" "mg1" {
    display_name = var.mg_display_name
    name         = var.mg_name

  }