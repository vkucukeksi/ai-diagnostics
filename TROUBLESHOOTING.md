# 🔧 Troubleshooting Guide

## Common Issues & Solutions

### API Errors

#### "insufficient_quota" / "You exceeded your current quota"
**Cause:** OpenAI account has no available credits.

**Solutions:**
1. Visit https://platform.openai.com/account/billing/overview
2. Check your plan type and usage
3. Add a payment method if needed
4. Wait a few minutes for billing to sync
5. Try again

---

#### "Invalid JSON in file"
**Cause:** The collected logs or analysis data is malformed.

**Solutions:**
```powershell
# Validate JSON
try {
    Get-Content ".\output\logs.json" | ConvertFrom-Json
} catch {
    Write-Host "JSON Error: $_"
}
```

**Check:**
- File is not empty
- File encoding is UTF-8
- No truncated JSON

---

#### "OPENAI_API_KEY not set"
**Cause:** Environment variable not configured.

**Solutions:**
```powershell
# Set temporarily (current PowerShell session only)
$env:OPENAI_API_KEY = "sk-your-key-here"

# Set permanently (all future sessions)
[Environment]::SetEnvironmentVariable("OPENAI_API_KEY", "sk-your-key-here", "User")
```

**Verify it's set:**
```powershell
Write-Host $env:OPENAI_API_KEY
```

---

#### "Prompt file not found"
**Cause:** Custom prompt path is incorrect.

**Solutions:**
```powershell
# Check file exists
Test-Path ".\prompts\root-cause.txt"

# List available prompts
Get-ChildItem ".\prompts\"

# Use full path
.\scripts\run-ai-analysis.ps1 -PromptPath "C:\ai-diagnostics\prompts\root-cause.txt"
```

---

### Data Collection Issues

#### "Input file not found"
**Cause:** Logs haven't been collected yet.

**Solution:**
```powershell
# Collect data first
.\scripts\collect-logs.ps1

# Then analyze
.\scripts\analyze-config.ps1
```

---

#### No DNS servers found / Invalid IPs detected
**Cause:** Network configuration issues on the system.

**Solutions:**
1. Check network configuration:
   ```powershell
   Get-DnsClientServerAddress -AddressFamily IPv4
   Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4"}
   ```

2. If issue is real, fix network settings
3. If issue is false positive, modify analysis rules in `config.json`

---

#### "Unusually low number of running services"
**Cause:** System has minimal services running (< configured minimum).

**Solutions:**
1. Check what services are running:
   ```powershell
   Get-Service | Where-Object {$_.Status -eq "Running"} | Measure-Object
   ```

2. Adjust threshold in `config.json`:
   ```json
   "rules": {
     "minServiceCount": 3  // Lower threshold
   }
   ```

---

### Execution Issues

#### "ExecutionPolicy" error
**Cause:** PowerShell execution policy prevents script execution.

**Solution:**
```powershell
# Bypass for current session only
powershell -ExecutionPolicy Bypass -File ".\scripts\run-full-analysis.ps1"

# Or set permanently (not recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

#### "Cannot find path"
**Cause:** Running script from wrong directory.

**Solution:**
```powershell
# Navigate to project root first
cd C:\Users\Volkan\Documents\ai-diagnostics

# Then run
.\scripts\run-full-analysis.ps1

# Or use full path
C:\Users\Volkan\Documents\ai-diagnostics\scripts\run-full-analysis.ps1
```

---

#### Timeout errors during API call
**Cause:** Slow network, OpenAI API slow response, or network blocking.

**Solutions:**
1. Check internet connection
2. Try again after a few minutes
3. Retry logic should auto-handle (up to 3 attempts)
4. Check if firewall is blocking OpenAI endpoints

---

### Output Issues

#### Output files are empty
**Cause:** Data collection or analysis failed silently.

**Solution:**
```powershell
# Run with verbose output
$VerbosePreference = "Continue"
.\scripts\run-full-analysis.ps1

# Check file size
(Get-Item ".\output\logs.json").Length
```

---

#### Can't find output files
**Cause:** Output directory is different than expected.

**Solution:**
```powershell
# Check where files were created
Get-ChildItem -Recurse ".\output"
Get-ChildItem -Recurse ".\scripts\output"

# Use specified output directory
.\scripts\run-full-analysis.ps1 -OutputDir "C:\my\path"
```

---

### AI Analysis Issues

#### "Model not found" or model errors
**Cause:** Model name in config doesn't exist.

**Solution:**
Update `config.json` with valid model:
```json
{
  "ai": {
    "model": "gpt-4o-mini"  // Or gpt-4, gpt-3.5-turbo
  }
}
```

Current available models:
- `gpt-4o` (latest, recommended)
- `gpt-4o-mini` (faster, cheaper)
- `gpt-4` (powerful)
- `gpt-3.5-turbo` (legacy)

---

#### API returns incomplete response
**Cause:** Response was cut off (max tokens reached).

**Solution:**
Increase `maxTokens` in `config.json`:
```json
{
  "ai": {
    "maxTokens": 4000
  }
}
```

---

#### Temperature setting doesn't affect output
**Cause:** Running with same seed or model behavior is consistent.

**Solutions:**
- Lower temperature (0.0-0.3) = More consistent/factual
- Higher temperature (0.7-1.0) = More creative/varied
- Try different values and test

---

## Debug Mode

Enable detailed logging:

```powershell
# Set verbose preference
$VerbosePreference = "Continue"

# Run script
.\scripts\run-full-analysis.ps1 -Verbose

# Check all output files
Get-ChildItem ".\output" -File | ForEach-Object {
    Write-Host "$($_.Name) - $($_.Length) bytes"
}
```

---

## Getting Help

1. **Check the logs:**
   ```powershell
   Get-ChildItem ".\output" -Include "*.log"
   ```

2. **Re-run with error details:**
   ```powershell
   $ErrorActionPreference = "Continue"
   .\scripts\run-full-analysis.ps1 2>&1 | Tee-Object "debug.log"
   ```

3. **Validate your setup:**
   ```powershell
   # Check API key is set
   Write-Host $env:OPENAI_API_KEY
   
   # Check files exist
   Test-Path ".\prompts\root-cause.txt"
   Test-Path ".\config.json"
   ```

4. **Test individual scripts:**
   ```powershell
   # Just collection
   .\scripts\collect-logs.ps1
   
   # Just analysis
   .\scripts\analyze-config.ps1
   
   # Just AI (if data exists)
   .\scripts\run-ai-analysis.ps1
   ```

---

## Still Stuck?

If you're still having issues:
1. Check the error message carefully
2. Look for your error above
3. Try the suggested solutions
4. Verify all prerequisites are set up correctly
5. Check project README for overview

**Common Checklist:**
- ✓ PowerShell 5.0+ installed
- ✓ OPENAI_API_KEY environment variable set
- ✓ OpenAI account has active credits
- ✓ Running from project root directory
- ✓ All files exist in expected locations
