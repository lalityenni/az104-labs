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
}

# -----------------------
# Task 1: RG with tag
# -----------------------
resource "azurerm_resource_group" "rg1" {
  name     = var.rg_name
  location = var.location

  tags = {
    (var.tag_key) = var.tag_value
  }
}

# -----------------------
# Task 2: Enforce tag (deny if missing)
# Built-in policy: RequireTagAndItsValue
# -----------------------
data "azurerm_policy_definition" "require_tag_and_value" {
  name = "RequireTagAndItsValue"
}

resource "azurerm_resource_group_policy_assignment" "enforce_cost_center" {
  name                 = "require-${replace(lower(var.tag_key), " ", "-")}-tag"
  display_name         = "Require ${var.tag_key} tag and value on resources"
  resource_group_id    = azurerm_resource_group.rg1.id
  policy_definition_id = data.azurerm_policy_definition.require_tag_and_value.id

  # v4: enforcement is ON by default; set enforcement_disabled = true to pause

  parameters = jsonencode({
    tagName  = { value = var.tag_key  }
    tagValue = { value = var.tag_value }
  })
}

# -----------------------
# Task 3: Inherit tag from RG (Modify effect) + remediation
# Built-in policy: InheritTagFromRG
# -----------------------
data "azurerm_policy_definition" "inherit_tag_from_rg" {
  name = "InheritTagFromRG"
  # If needed, you can use:
  # display_name = "Inherit a tag from the resource group if missing"
}

resource "azurerm_resource_group_policy_assignment" "inherit_cost_center" {
  name                 = "inherit-${replace(lower(var.tag_key), " ", "-")}-from-rg"
  display_name         = "Inherit ${var.tag_key} tag from the RG if missing"
  resource_group_id    = azurerm_resource_group.rg1.id
  policy_definition_id = data.azurerm_policy_definition.inherit_tag_from_rg.id

  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode({
    tagName = { value = var.tag_key }
  })
}

resource "azurerm_resource_group_policy_remediation" "remediate_inherit_cost_center" {
  name                 = "remediate-inherit-${replace(lower(var.tag_key), " ", "-")}"
  resource_group_id    = azurerm_resource_group.rg1.id
  policy_assignment_id = azurerm_resource_group_policy_assignment.inherit_cost_center.id

  # Optional knobs you can uncomment if desired:
  # resource_discovery_mode = "ReEvaluateCompliance"
  # parallel_deployments    = 5
  # failure_percentage      = 10
  # location_filters        = [var.location]
}

# -----------------------
# Task 4: RG delete lock
# -----------------------
resource "azurerm_management_lock" "rg_delete_lock" {
  name       = "rg-lock"
  scope      = azurerm_resource_group.rg1.id
  lock_level = "CanNotDelete" # exact casing
  notes      = "Prevents deletion of the resource group per Lab 02b"
}