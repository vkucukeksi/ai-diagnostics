# 🧠 AI Diagnostics & Security Analysis Toolkit

This project demonstrates how LLMs can assist in infrastructure diagnostics and security analysis.

---

## 🚀 Quick Start

```powershell
# Run complete analysis pipeline
.\scripts\run-full-analysis.ps1

# Include AI-powered insights (requires OpenAI API key)
$env:OPENAI_API_KEY="sk-your-api-key"
.\scripts\run-full-analysis.ps1 -IncludeAI
```

See [USAGE.md](USAGE.md) for detailed examples and workflows.

---

## 📂 Overview

The goal of this project is to explore how AI can:

- Collect system and infrastructure data automatically
- Analyse data for root causes and issues
- Provide security risk assessments
- Generate clear, actionable recommendations

**Features:**
- ✅ Automated data collection (network, services, DNS, routes)
- ✅ Local analysis with configurable rules
- ✅ AI-powered root cause analysis
- ✅ Security assessment capabilities
- ✅ Comprehensive error handling and retry logic
- ✅ Configurable via `config.json`

---

## 📖 Documentation

| Document | Purpose |
|----------|---------|
| [USAGE.md](USAGE.md) | How to run scripts, examples, advanced workflows |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | Common issues and solutions |
| [config.json](config.json) | Configuration for AI model, rules, directories |

---

## 📂 Project Structure

```
ai-diagnostics/
├── scripts/
│   ├── run-full-analysis.ps1    ← Start here (orchestrates all 3)
│   ├── collect-logs.ps1         ← Gather system data
│   ├── analyze-config.ps1       ← Analyze for issues
│   ├── run-ai-analysis.ps1      ← AI insights (optional)
│   └── output/                  ← Generated results
├── prompts/
│   ├── root-cause.txt          ← Root cause analysis prompt
│   └── security-analysis.txt    ← Security assessment prompt
├── examples/
│   └── sample-output.md        ← Example report
├── config.json                 ← Configuration file
├── USAGE.md                    ← Usage guide with examples
├── TROUBLESHOOTING.md          ← Common issues & fixes
└── README.md                   ← This file
```

---

## 🔑 API Requirements

This project includes **optional** AI-powered analysis using the OpenAI API.

### Setup (for AI features)

1. **Get an API key:**
   - Go to https://platform.openai.com/api-keys
   - Create a new secret key

2. **Set the environment variable:**
   ```powershell
   $env:OPENAI_API_KEY = "sk-your-key-here"
   ```

3. **Ensure you have credits:**
   - Check https://platform.openai.com/account/billing/overview
   - Add payment method if needed

### Using AI Analysis

```powershell
# Root cause analysis
.\scripts\run-full-analysis.ps1 -IncludeAI

# Custom prompt
.\scripts\run-ai-analysis.ps1 `
    -PromptPath ".\prompts\security-analysis.txt" `
    -DataPath ".\output\analysis.json"
```

**Note:** If no API credits are available, AI features will fail. The core data collection and local analysis work without an API key.

---

## 💡 How It Works

### 1. Data Collection
Gathers information about your system:
- Hostname and OS
- Network interfaces and IP addresses
- DNS configuration
- Network routes
- Running services

### 2. Local Analysis
Checks for common infrastructure issues:
- Missing DNS servers
- Invalid IP addresses
- Low service count

### 3. AI Analysis (Optional)
Sends findings to OpenAI for deeper insights:
- Root cause analysis
- Security risk assessment
- Actionable recommendations

---

## 🛠️ Use Cases

### Infrastructure Troubleshooting
```powershell
# Analyze system health
.\scripts\run-full-analysis.ps1 -IncludeAI

# Get AI diagnosis of issues
# Output saved to ./output/
```

### Security Audits
```powershell
# Collect system data
.\scripts\collect-logs.ps1

# Get security assessment from AI
.\scripts\run-ai-analysis.ps1 `
    -PromptPath ".\prompts\security-analysis.txt"
```

### Monitoring & Alerts
Schedule regular analysis:
```powershell
# Windows Task Scheduler
# Run daily, save historical reports
# Compare changes over time
```

See [USAGE.md](USAGE.md) for more examples.

---

## ⚙️ Configuration

Edit `config.json` to customize:

```json
{
  "ai": {
    "model": "gpt-4o-mini",      // OpenAI model
    "temperature": 0.3            // 0=factual, 1=creative
  },
  "rules": {
    "minServiceCount": 5,         // Alert threshold
    "requireDNS": true            // Require DNS configured
  }
}
```

---

## 🔍 Example Output

**Data Collection:**
```json
{
  "Hostname": "DESKTOP-ABC123",
  "OS": "Microsoft Windows 11",
  "IPs": ["192.168.1.100"],
  "DNS": ["8.8.8.8", "8.8.4.4"],
  "Services": [...]
}
```

**Analysis Result:**
```
✓ No issues detected

- DNS configured correctly
- All IP addresses valid
- 15 services running (meets minimum of 5)
```

**AI Insights:**
```markdown
# Root Cause Analysis Report
## Summary
System appears healthy with good network configuration.

## Recommendations
1. Enable Windows Firewall logging for security monitoring
2. Review event logs for any warnings or errors
...
```

---

## 🚀 Getting Started

1. **Clone/download** this project
2. **Open PowerShell** in the project directory
3. **Run full analysis:**
   ```powershell
   .\scripts\run-full-analysis.ps1
   ```
4. **View results** in `./output/` folder
5. **For AI features**, [set up API key](#setup-for-ai-features) and add `-IncludeAI` flag

---

## 📋 Requirements

- **PowerShell 5.0+** (Windows 7 SP1, Server 2008 R2 or higher)
- **Internet connection** (for OpenAI API only)
- **OpenAI API key** (optional, only for AI features)
- **Active OpenAI credits** (if using AI features)

---

## 🔒 Security Notes

- **API Keys:** Never hardcode or commit your API key
- **Logs:** Collected logs may contain sensitive data—store securely
- **Output:** Reports may contain system information—treat as sensitive

---

## 📚 Documentation

- **[USAGE.md](USAGE.md)** — Detailed usage guide with examples
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** — Common issues and fixes
- **[config.json](config.json)** — All configuration options

---

## 💭 Limitations

- **Local analysis** is rule-based and limited
- **AI analysis** depends on OpenAI API availability and costs
- **Data collection** is Windows-specific (uses PowerShell/WMI)
- **Results** are only as good as the prompt and model selected

---

## 🎯 Future Enhancements

Potential improvements mentioned in backlog:
- [ ] Output format options (CSV, HTML, JSON)
- [ ] Comparative analysis (before/after changes)
- [ ] Integration with monitoring systems
- [ ] Cross-platform data collection (Linux/macOS)
- [ ] Custom rule engine for analysis
- [ ] Web dashboard for reports

---

## 📝 License

This is a demonstration project for educational purposes.

---

## ❓ Troubleshooting

Having issues? Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for solutions to common problems.
