Import-Module ActiveDirectory

# Initialize Array to store the results
$results = @()

# List all distribution groups
$distributionGroups = Get-ADGroup -Filter {GroupCategory -eq "Distribution"}

# List members on each DL
foreach ($group in $distributionGroups) {
    $members = Get-ADGroupMember -Identity $group.DistinguishedName
    foreach ($member in $members) {
        # Store the result to the array
        $results += [PSCustomObject]@{
            GroupName = $group.Name
            MemberName = $member.Name
        }
    }
}

# Export 
$results | Export-Csv -Path "C:\Path\to\result\DistributionGroups.csv" -NoTypeInformation
