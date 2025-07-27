<#
Tried to find the users belonging to a group, nested up to 3 levels.
There may be a beter way to get this, but I didn't have the time or the neccesity to do it.
#>

Connect-MsolService
Connect-AzureAD

$group = Get-AzureADGroup -SearchString "GrpIMA-MFA"

$resultsarray = @()

$members = Get-AzureADGroupMember -ObjectId $group.ObjectId -All $true

foreach ($member in $members) {
    if ($member.ObjectType -eq "User") {
        $user = Get-AzureADUser -ObjectId $member.ObjectId
        $userObject = New-Object PSObject
        $userObject | Add-Member -MemberType NoteProperty -Name "GroupName" -Value $group.DisplayName
        $userObject | Add-Member -MemberType NoteProperty -Name "MemberName" -Value $user.DisplayName
        $userObject | Add-Member -MemberType NoteProperty -Name "UPN" -Value $user.UserPrincipalName
        $userObject | Add-Member -MemberType NoteProperty -Name "NestedGroupName" -Value $null
        $resultsarray += $userObject
    }
    else {
        if ($member.ObjectType -eq "Group") {
            $nestedGroup = Get-AzureADGroup -ObjectId $member.ObjectId
            $nestedGroupObject = New-Object PSObject
            $nestedGroupObject | Add-Member -MemberType NoteProperty -Name "GroupName" -Value $group.DisplayName
            $nestedGroupObject | Add-Member -MemberType NoteProperty -Name "NestedGroupName" -Value $nestedGroup.DisplayName
            $nestedGroupObject | Add-Member -MemberType NoteProperty -Name "MemberName" -Value $null
            $nestedGroupObject | Add-Member -MemberType NoteProperty -Name "UPN" -Value $null
            $resultsarray += $nestedGroupObject

          
            $nestedMembers = Get-AzureADGroupMember -ObjectId $nestedGroup.ObjectId -All $true
            foreach ($nestedMember in $nestedMembers) {
                if ($nestedMember.ObjectType -eq "User") {
                    $nestedUser = Get-AzureADUser -ObjectId $nestedMember.ObjectId
                    $nestedUserObject = New-Object PSObject
                    $nestedUserObject | Add-Member -MemberType NoteProperty -Name "GroupName" -Value $group.DisplayName
                    $nestedUserObject | Add-Member -MemberType NoteProperty -Name "NestedGroupName" -Value $nestedGroup.DisplayName
                    $nestedUserObject | Add-Member -MemberType NoteProperty -Name "MemberName" -Value $nestedUser.DisplayName
                    $nestedUserObject | Add-Member -MemberType NoteProperty -Name "UPN" -Value $nestedUser.UserPrincipalName
                    $resultsarray += $nestedUserObject
                }
                else {
                    
                      if ($member.ObjectType -eq "Group") {
                          $nestedGroup = Get-AzureADGroup -ObjectId $member.ObjectId
                          $nestedGroupObject = New-Object PSObject
                          $nestedGroupObject | Add-Member -MemberType NoteProperty -Name "GroupName" -Value $group.DisplayName
                          $nestedGroupObject | Add-Member -MemberType NoteProperty -Name "NestedGroupName" -Value $nestedGroup.DisplayName
                          $nestedGroupObject | Add-Member -MemberType NoteProperty -Name "MemberName" -Value $null
                          $nestedGroupObject | Add-Member -MemberType NoteProperty -Name "UPN" -Value $null
                          $resultsarray += $nestedGroupObject

                        
                          $nestedMembers = Get-AzureADGroupMember -ObjectId $nestedGroup.ObjectId -All $true
                          foreach ($nestedMember in $nestedMembers) {
                              if ($nestedMember.ObjectType -eq "User") {
                                  $nestedUser = Get-AzureADUser -ObjectId $nestedMember.ObjectId
                                  $nestedUserObject = New-Object PSObject
                                  $nestedUserObject | Add-Member -MemberType NoteProperty -Name "GroupName" -Value $group.DisplayName
                                  $nestedUserObject | Add-Member -MemberType NoteProperty -Name "NestedGroupName" -Value $nestedGroup.DisplayName
                                  $nestedUserObject | Add-Member -MemberType NoteProperty -Name "MemberName" -Value $nestedUser.DisplayName
                                  $nestedUserObject | Add-Member -MemberType NoteProperty -Name "UPN" -Value $nestedUser.UserPrincipalName
                                  $resultsarray += $nestedUserObject
                              }  
                               else { Write-Host "Object not found: $($member.ObjectType)"
                                  }
                              }
                          }
                      }
                    }   
                   
    }
}
}

$resultsarray | Export-Csv -Path "C:\Path\to\aadgroupmembersNested.csv" -NoTypeInformation