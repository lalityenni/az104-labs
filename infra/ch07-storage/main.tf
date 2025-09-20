variable "rg_name"   { type = string, description = "Resource group for today" }
variable "location"  { type = string, description = "Region for today" }

variable "sa_prefix" {
  description = "Prefix for the storage account (lowercase, no dashes), e.g., az104sa"
  type        = string
  default     = "az104sa"
}

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  # no subscription_id here; uses your current `az account set` context
}

# Unique name helper for the storage account
resource "random_string" "suffix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

locals {
  sa_name = "${var.sa_prefix}${random_string.suffix.result}"  # e.g., az104sax3k1p9
}

# -------------------------
# Network: VNet + Subnet
# -------------------------
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

# -------------------------
# Storage Account (locked to subnet)
# -------------------------
resource "azurerm_storage_account" "storageaccount1" {
  name                     = local.sa_name
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  allow_blob_public_access = false

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.subnet1.id]
  }
}

# -------------------------
# Lifecycle: move base blobs to Cool after 30 days
# -------------------------
resource "azurerm_storage_management_policy" "movetocool" {
  storage_account_id = azurerm_storage_account.storageaccount1.id

  rule {
    name    = "move-to-cool"
    enabled = true

    filters {
      blob_types = ["blockBlob"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = 30
      }
    }
  }
}

# -------------------------
# Private container
# -------------------------
resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_id    = azurerm_storage_account.storageaccount1.id
  container_access_type = "private"
}

# -------------------------
# Immutability (time-based WORM for 180 days)
# -------------------------
resource "azurerm_storage_container_immutability_policy" "data_worm" {
  storage_container_resource_manager_id = azurerm_storage_container.data.resource_manager_id
  immutability_period_in_days           = 180
}

# Container level SAS (list-only), valid for 24 hours
data "azurerm_storage_account_sas" "container_list_ro_24h" {
  connection_string = azurerm_storage_account.storageaccount1.primary_connection_string
  https_only        = true
  start             = timestamp()
  expiry            = timeadd(timestamp(), "24h")

  resource_types {
    service   = false
    container = true
    object    = false
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  permissions {
    read    = false
    write   = false
    delete  = false
    list    = true
    add     = false
    create  = false
    update  = false
    process = false
    filter  = false
    tag     = false
  }
  
}

resource "azurerm_storage_share" "share1" {
  name                 = "share1"
  storage_account_id   = azurerm_storage_account.storageaccount1.id
  quota                = 100
}

resource "azurerm_storage_share_directory" "dir" {
    name             = "mydir"
    storage_share_id = azurerm_storage_share.share1.id
   
}
resource "azurerm_storage_share_file" "file1" {
  name              = "example.txt"
  storage_share_id  = azurerm_storage_share.share1.id
  source            = "example.txt" # Path to a local file, or remove if not uploading
  path              = azurerm_storage_share_directory.dir.name
}