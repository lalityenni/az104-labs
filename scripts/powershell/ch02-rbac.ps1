$mgname=az104-mg1
$mgscope="/providers/Microsoft.Management/managementGroups/$mgname"
$helpdeskObjectID="00000000-0000-0000-0000-000000000001"
Write-Host "--whatif: assign VM Contributor role to Helpdesk grou p at management group scope $mgscope"
New-AzRoleAssignment
    -ObjectID = $helpdeskObjectID
    -RoleDefinitionName "Virtual Machine Contributor"
    -Scope $mgscope
    -WhatIf



#audit: List the current role assignments at the Management group scope

Get-AzRoleAssignment -scope $mgscope |
    Select-Object DisplayName, Role DefinitionName, Prinicipalname, Scope |
    Format-Table -AutoSize

    