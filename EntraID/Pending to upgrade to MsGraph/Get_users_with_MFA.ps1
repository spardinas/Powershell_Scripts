Connect-MsolService
Connect-AzureAD

# Obtener todos los usuarios
$users = Get-AzureADUser -All $true
 
# Filter from all users those with MFS enabled.
$mfaEnabledUsers = @()
foreach ($user in $users) {
    $mfaDetails = Get-MsolUser -UserPrincipalName $user.UserPrincipalName | Select-Object DisplayName, UserPrincipalName, StrongAuthenticationMethods
    if ($mfaDetails.StrongAuthenticationMethods -ne $null) {
        $mfaEnabledUsers += $mfaDetails
    }
}
 
# Show the users
$mfaEnabledUsers | Export-Csv -Path "C:\Path\to\users_with_MFA.csv" -NoTypeInformation
