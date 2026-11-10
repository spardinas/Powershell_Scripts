<#
Automatically changes DNS servers if WIFI adapeter is connected to specific network.
Then point DNS to pi-hole server. 
If not is set to DHCP
#>

$internalDNS = "DNS_Server_IP"
$internalWIFI = "Network_Name"
$adaptername = "Card_Name"
$profile = Get-NetIPConfiguration -InterfaceAlias $adaptername

# Define network adapter
Get-NetAdapter | Select-Object InterfaceAlias, InterfaceIndex

$currentDNS = Get-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter -Name $adaptername).InterfaceIndex -AddressFamily IPv4 | select ServerAddresses | select -ExpandProperty ServerAddresses

try {
    $ssid = (netsh wlan show interfaces) -match '^\s*SSID\s*:\s*(.+)$' |
            ForEach-Object { ($_ -split ':')[1].Trim() } |
            Select-Object -First 1

    if ($ssid) {
        Write-Output "Connected SSID: $ssid"
    }
    else {
        Write-Output "No active Wi-Fi connection found."
    }
}
catch {
    Write-Error "Error retrieving SSID: $_"
}
if ($ssid -eq $internalWIFI) {
    if ($currentDNS -ne $internalDNS) {
        Write-Output "Connected to $internalWIFI. Setting DNS to $internalDNS."
        Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter -Name $adaptername).InterfaceIndex -ServerAddresses $internalDNS
    }
    else {
        Write-Output "Already connected to $internalWIFI with correct DNS settings."
    }
}else {
    if ($currentDNS -ne "DHCP") {
        Write-Output "Not connected to $internalWIFI. Setting DNS to DHCP."
        Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter -Name $adaptername).InterfaceIndex -ResetServerAddresses
    }
    else {
        Write-Output "Not connected to $internalWIFI and DNS is already set to DHCP."
    }
}




