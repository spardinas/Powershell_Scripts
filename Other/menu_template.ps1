####
#### To use this as template for management menu.
#### Adapt and chenge function Show-Menu to executescripts as needed
####

####
# Check if the user running the script is asigned as admin for the computer
####
function Check-IsAdmin {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($user)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
# If not, exit
if (-not (Check-IsAdmin)) {
    Write-Output "Please run this script as an administrator."
    exit
}
Write-Output "Running script as administrator..."
####
# Open a menu option to choose
####
function Show-Menu {
    param (
        [string]$Title = 'Script Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host "Option 1"
    Write-Host "Option 2"
    Write-Host "Option 3"
    Write-Host "Option 4"
    Write-Host "Q: Exit"
}
function Get-Selection {
    $selection = Read-Host "Select an option (1-4 or Q to quit)"
    return $selection
}
function Process-Selection {
    param (
        [string]$selection
    )
    switch ($selection) {
        '1' { 
		Write-Host "You chose Option 1" 
		#### Do something for option 1
		}
        '2' { 
		Write-Host "You chose Option 2" 
		#### Do something for option 2
		}
        '3' { 
		Write-Host "You chose Option 3" 
		##### Do something for option 3
		}
		'4' { 
		Write-Host "You chose Option 4" 
		##### Do something for option 4
		}
        'Q' { 
		Write-Host "Exiting..."; exit 
		}
        default { 
		Write-Host "Invalid selection" 
		}
    }
}
while ($true) {
    Show-Menu -Title "Script Menu"
    $selection = Get-Selection
    Process-Selection -selection $selection
}
