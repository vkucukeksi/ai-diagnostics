param (
    [string]$InputPath = ".\output\logs.json"
)

function Write-Log {
    param ([string]$Message)
    Write-Host "[Analyze] $Message" -ForegroundColor Yellow
}

Write-Log "Loading data..."

if (!(Test-Path $InputPath)) {
    Write-Error "Input file not found: $InputPath"
    exit
}

$data = Get-Content $InputPath | ConvertFrom-Json

$analysis = @()

# Example checks
if ($data.IPs -contains "0.0.0.0") {
    $analysis += "Invalid IP configuration detected"
}

if ($data.DNS.Count -eq 0) {
    $analysis += "No DNS servers configured"
}

if ($data.Services.Count -lt 5) {
    $analysis += "Low number of running services (possible issue)"
}

# Output structured summary
$result = @{
    Timestamp = Get-Date
    Findings  = $analysis
    RawData   = $data
}

$result | ConvertTo-Json -Depth 5 | Out-File ".\output\analysis.json"

Write-Log "Analysis complete. Output saved to output\analysis.json"