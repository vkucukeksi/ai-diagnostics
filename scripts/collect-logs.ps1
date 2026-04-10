param (
    [string]$OutputPath = ".\output\logs.json"
)

function Write-Log {
    param ([string]$Message)
    Write-Host "[Collect] $Message" -ForegroundColor Cyan
}

Write-Log "Starting data collection..."

$data = @{
    Timestamp = (Get-Date)
    Hostname  = $env:COMPUTERNAME
    OS        = (Get-CimInstance Win32_OperatingSystem).Caption
    IPs       = (Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4"}).IPAddress
    DNS       = (Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses
    Routes    = (Get-NetRoute | Select-Object DestinationPrefix, NextHop)
    Services  = (Get-Service | Where-Object {$_.Status -eq "Running"} | Select-Object Name, Status)
}

# Ensure output folder exists
New-Item -ItemType Directory -Force -Path (Split-Path $OutputPath) | Out-Null

$data | ConvertTo-Json -Depth 4 | Out-File $OutputPath

Write-Log "Data collection complete. Output saved to $OutputPath"