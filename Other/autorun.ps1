# Autorun script for PowerShell
[autorun]
icon=Z:\path\to\autorun.ico
open=Z:\path\to\autorun.cmd

%Windir%\System32\WindowsPowerShell\v1.0\PowerShell.exe -exec bypass -noprofile -file "Z:\path\to\autorun.ps1"

$directoryPath = "P:\Path\To\Destination\Directory"
if (Test-Path -Path $directoryPath) {
   Write-Host "Directory exists."
   robocopy "Z:\path\to\source\directory" "P:\Path\To\Destination\Directory" /E /Z /COPYALL /R:0 /W:0 /xj /LOG:"P:\robocopy_log.txt"

} else {
   Write-Host "Directory does not exist."
}

