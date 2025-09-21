#The PowerShell script audits Azure resources in a specified subscription to find those missing a specific tag ($TagName).
#It:Takes inputs: Subscription ID (required), tag name to check (required), optional resource group to filter, and output CSV path (defaults to missing-tag.csv).
#Imports Azure PowerShell modules and sets the subscription.
#Gets resources (all or from a specific resource group if provided).
#Checks each resource for the tag. If missing, adds its details (name, type, ID, group, location) to an array ($missing).
#Prints the count of resources missing the tag and saves their details to a CSV file.

#Example: If run with -SubscriptionId "1234-5678" -TagName "Environment", it lists resources without the "Environment" tag in a CSV and shows how many were found.
#Let me know if you need a specific part clarified!



param(
   [parameter(Mandatory)] [string]$subscriptionId,
     [parameter(Mandatory)][string]$Tagname,
    [string]$ResourceGroup,
    [string]$OutCsv = "./missing-tag.csv"

)

Import-Module Az.Resources, Az.Accounts -ErrorAction Stop

Select-AzSubscription -SubscriptionId $subscriptionId | Out-Null   

$filter = if ($ResourceGroup) {@{ ResourceGroup = $ResourceGroup }} else{@{}    }
    <# Action to perform if the condition is true #>
$all = Get-AzResource @filter
$missing = @()
foreach(r in $all) {
    try {
        $tags = (Get-AzTag -ResourceId $r.ResourceId -ErrorAction Stop).Tags
    }
    catch {
        <#Do this if a terminating exception happens#>
        $tags = @{}
    }
    if (-not ($tags.ContainsKey($Tagname))) {
        $missing += ([PSCustomObject]@{
            Name = $r.Name
            ResourceGroup = $r.ResourceGroupName
            ResourceType = $r.ResourceType
            Location = $r.Location
        })
    }
}

Write-Host "$($missing.Count) resources missing tag '$Tagname'

$missing | Export-Csv -Path $OutCsv -NoTypeInformation -Force
Write-Host "List exported to: $(($OutCsv).Path)"