terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id                 = "a2b28c85-1948-4263-90ca-bade2bac4df4"
}


# Create VNet + subnet with Microsoft.Storage service endpoint

resource "azurerm_virtual_network" "Vnet1" {
  name                = "vnet1"
  address_space       = ["10.10.0.0/16"]
  location            = var.location
  resource_group_name = var.rg_name

}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.Vnet1.name
  address_prefixes     = ["10.10.1.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

}

# Create storage account with VNet rule

resource "azurerm_storage_account" "storageaccount1" {
  name                     = var.storage_account_name
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.subnet1.id]
  }

}