# Connect to Azure AD
Connect-AzureAD

# Get the User group ID
$GroupID = "XXXXXX-YYYYY-ZZZZZ-AAAAAA-BBBBBBBBBBB"

# File to update data in CSV
$CSVFilePath = "C:\Path\to\list_users.csv" 

# Get the UPN from the CSV file
$usersToAdd = Import-Csv -Path $CSVFilePath -Delimiter ';' | Select-Object -ExpandProperty UPN

# Add user
foreach ($userUPN in $usersToAdd) {
# Check if the user is already a member of the group
if ($currentMembers.UPN -contains $userUPN) {
Write-Host "The user with UPN $userUPN is already a member of the group."
} else {
# Add the user to the group
$user = Get-AzureADUser -ObjectId $userUPN
Add-AzureADGroupMember -ObjectId $GroupID -RefObjectId $user.ObjectId
Write-Host "The user with UPN $userUPN has been added to the group."
}
}