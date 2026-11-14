$ErrorActionPreference = 'Stop'
try {
    Connect-MgGraph -Scopes @(
        'User.Read.All',
        'Directory.Read.All',
        'Organization.Read.All'
    )
}
catch {
    Write-Error "Failed to connect to Microsoft Graph: $($_.Exception.Message)"
    exit 1
}
try {
    $ExportFolder = 'C:\Path\to\folder' # Change this to your desired export folder
    if (-not (Test-Path -Path $ExportFolder)) {
        New-Item -Path $ExportFolder -ItemType Directory -Force | Out-Null
    }
    $ExportPath = Join-Path $ExportFolder 'Microsoft365Users_ID_Manager.csv'
    $Result = [System.Collections.Generic.List[object]]::new()
    $AllSkus = Get-MgSubscribedSku
    $SkuLookup = @{}
    foreach ($Sku in $AllSkus) {
        $SkuKey = [string]$Sku.SkuId
        if (-not [string]::IsNullOrWhiteSpace($SkuKey)) {
            $SkuLookup[$SkuKey] = $Sku.SkuPartNumber
        }
    }
    $AllUsers = Get-MgUser -All `
        -Property @(
            'Id',
            'DisplayName',
            'UserPrincipalName',
            'Mail',
            'EmployeeId',
            'AssignedLicenses',
            'AssignedPlans'
        ) `
        -ExpandProperty 'manager'
    $TotalUsers = $AllUsers.Count
    $Index = 0
    foreach ($User in $AllUsers) {
        $Index++
        $PercentComplete = if ($TotalUsers -gt 0) {
            [math]::Round(($Index / $TotalUsers) * 100, 2)
        }
        else {
            100
        }
        Write-Progress -Activity 'Processing users...' `
                       -Status "Processing $($User.UserPrincipalName) ($Index of $TotalUsers)" `
                       -PercentComplete $PercentComplete
        try {
            $AssignedLicenses = [System.Collections.Generic.List[string]]::new()
            $LicensedServices = [System.Collections.Generic.List[string]]::new()
            $ManagerName = 'No Manager'
            if ($null -ne $User.Manager -and $null -ne $User.Manager.AdditionalProperties) {
                $ManagerProps = $User.Manager.AdditionalProperties
                if ($ManagerProps.ContainsKey('userPrincipalName') -and
                    -not [string]::IsNullOrWhiteSpace([string]$ManagerProps['userPrincipalName'])) {
                    $ManagerName = [string]$ManagerProps['userPrincipalName']
                }
                elseif ($ManagerProps.ContainsKey('displayName') -and
                        -not [string]::IsNullOrWhiteSpace([string]$ManagerProps['displayName'])) {
                    $ManagerName = [string]$ManagerProps['displayName']
                }
            }
            if ($null -ne $User.AssignedLicenses -and $User.AssignedLicenses.Count -gt 0) {
                foreach ($License in $User.AssignedLicenses) {
                    $LicenseSkuKey = [string]$License.SkuId
                    if (-not [string]::IsNullOrWhiteSpace($LicenseSkuKey)) {
                        if ($SkuLookup.ContainsKey($LicenseSkuKey)) {
                            $AssignedLicenses.Add($SkuLookup[$LicenseSkuKey])
                        }
                        else {
                            $AssignedLicenses.Add("UnknownSku:$LicenseSkuKey")
                        }
                    }
                }
            }
            if ($null -ne $User.AssignedPlans -and $User.AssignedPlans.Count -gt 0) {
                foreach ($ServicePlan in $User.AssignedPlans) {
                    if ($ServicePlan.CapabilityStatus -eq 'Enabled' -and
                        -not [string]::IsNullOrWhiteSpace([string]$ServicePlan.Service)) {
                        $LicensedServices.Add([string]$ServicePlan.Service)
                    }
                }
            }
            $Result.Add([PSCustomObject]@{
                DisplayName      = $User.DisplayName
                UPN              = $User.UserPrincipalName
                Mail             = $User.Mail
                UserId           = $User.Id
                EmployeeId       = $User.EmployeeId
                IsLicensed       = ($null -ne $User.AssignedLicenses -and $User.AssignedLicenses.Count -gt 0)
                Licenses         = (($AssignedLicenses | Sort-Object -Unique) -join ',')
                LicensedServices = (($LicensedServices | Sort-Object -Unique) -join ',')
                Manager          = $ManagerName
            })
        }
        catch {
            Write-Warning "Error processing user $($User.UserPrincipalName): $($_.Exception.Message)"
        }
    }
    $Result |
        Select-Object DisplayName, UPN, Mail, UserId, EmployeeId, IsLicensed, Licenses, LicensedServices, Manager |
        Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
    Write-Host "Export completed successfully: $ExportPath" -ForegroundColor Green
}
catch {
    Write-Error "Script failed: $($_.Exception.Message)"
}
finally {
    try {
        Disconnect-MgGraph | Out-Null
    }
    catch {
        # ignore disconnect errors
    }
    Write-Progress -Activity 'Processing users...' -Completed
}