
## Load required modules
Import-Module ActiveDirectory -ErrorAction Stop

# Set the base OU where you want to create new OUs 
$baseOU = 'OU=Department,DC=domain,DC=com'

## List child OUs and allow user to select one

$childOUs = Get-ADOrganizationalUnit `
    -Filter * `
    -SearchBase $baseOU `
    -SearchScope OneLevel ` # Only one level below the base OU
    | Sort-Object Name

if ($childOUs.Count -eq 0) {
    Write-Host "Child OUs not found in $baseOU." -ForegroundColor Yellow
    exit 1
}

# Show menu to select the target OU
Write-Host "`nSelect the target OU:`n"
for ($i = 0; $i -lt $childOUs.Count; $i++) {
    Write-Host ("{0}. {1}" -f ($i + 1), $childOUs[$i].Name)
}

## Read user input and validate selection
do {
    $input = Read-Host "Enter the number of the target OU (1..$($childOUs.Count))"
} while (-not ($input -match '^\d+$' -and [int]$input -ge 1 -and [int]$input -le $childOUs.Count))

$selectedDN = $childOUs[[int]$input - 1].DistinguishedName # Store the value entred by the user in a variable for later use.

## Enter name for the new OU
do {
    $newName = Read-Host "`nEnter the name of the new OU"
} while ([string]::IsNullOrWhiteSpace($newName)) # while loop to ensure the user enters a non-empty name for the new OU.

## Create the new OU under the selected parent OU
try {
    New-ADOrganizationalUnit `
        -Name $newName `
        -Path $selectedDN `
        -ProtectedFromAccidentalDeletion $false `
        -ErrorAction Stop

    Write-Host "`nOU '$newName' created in '$selectedDN'." -ForegroundColor Green # Show the result of the operation.
}
catch {
    Write-Error "Error creating the OU: $_"
}
