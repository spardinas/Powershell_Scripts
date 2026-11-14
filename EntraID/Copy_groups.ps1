# Required: Microsoft.Graph
# Install-Module Microsoft.Graph -Scope CurrentUser
# Update-Module Microsoft.Graph
# Update to include DL and Exchange groups
# Install-Module ExchangeOnlineManagement

### Usage example
### script.ps1 -SourceUser sourceUPN -TargetUser targetUPN -TransitiveMembership 
### IncludeOwners only to be used under very special circunstances as make TargetUser owner of the same groups as SourceUser
### Dryrun to check before make any changes the output is correct.

param(
    [Parameter(Mandatory=$true)]
    [string]$SourceUser,                 # UPN source user
    [Parameter(Mandatory=$true)]
    [string]$TargetUser,                 # UPN target user
    [switch]$TransitiveMembership,       # Chained groups
    [switch]$IncludeOwners,              # Owner roles
    [switch]$DryRun                      # Just test
)

function Connect-GraphSafely {
    $scopes = @(
        "User.Read.All",
        "Group.ReadWrite.All",
        "Directory.Read.All"
    )
    if (-not (Get-MgContext)) {
        Connect-MgGraph -Scopes $scopes | Out-Null
    }
}

# Resolve a user by UPN entered as parameter
function Resolve-GraphUser {
    param([string]$UserRef)
    try {
        
        return Get-MgUser -UserId $UserRef -ErrorAction Stop
    } catch {
        # search EXACT UPN
        $u = Get-MgUser -Filter "userPrincipalName eq '$UserRef'" -ConsistencyLevel eventual -Count userCount
        if ($u) { return $u[0] }
        throw "Not found: $UserRef"
    }
}

function Get-UserGroups {
    param(
        [string]$UserId,
        [switch]$Transitive
    )
    if ($Transitive) {
        $objs = Get-MgUserTransitiveMemberOf -UserId $UserId -All
    } else {
        $objs = Get-MgUserMemberOf -UserId $UserId -All
    }
    # Filter for only group type 
    $groups = @()
    foreach ($o in $objs) {
        if ($o.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.group') {
            $groups += [pscustomobject]@{
                Id = $o.Id
            }
        }
    }
    return $groups
}

function Get-GroupDetails {
    param([string]$GroupId)
    
    return Get-MgGroup -GroupId $GroupId -Property "id,displayName,groupTypes,membershipRule,isAssignableToRole,securityEnabled,mailEnabled"
}

function Is-DynamicGroup {
    param($Group)
    # If dynamic, not copied
    return ([bool]$Group.MembershipRule -or ($Group.GroupTypes -contains "DynamicMembership"))
}

function Ensure-UserIsMember {
    param(
        [string]$GroupId,
        [string]$UserId,
        [switch]$WhatIf
    )
    # check if already member
    $exists = $false
    
    $members = Get-MgGroupMember -GroupId $GroupId -All -Property "id"
    if ($members | Where-Object Id -eq $UserId) { $exists = $true }

    if ($exists) {
        return "Already Member"
    }

    $refBody = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$UserId"
    }

    if ($WhatIf) {
        return "Just Testing"
    } else {
        New-MgGroupMemberByRef -GroupId $GroupId -BodyParameter $refBody | Out-Null
        return "Joined"
    }
}

function Ensure-UserIsOwner {
    param(
        [string]$GroupId,
        [string]$UserId,
        [switch]$WhatIf
    )
    $exists = $false
    $owners = Get-MgGroupOwner -GroupId $GroupId -All -Property "id"
    if ($owners | Where-Object Id -eq $UserId) { $exists = $true }

    if ($exists) {
        return "Already Owner"
    }

    $refBody = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$UserId"
    }

    if ($WhatIf) {
        return "Addind as owner (test)"
    } else {
        New-MgGroupOwnerByRef -GroupId $GroupId -BodyParameter $refBody | Out-Null
        return "Added as owner"
    }
}

# ============== Run Main ==============

Connect-GraphSafely

$src = Resolve-GraphUser -UserRef $SourceUser -properties *
$dst = Resolve-GraphUser -UserRef $TargetUser

Write-Host "source:  $($src.DisplayName) <$($src.UserPrincipalName)>"
Write-Host "target: $($dst.DisplayName) <$($dst.UserPrincipalName)>"
if ($DryRun) { Write-Host "SIMULATION ( no changes made )" -ForegroundColor Yellow }

$groups = Get-UserGroups -UserId $src.Id -Transitive:$TransitiveMembership
if (-not $groups -or $groups.Count -eq 0) {
    Write-Host "Source don't have groups to copy to target." -ForegroundColor Yellow
    return
}

$report = @()

# Copia de extensiones de directorio
$ExtensionValues = @{
    "extension_xxxyyyyzzzz4146734f63_XXX" = $src.AdditionalProperties["extension_xxxyyyyzzzz4146734f63_XXX"]
    "extension_xxxyyyyzzzz4146734f63_YYY" = $src.AdditionalProperties["extension_xxxyyyyzzzz4146734f63_YYY"]
}
if ($DryRun) {
    Write-Host "Would update extension attributes on target user" -ForegroundColor Yellow
}
else {
    Update-MgUser -UserId $dst.Id -BodyParameter $ExtensionValues
}
Update-MgUser -UserId $dst.Id -BodyParameter $ExtensionValues

## Exclusions of groups. Specific groups may require individual atention
foreach ($g in $groups) {
    $gd = Get-GroupDetails -GroupId $g.Id

    # Exclusions of Dynamic groups
    if (Is-DynamicGroup -Group $gd) {
        $report += [pscustomobject]@{
            GroupName = $gd.DisplayName
            GroupId   = $gd.Id
            Action    = "Excluded"
            Reason    = "Dynamic Group"
            Role      = "Member"
        }
        continue
    }
    # Exclusions of groups 
    if ($gd.IsAssignableToRole) {
        # Role assigment
        $report += [pscustomobject]@{
            GroupName = $gd.DisplayName
            GroupId   = $gd.Id
            Action    = "Excluded"
            Reason    = "Require elevation"
            Role      = "Member"
        }
        continue
    }
    # Example of excluded group
    if ($gd.Id -eq "b4584ca0-92ea-472f-8145-4a8351cc327c") {
        $report += [pscustomobject]@{
            GroupName = $gd.DisplayName
            GroupId   = $gd.Id
            Action    = "Excluded"
            Reason    = "ELT group"
            Role      = "Member"
        }
        continue
    }
    }
    # Add as member
    $resMember = Ensure-UserIsMember -GroupId $gd.Id -UserId $dst.Id -WhatIf:$DryRun
    $report += [pscustomobject]@{
        GroupName = $gd.DisplayName
        GroupId   = $gd.Id
        Action    = $resMember
        Reason    = ""
        Role      = "Member"
    }

    # Take Ownership of the group
    if ($IncludeOwners) {
        $resOwner = Ensure-UserIsOwner -GroupId $gd.Id -UserId $dst.Id -WhatIf:$DryRun
        $report += [pscustomobject]@{
            GroupName = $gd.DisplayName
            GroupId   = $gd.Id
            Action    = $resOwner
            Reason    = ""
            Role      = "Owner"
        }
    }

# Output
$report | Sort-Object GroupName, Role | Format-Table -AutoSize