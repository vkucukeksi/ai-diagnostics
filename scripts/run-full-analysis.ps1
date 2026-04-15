param (
    [switch]$IncludeAI,
    [string]$OutputDir = ".\output",
    [switch]$Verbose
)

<#
.SYNOPSIS
    Orchestrates the complete AI Diagnostics analysis workflow.

.DESCRIPTION
    Runs the full diagnostic pipeline in sequence:
    1. Collects system logs and infrastructure data
    2. Analyzes collected data for issues
    3. (Optional) Sends analysis to AI for deeper insights

.PARAMETER IncludeAI
    Include AI-powered analysis using OpenAI API.

.PARAMETER OutputDir
    Directory for output files (default: ./output).

.PARAMETER Verbose
    Show detailed progress and debug info.

.EXAMPLE
    .\scripts\run-full-analysis.ps1
    Run local analysis only.

    .\scripts\run-full-analysis.ps1 -IncludeAI
    Run full analysis including AI insights.
#>

function Write-Header {
    param([string]$Title)
    Write-Host ""
    Write-Host ("=" * 60) -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host ("=" * 60) -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Message, [int]$Number, [int]$Total)
    $prefix = "[$Number/$Total]"
    Write-Host "$prefix $Message" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

# Start analysis
Write-Header "AI Diagnostics - Full Analysis Pipeline"
Write-Host "Started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray

# Validate output directory
if (!(Test-Path $OutputDir)) {
    Write-Warning "Output directory does not exist. Creating: $OutputDir"
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$stepCount = 2
if ($IncludeAI) { $stepCount = 3 }

# Step 1: Collect Logs
Write-Step "Collecting system and infrastructure data" 1 $stepCount
Write-Host "Running collect-logs.ps1..." -ForegroundColor Gray

try {
    & "$scriptDir\collect-logs.ps1" -OutputPath "$OutputDir\logs.json"
    Write-Success "Data collection complete"
} catch {
    Write-Error "Failed to collect logs: $_"
    exit 1
}

# Step 2: Analyze Config
Write-Step "Analyzing collected data for issues" 2 $stepCount
Write-Host "Running analyze-config.ps1..." -ForegroundColor Gray

try {
    & "$scriptDir\analyze-config.ps1" -InputPath "$OutputDir\logs.json"
    Write-Success "Analysis complete"
} catch {
    Write-Error "Failed to analyze config: $_"
    exit 1
}

# Step 3: AI Analysis (Optional)
if ($IncludeAI) {
    Write-Step "Running AI-powered analysis" 3 $stepCount
    Write-Host "Running run-ai-analysis.ps1..." -ForegroundColor Gray

    try {
        & "$scriptDir\run-ai-analysis.ps1" `
            -PromptPath ".\prompts\root-cause.txt" `
            -DataPath "$OutputDir\analysis.json"
        Write-Success "AI analysis complete"
    } catch {
        Write-Error "Failed to run AI analysis: $_"
        if ($_.Exception.Message -like "*insufficient_quota*") {
            Write-Warning "OpenAI API quota exceeded. Check your billing at https://platform.openai.com/account/billing/overview"
        }
        exit 1
    }
} else {
    Write-Host ""
    Write-Host "Tip: Run with -IncludeAI flag to get AI-powered insights:" -ForegroundColor Gray
    Write-Host "  .\scripts\run-full-analysis.ps1 -IncludeAI" -ForegroundColor Gray
}

# Summary
Write-Header "Analysis Complete"
Write-Host "Output files saved to: $OutputDir" -ForegroundColor Green
Write-Host ""
Write-Host "Generated files:" -ForegroundColor Yellow
Get-ChildItem "$OutputDir" -File | Where-Object { $_.Extension -in @('.json', '.md') } | ForEach-Object {
    $size = [math]::Round($_.Length / 1KB, 2)
    Write-Host "  • $($_.Name) ($size KB)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host ""
