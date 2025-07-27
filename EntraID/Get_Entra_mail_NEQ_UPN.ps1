<# Perform a search in EntraID for all users where the UPN <> mail address #>

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All"

# Initialize list
$allUsers = @()
$uri = 'https://graph.microsoft.com/v1.0/users?$select=id,displayName,userPrincipalName,mail,userType,employeeId'

# Pagination loop
do {
    $response = Invoke-MgGraphRequest -Method GET -Uri $uri
    $allUsers += $response.value
    $uri = $response.'@odata.nextLink'
} while ($uri)

# Filter: Members with non-null mail, UPN ≠ mail, and non-empty employeeId
$filteredUsers = $allUsers | Where-Object {
    $_.userType -eq "Member" -and
    $_.mail -ne $null -and
    $_.userPrincipalName -ne $_.mail -and
    ![string]::IsNullOrWhiteSpace($_.employeeId)
} | ForEach-Object {
    [PSCustomObject]@{
        DisplayName       = $_.displayName
        UserPrincipalName = $_.userPrincipalName
        Mail              = $_.mail
        EmployeeId        = $_.employeeId
    }
}

# Export to CSV
$filteredUsers | Export-Csv -Path "Filtered_EntraID_Users.csv" -NoTypeInformation

