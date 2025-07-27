<# This may need a little explanation.
The script looks for all the actions a user did in Sharepoint Online ( it includes Onedrive )
The first export is almost raw data, the second one is parsed to make it more readable.
It needs some tweak, be aware of that #>

# Connect to Microsoft with Admin user
Connect-ExchangeOnline -UserPrincipalName admin@domain.com

# Define the user to look for and date range ( license below E5 only got 180 days )
$deletedUserUPN = "deleted_user@domain.com"
$startDate = (Get-Date).AddDays(-180).ToString("yyyy-MM-ddTHH:mm:ssZ")

# Search for activities by the user in ALL record types
$searchResults = Search-UnifiedAuditLog -StartDate $startDate -EndDate (Get-Date) -UserIds $deletedUserUPN

# If you want to feel inside Matrix the movie
$searchResults | Format-Table -AutoSize

# Export the results to a CSV file - Check file path
$searchResults | Export-Csv -Path "C:\Path\to\DeletedUserAuditLogs.csv" -NoTypeInformation

Write-Host "Audit logs for $deletedUserUPN have been exported to C:\Path\to\DeletedUserAuditLogs.csv"

# Import CSV file to parse the JSON data
$csvData = Import-Csv -Path "C:\Path\to\DeletedUserAuditLogs.csv"

# Initialize an array to store parsed data
$parsedData = @()

# Loop through each row and parse JSON
foreach ($row in $csvData) {
    try {
        $auditJson = $row.AuditData | ConvertFrom-Json
        $parsedData += [PSCustomObject]@{
            CreationDate = $row.CreationDate
            Operation = $row.Operation
            UserId = $auditJson.UserId
            SiteUrl = $auditJson.SiteUrl
            SourceFileName = $auditJson.SourceFileName
            SourceRelativeUrl = $auditJson.SourceRelativeUrl
            ClientIP = $auditJson.ClientIP
            ObjectId = $auditJson.ObjectId
            UserAgent = $auditJson.UserAgent
            TargetUserOrGroupName = $auditJson.TargetUserOrGroupName
        }
    } catch {
        Write-Host "Error parsing JSON for row: $($row.CreationDate)"
    }
}

# Export parsed data to a new CSV file for drama
$parsedData | Export-Csv -Path "C:\Path\to\ParsedAuditLogs.csv" -NoTypeInformation

Write-Host "Parsed audit logs saved to C:\Path\to\ParsedAuditLogs.csv"
