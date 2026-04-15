param (
    [string]$PromptPath = ".\prompts\root-cause.txt",
    [string]$DataPath = ".\output\analysis.json"
)

function Write-Log {
    param ([string]$Message)
    Write-Host "[AI Analysis] $Message" -ForegroundColor Magenta
}

Write-Log "Loading prompt template..."

if (!(Test-Path $PromptPath)) {
    Write-Error "Prompt file not found: $PromptPath"
    exit
}

$promptTemplate = Get-Content $PromptPath -Raw

if (!(Test-Path $DataPath)) {
    Write-Error "Data file not found: $DataPath"
    exit
}

$data = Get-Content $DataPath -Raw

# Inject data into prompt (safe replace)
$finalPrompt = $promptTemplate.Replace("{{DATA}}", $data)

if (-not $finalPrompt) {
    Write-Error "Final prompt is empty. Check prompt file or data injection."
    exit
}

Write-Log "Calling OpenAI API..."

$apiKey = $env:OPENAI_API_KEY

if (-not $apiKey) {
    Write-Error "OPENAI_API_KEY not set"
    exit
}

# Escape JSON string properly
function Escape-JsonString {
    param([string]$String)
    $String = $String -replace '\\', '\\'
    $String = $String -replace '"', '\"'
    $String = $String -replace "`n", '\n'
    $String = $String -replace "`r", '\r'
    $String = $String -replace "`t", '\t'
    return $String
}

# Build request body - use explicit JSON construction
$escapedContent = Escape-JsonString $finalPrompt
$body = "{
  ""model"": ""gpt-4o-mini"",
  ""messages"": [
    {
      ""role"": ""user"",
      ""content"": ""$escapedContent""
    }
  ],
  ""temperature"": 0.3
}"

# Call API with retry logic
$maxRetries = 3
$retryDelay = 2
$response = $null

for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
    try {
        Write-Log "API call attempt $attempt/$maxRetries..."

        $response = Invoke-RestMethod `
            -Uri "https://api.openai.com/v1/chat/completions" `
            -Method Post `
            -Headers @{
                Authorization = "Bearer $apiKey"
                "Content-Type" = "application/json"
            } `
            -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) `
            -TimeoutSec 30

        # Success - break out of retry loop
        break
    } catch {
        $errorMsg = $_.Exception.Message

        # Check for specific errors
        if ($errorMsg -like "*insufficient_quota*") {
            Write-Error "API Error: Insufficient quota. Check your billing at https://platform.openai.com/account/billing"
            exit 1
        } elseif ($errorMsg -like "*invalid_request_error*") {
            Write-Error "API Error: Invalid request format. This may be a configuration issue."
            exit 1
        } elseif ($attempt -eq $maxRetries) {
            Write-Error "API Error after $maxRetries attempts: $errorMsg"
            exit 1
        } else {
            Write-Log "Attempt failed, retrying in $retryDelay seconds..."
            Start-Sleep -Seconds $retryDelay
            $retryDelay = $retryDelay * 2  # Exponential backoff
        }
    }
}

# Validate response
if (-not $response -or -not $response.choices) {
    Write-Error "AI analysis failed: no valid response received."
    exit
}

$output = $response.choices[0].message.content

Write-Output $output