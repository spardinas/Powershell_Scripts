<# 
Get the last time a users connect to EntraID 
#>

Connect-MsolService
Connect-AzureAD

$allUsers = Get-MsolUser -all
$object  = Foreach ($upn in $allUsers.userprincipalname) {
  try {
      $signindata = Get-AzureADAuditSignInLogs -Filter "startsWith(userPrincipalName, '$upn')" -top 1
      if ($signindata -eq $Null)
          {
          [PSCustomobject]@{
             UserdisplayName = $upn
             LastLoginDate = "Never Logged in"
          }  
      }
      Else{
           [PSCustomobject]@{
             UserdisplayName = $signindata.UserDisplayName
             LastLoginDate = $signindata.CreatedDateTime
            }
      }
}
      Catch {
        Write-Error $_
      }
}
$object | Export-csv c:\Path\to\LastLogininfo.csv -NoTypeInformation