<#

#>

[CmdletBinding()]
param(
    [switch]$Transitive
)


$TenantId     = "00000-0000-0000-0000-000000000000"
$ClientId     = "11111111-1111-1111-1111-111111111111"
$ClientSecret = "abcdefghijklmnopqrstuvwxyz1234567890"

$SecureSecret = ConvertTo-SecureString $ClientSecret -AsPlainText -Force
$AppCred      = New-Object System.Management.Automation.PSCredential($ClientId, $SecureSecret)

if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Host "Install Microsoft.Graph: Install-Module Microsoft.Graph -Scope CurrentUser" -ForegroundColor Yellow
    return
}
Import-Module Microsoft.Graph.Users -ErrorAction Stop
Import-Module Microsoft.Graph.Groups -ErrorAction Stop
Import-Module Microsoft.Graph.DirectoryObjects -ErrorAction Stop

try {
    Connect-MgGraph -TenantId $TenantId -ClientSecretCredential $AppCred -NoWelcome | Out-Null
} catch {
    Write-Host "Error conect Graph (app-only/secret): $($_.Exception.Message)" -ForegroundColor Red
    return
}

$term = Read-Host "Enter part of the groupname - No wildcars - (ej: QWERTY)"
if ([string]::IsNullOrWhiteSpace($term)) { Write-Host "Empty. Exiting..." -ForegroundColor Yellow; return }

Write-Host "Searching security groups '$term'..." -ForegroundColor Cyan
$allSecGroups = Get-MgGroup -All -Filter "securityEnabled eq true" -Property "id,displayName,securityEnabled,mailEnabled,groupTypes"
$groups = $allSecGroups | Where-Object { $_.DisplayName -like "*$term*" }

if (-not $groups) { Write-Host "No groups found." -ForegroundColor Yellow; return }

$ts  = Get-Date -Format "yyyyMMdd_HHmmss"
$san = ($term -replace '[^a-zA-Z0-9_-]','')
$pathGroups  = Join-Path $PWD "EntraID_Grouprs_${san}_$ts.csv"
$pathMembers = Join-Path $PWD ("EntraID_Members{0}_${1}_{2}.csv" -f ($Transitive ? "Nested" : "Direct"), $san, $ts)

$groups | Select-Object Id, DisplayName, SecurityEnabled, MailEnabled, GroupTypes |
    Export-Csv -Path $pathGroups -NoTypeInformation -Encoding UTF8
Write-Host "Total groups: $($groups.Count). Export to: $pathGroups" -ForegroundColor Green

$memberRows = New-Object System.Collections.Generic.List[object]

foreach ($g in $groups) {
    Write-Host ("Proccess group: {0}" -f $g.DisplayName) -ForegroundColor DarkCyan

    try {
        $members = if ($Transitive) {
            Get-MgGroupTransitiveMember -GroupId $g.Id -All -ErrorAction Stop
        } else {
            Get-MgGroupMember -GroupId $g.Id -All -ErrorAction Stop
        }
    } catch {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        continue
    }

    if (-not $members) {
        $memberRows.Add([pscustomobject]@{
            GroupId        = $g.Id
            GroupName      = $g.DisplayName
            MemberType     = "None"
            MemberId       = $null
            MemberUPN      = $null
            MemberDisplay  = $null
        })
        continue
    }

    foreach ($m in $members) {
        $odata = $m.AdditionalProperties['@odata.type']
        switch -Regex ($odata) {
            "#microsoft.graph.user" {
                $u = $null; try { $u = Get-MgUser -UserId $m.Id -Property "userPrincipalName,displayName" -ErrorAction Stop } catch {}
                $memberRows.Add([pscustomobject]@{
                    GroupId=$g.Id; GroupName=$g.DisplayName; MemberType="User"
                    MemberId=$m.Id; MemberUPN=$u.UserPrincipalName; MemberDisplay=$u.DisplayName
                })
            }
            "#microsoft.graph.group" {
                $gg = $null; try { $gg = Get-MgGroup -GroupId $m.Id -Property "displayName" -ErrorAction Stop } catch {}
                $memberRows.Add([pscustomobject]@{
                    GroupId=$g.Id; GroupName=$g.DisplayName; MemberType="Group"
                    MemberId=$m.Id; MemberUPN=$null; MemberDisplay=$gg.DisplayName
                })
            }
            "#microsoft.graph.device" {
                $dv = $null; try { $dv = Get-MgDevice -DeviceId $m.Id -Property "displayName" -ErrorAction Stop } catch {}
                $memberRows.Add([pscustomobject]@{
                    GroupId=$g.Id; GroupName=$g.DisplayName; MemberType="Device"
                    MemberId=$m.Id; MemberUPN=$null; MemberDisplay=$dv.DisplayName
                })
            }
            "#microsoft.graph.servicePrincipal" {
                $sp = $null; try { $sp = Get-MgServicePrincipal -ServicePrincipalId $m.Id -Property "displayName,appId" -ErrorAction Stop } catch {}
                $memberRows.Add([pscustomobject]@{
                    GroupId=$g.Id; GroupName=$g.DisplayName; MemberType="ServicePrincipal"
                    MemberId=$m.Id; MemberUPN=$sp.AppId; MemberDisplay=$sp.DisplayName
                })
            }
            default {
                $memberRows.Add([pscustomobject]@{
                    GroupId=$g.Id; GroupName=$g.DisplayName
                    MemberType=($odata -replace '^#microsoft\.graph\.','')
                    MemberId=$m.Id; MemberUPN=$null
                    MemberDisplay=$m.AdditionalProperties['displayName']
                })
            }
        }
    }
}

$memberRows | Export-Csv -Path $pathMembers -NoTypeInformation -Encoding UTF8
Write-Host "Members exported to: $pathMembers" -ForegroundColor Green

Disconnect-MgGraph