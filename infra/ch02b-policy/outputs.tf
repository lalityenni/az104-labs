output "rg_id" {
  value = azurerm_resource_group.rg1.id
}

output "require_assignment_id" {
  value = azurerm_resource_group_policy_assignment.enforce_cost_center.id
}

output "inherit_assignment_id" {
  value = azurerm_resource_group_policy_assignment.inherit_cost_center.id
}