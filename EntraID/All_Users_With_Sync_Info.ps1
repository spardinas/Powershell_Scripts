<# 
list the users in EntraID who are sync to local AD 
#>


# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All"

# Retrieve all users and the properties needed
$allUsers = Get-MgUser -All -Property "displayName,mail,userPrincipalName,onPremisesSyncEnabled,onPremisesDomainName,userType"

# Create a list to store user details with sync information
$userDetails = @()

foreach ($user in $allUsers) {
    if ($user.UserType -eq "Member") {
        $userDetails += [PSCustomObject]@{
            DisplayName = $user.DisplayName
            Mail = $user.Mail
            UserPrincipalName = $user.UserPrincipalName
            OnPremisesSyncEnabled = $user.OnPremisesSyncEnabled
            OnPremisesDomainName = $user.OnPremisesDomainName
        }
    }
}


# Export the data to a CSV file
$userDetails | Export-Csv -Path "C:\path\to\export\file\All_Users_With_Sync_Info.csv" -NoTypeInformation