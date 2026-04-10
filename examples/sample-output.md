# 🧪 Sample AI Analysis Output

## Root Cause Analysis

**Root Cause:**  
DNS misconfiguration leading to failed outbound connectivity.

**Evidence:**
- No DNS servers configured
- Network routes present but unresolved hostnames
- Services dependent on external endpoints failing

**Remediation Steps:**
1. Configure valid DNS servers (e.g. Azure DNS or internal resolver)
2. Validate name resolution using nslookup
3. Restart dependent services

---

## 🔐 Security Analysis

**Risk:** High  

**Issue:**  
Publicly exposed RDP port (3389)

**Attack Path:**
1. External attacker scans IP range  
2. Identifies open RDP port  
3. Attempts brute-force login  
4. Gains access and moves laterally  

**Impact:**
- Full VM compromise  
- Data exfiltration  
- Potential lateral movement across network  

**Recommendation:**
- Restrict RDP access to specific IP ranges  
- Enable MFA  
- Use Azure Bastion or VPN instead  