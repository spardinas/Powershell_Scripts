##
## Script de limpieza de usuarios en Entra, en base a EmployeeID
##
$LogDir = "C:\Path\to\Logs"
if (-not (Test-Path $LogDir)) { New-Item -Path $LogDir -ItemType Directory | Out-Null }
$LogFile = Join-Path $LogDir ("ScriptLog_" + (Get-Date -Format "dd-MM-yyyy") + ".log")
$Remember = "C:\Path\to\Remember.csv"

Start-Transcript -Path $LogFile -Append

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All"

# Enter EmployeeID to search
$EmployeeID = Read-Host "Enter EmployeeID to search"

$user = Get-MgUser -Filter "employeeId eq '$EmployeeID'" -ConsistencyLevel eventual

if (-not $user)
{
    Write-Host "EmployeeID not found" -ForegroundColor Red
    return
}

## Save data to CSV for reporting or rollback purposes
$Report = [PSCustomObject]@{
    Date          = Get-Date
    DisplayName   = $user.DisplayName
    UPN           = $user.UserPrincipalName
    EmployeeID    = $user.EmployeeId
    Manager       = $user.Manager
    Department    = $user.Department
    JobTitle      = $user.JobTitle
}

$Report | Export-Csv -Path $Remember -NoTypeInformation -Append

#### Main Script

# Data returned with user details
Display details:

Write-Host ""
Write-Host "User found:" -ForegroundColor Yellow
Write-Host "Display Name : $($user.DisplayName)" 
Write-Host "UPN          : $($user.UserPrincipalName)" 
Write-Host "Department   : $($user.Department)"
Write-Host "EmployeeID   : $($user.EmployeeId)"
Write-Host "Job Title    : $($user.JobTitle)"
Write-Host ""

# Confirmation before continue

$confirm = Read-Host "Continue cleanup? (Y/N)"

if ($confirm -ne "Y")
{
    Write-Host "Cancelled"
    Write-Log "Error occurred: $($_.Exception.Message)" "ERROR"
    return
}

# Disable Sign-In and revoke sessions
Update-MgUser -UserId $user.Id -AccountEnabled:$false
Revoke-MgUserSignInSession -UserId $user.Id

# Retrieve current licences ( just listing, not removal)
$userLicenses = Get-MgUserLicenseDetail -UserId $user.Id

###
### Remove Group Memberships

#Get memberships:
$Groups = Get-MgUserMemberOf `
    -UserId $user.Id -All
foreach ($Group in $Groups)
{
    if ($Group.AdditionalProperties.'@odata.type' -ne '#microsoft.graph.group')
    {
        continue
    }
    $GroupObject = Get-MgGroup -GroupId $Group.Id
    if ($GroupObject.DisplayName -in $ExcludedGroups)
    {
        continue
    }
    Remove-MgGroupMemberByRef -GroupId $GroupObject.Id -DirectoryObjectId $user.Id
}

# Remove Manager TO REVIEW
Remove-MgUserManagerByRef -UserId $user.Id

# Rename Account
Update-MgUser -UserId $user.Id -DisplayName "[DISABLED] $($user.DisplayName)"
# Cleanup User Data
Update-MgUser -UserId $user.Id -JobTitle "" -Department "" -Country "" -PhysicalOfficeLocation ""

Stop-Transcript | Out-Null
