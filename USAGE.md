# 📖 Usage Guide

## Quick Start

### Run Full Analysis (Recommended)
```powershell
.\scripts\run-full-analysis.ps1
```
This runs the complete pipeline:
1. Collects system data
2. Analyzes for issues
3. (Optional) Gets AI insights

### With AI Analysis
```powershell
$env:OPENAI_API_KEY="your-api-key-here"
.\scripts\run-full-analysis.ps1 -IncludeAI
```

---

## Individual Scripts

### 1. Collect System Data
Gathers infrastructure data from your system.

```powershell
.\scripts\collect-logs.ps1
```

**Parameters:**
- `-OutputPath` — Where to save collected data (default: `./output/logs.json`)

**Example:**
```powershell
.\scripts\collect-logs.ps1 -OutputPath "C:\data\system-logs.json"
```

**Output:** JSON file containing:
- System hostname and OS info
- Network IPs and DNS servers
- Network routes
- Running services

---

### 2. Analyze Configuration
Checks for common infrastructure issues.

```powershell
.\scripts\analyze-config.ps1
```

**Parameters:**
- `-InputPath` — Path to collected logs (default: `./output/logs.json`)

**Example:**
```powershell
.\scripts\analyze-config.ps1 -InputPath "C:\data\system-logs.json"
```

**Checks Performed:**
- ✓ DNS servers configured
- ✓ No invalid IP addresses (0.0.0.0)
- ✓ Minimum number of services running

**Output:** 
- Console report with findings
- JSON analysis file (`./output/analysis.json`)

---

### 3. AI-Powered Analysis
Sends analysis to OpenAI for deeper insights.

```powershell
$env:OPENAI_API_KEY="sk-..."
.\scripts\run-ai-analysis.ps1
```

**Parameters:**
- `-PromptPath` — Custom prompt template (default: `./prompts/root-cause.txt`)
- `-DataPath` — Analysis data to review (default: `./output/analysis.json`)

**Example - Root Cause Analysis:**
```powershell
.\scripts\run-ai-analysis.ps1 `
    -PromptPath ".\prompts\root-cause.txt" `
    -DataPath ".\output\analysis.json"
```

**Example - Security Analysis:**
```powershell
.\scripts\run-ai-analysis.ps1 `
    -PromptPath ".\prompts\security-analysis.txt" `
    -DataPath ".\output\analysis.json"
```

**Output:** AI-generated markdown report to console

---

## Configuration

Edit `config.json` to customize:

```json
{
  "ai": {
    "model": "gpt-4o-mini",      // OpenAI model to use
    "temperature": 0.3,           // Lower = more factual (0-1)
    "maxTokens": 2000
  },
  "rules": {
    "minServiceCount": 5,         // Alert if fewer services running
    "requireDNS": true            // Require DNS servers configured
  }
}
```

---

## Advanced Workflows

### 1. Batch Multiple System Analysis
```powershell
$systems = @("server1", "server2", "server3")

foreach ($system in $systems) {
    Write-Host "Analyzing $system..."
    
    # Copy remote logs
    Copy-Item "\\$system\logs.json" -Destination ".\output\$system-logs.json"
    
    # Analyze locally
    .\scripts\analyze-config.ps1 -InputPath ".\output\$system-logs.json"
}
```

### 2. Generate Security Reports Only
```powershell
# Collect data
.\scripts\collect-logs.ps1

# Analyze
.\scripts\analyze-config.ps1

# Get AI security assessment
$env:OPENAI_API_KEY="sk-..."
.\scripts\run-ai-analysis.ps1 `
    -PromptPath ".\prompts\security-analysis.txt" `
    -DataPath ".\output\analysis.json"
```

### 3. Compare Before/After Changes
```powershell
# Before making changes
.\scripts\collect-logs.ps1 -OutputPath ".\output\before-logs.json"
.\scripts\analyze-config.ps1 -InputPath ".\output\before-logs.json"

# [Make infrastructure changes]

# After changes
.\scripts\collect-logs.ps1 -OutputPath ".\output\after-logs.json"
.\scripts\analyze-config.ps1 -InputPath ".\output\after-logs.json"

# Compare reports manually
```

---

## Output Files

All output is saved to `./output/`:

| File | Purpose |
|------|---------|
| `logs.json` | Raw system data collected |
| `analysis.json` | Findings from local analysis |
| `report.md` | AI-generated report (if using -IncludeAI) |

---

## Scheduling Analysis

### Windows Task Scheduler
Create a scheduled task to run analysis weekly:

```powershell
# Create task
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File C:\path\to\run-full-analysis.ps1"

$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 2am

Register-ScheduledTask -TaskName "AI Diagnostics" `
    -Action $action -Trigger $trigger
```

---

## Tips & Best Practices

1. **Store API Key Securely**
   ```powershell
   # Don't hardcode! Use environment variable or credential vault
   $env:OPENAI_API_KEY = Read-Host -AsSecureString "Enter API Key"
   ```

2. **Test API Connection First**
   ```powershell
   .\scripts\run-ai-analysis.ps1 -DataPath ".\examples\sample-data.json"
   ```

3. **Keep Output for Auditing**
   ```powershell
   # Archive old reports
   Move-Item ".\output\*" ".\archive\$(Get-Date -f 'yyyy-MM-dd')"
   ```

4. **Customize Prompts**
   Create custom prompt files for your use case:
   - Copy `.\prompts\root-cause.txt` 
   - Modify the prompt instructions
   - Use with `-PromptPath` parameter

---

## Next Steps

- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Review [README.md](../README.md) for project overview
- See `./examples/` for sample outputs
