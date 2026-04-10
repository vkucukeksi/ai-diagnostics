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

$findings = @()

# 🔍 Check 1: Missing DNS
if (!$data.DNS -or $data.DNS.Count -eq 0) {
    $findings += @{
        Severity = "High"
        Issue    = "No DNS servers configured"
        Impact   = "Name resolution will fail"
    }
}

# 🔍 Check 2: Suspicious IP
if ($data.IPs -contains "0.0.0.0") {
    $findings += @{
        Severity = "Medium"
        Issue    = "Invalid IP address detected"
        Impact   = "Network misconfiguration"
    }
}

# 🔍 Check 3: Low services running
if ($data.Services.Count -lt 5) {
    $findings += @{
        Severity = "Low"
        Issue    = "Unusually low number of running services"
        Impact   = "Possible system issue or minimal install"
    }
}

# 📦 Output object
$result = @{
    Timestamp = Get-Date
    Hostname  = $data.Hostname
    Findings  = $findings
}

# Ensure output folder exists
New-Item -ItemType Directory -Force -Path ".\output" | Out-Null

# Save JSON
$result | ConvertTo-Json -Depth 5 | Out-File ".\output\analysis.json"

# 👀 Console output (this is the demo magic)
Write-Host "`n=== Analysis Results ===" -ForegroundColor Cyan

if ($findings.Count -eq 0) {
    Write-Host "No issues detected ✅" -ForegroundColor Green
} else {
    foreach ($f in $findings) {
        Write-Host "`n[$($f.Severity)] $($f.Issue)" -ForegroundColor Red
        Write-Host "Impact: $($f.Impact)" -ForegroundColor Gray
    }
}

Write-Log "Analysis complete. Output saved to output\analysis.json"