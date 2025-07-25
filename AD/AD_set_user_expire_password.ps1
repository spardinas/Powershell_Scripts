Import-Module ActiveDirectory

# Set OU
$OU = "OU=Users,DC=domain,DC=com"

$users = Get-ADUser -Filter * -SearchBase $OU
foreach ($user in $users) {
    Set-ADUser -Identity $user -PasswordNeverExpires $false
    Set-ADUser -Identity $user -ChangePasswordAtLogon $true
}
Write-Host "Password reset enforced for all users in the OU: $OU"

