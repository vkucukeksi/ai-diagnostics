param (
    [string]$AnalysisPath = ".\output\analysis.json",
    [string]$PromptPath   = ".\prompts\root-cause.txt",
    [string]$OutputPath   = ".\output\report.md"
)

function Write-Log {
    param ([string]$Message)
    Write-Host "[AI] $Message" -ForegroundColor Magenta
}

Write-Log "Loading analysis data..."

if (!(Test-Path $AnalysisPath)) {
    Write-Error "Analysis file not found: $AnalysisPath"
    exit
}

$data = Get-Content $AnalysisPath -Raw

Write-Log "Loading prompt template..."

$promptTemplate = Get-Content $PromptPath -Raw

# Inject data into prompt
$finalPrompt = $promptTemplate -replace "{{DATA}}", $data

Write-Log "Calling OpenAI API..."

$apiKey = $env:OPENAI_API_KEY

if (-not $apiKey) {
    Write-Error "OPENAI_API_KEY not set"
    exit
}

$body = @{
    model = "gpt-4.1-mini"
    messages = @(
        @{
            role = "user"
            content = $finalPrompt
        }
    )
    temperature = 0.3
} | ConvertTo-Json -Depth 5

$response = Invoke-RestMethod `
    -Uri "https://api.openai.com/v1/chat/completions" `
    -Method Post `
    -Headers @{
        "Authorization" = "Bearer $apiKey"
        "Content-Type"  = "application/json"
    } `
    -Body $body

$output = $response.choices[0].message.content

# Ensure output folder exists
New-Item -ItemType Directory -Force -Path (Split-Path $OutputPath) | Out-Null

$output | Out-File $OutputPath

Write-Log "AI analysis complete. Output saved to $OutputPath"