# Import the server list and the new password list
$servers = Get-Content -Path 'C:\Marejadilla\computers.csv'
$passwords = Get-Content -Path 'C:\Marejadilla\password.txt'
$new_passwords = Get-Content -Path 'C:\Marejadilla\new_password.txt'

# Loop through each server
for ($i=0; $i -lt $servers.Length; $i++) {
    $server = $servers[$i]
    $new_password = $new_passwords[$i]

    # Specify the credentials
    $username = 'Administrator'
    $securePassword = ConvertTo-SecureString -String $passwords -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $securePassword

    try {
        # Create a new PSSession
        $session = New-PSSession -ComputerName $server -Credential $cred -ErrorAction Stop

        # Get all users and write to a file
        Invoke-Command -Session $session -ScriptBlock { 
            $users = Get-WmiObject -Class Win32_UserAccount 
            $users | Out-File -FilePath "users_$env:COMPUTERNAME.txt"
        }

        # Change the password for the administrator
        Invoke-Command -Session $session -ScriptBlock { 
            $admin = [ADSI]"WinNT://$env:COMPUTERNAME/Administrator,user"
            $admin.SetPassword($new_password)
        }
    }
    catch {
        Write-Output "Failed to connect to $server"
    }
    finally {
        # Close the PSSession
        if ($session) {
            Remove-PSSession -Session $session
        }
    }
}
