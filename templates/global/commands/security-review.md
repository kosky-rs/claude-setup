---
description: Security-focused code review before commit - checks for secrets, vulnerabilities, and best practices
---

# Security Review

## 1. Gather Changes

```bash
echo "=== Changed Files ==="
git status --short

echo ""
echo "=== Detailed Diff ==="
git diff --stat
git diff
```

## 2. Secret Detection

Search for potential secrets in changed files:

```bash
echo "=== Checking for Secrets ==="
# API Keys
git diff | grep -iE "(api[_-]?key|apikey)\s*[:=]" || echo "No API keys found"

# Passwords
git diff | grep -iE "(password|passwd|pwd)\s*[:=]" || echo "No passwords found"

# Tokens
git diff | grep -iE "(token|bearer|auth)\s*[:=]" || echo "No tokens found"

# Private Keys
git diff | grep -E "-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----" || echo "No private keys found"

# AWS
git diff | grep -iE "(aws_access_key|aws_secret|AKIA[0-9A-Z]{16})" || echo "No AWS credentials found"

# Generic secrets
git diff | grep -iE "(secret|credential|private)\s*[:=]" || echo "No generic secrets found"
```

## 3. Security Checklist

Review the changes against these criteria:

### Input Validation
- [ ] All user inputs are validated
- [ ] Type checking is enforced
- [ ] Length limits are applied
- [ ] Special characters are properly handled/escaped

### Authentication & Authorization
- [ ] Protected routes require authentication
- [ ] Authorization checks are in place for resource access
- [ ] Session/token handling is secure
- [ ] Password handling follows best practices (hashing, no plaintext)

### Injection Prevention
- [ ] SQL queries use parameterized statements (no string concatenation)
- [ ] HTML output is properly escaped (XSS prevention)
- [ ] Command execution uses safe APIs (no shell injection)
- [ ] File paths are validated (no path traversal)

### Data Protection
- [ ] Sensitive data is not logged
- [ ] Error messages don't expose internal details
- [ ] PII handling follows privacy requirements
- [ ] Encryption is used for sensitive data at rest/in transit

### Dependencies
- [ ] No known vulnerable dependencies added
- [ ] Dependencies are from trusted sources
- [ ] Lock files are updated appropriately

## 4. Sensitive File Check

```bash
echo "=== Checking for Sensitive Files ==="
# Check if any sensitive files are staged
git diff --cached --name-only | grep -iE "\.(env|pem|key|secrets?|credentials?)$" || echo "No sensitive files staged"
git diff --cached --name-only | grep -iE "(secret|credential|password|private)" || echo "No suspicious file names"
```

## 5. Generate Report

```markdown
## 🔒 Security Review Report

### Overview
- **Files Reviewed**: [N]
- **Review Date**: [timestamp]
- **Reviewer**: Claude Code

### Secret Detection Results
| Type | Status | Details |
|------|--------|---------|
| API Keys | [PASS/WARN/FAIL] | [details] |
| Passwords | [PASS/WARN/FAIL] | [details] |
| Tokens | [PASS/WARN/FAIL] | [details] |
| Private Keys | [PASS/WARN/FAIL] | [details] |
| AWS Credentials | [PASS/WARN/FAIL] | [details] |

### Security Checklist Results
| Category | Status | Notes |
|----------|--------|-------|
| Input Validation | [PASS/WARN/FAIL] | [notes] |
| Auth & Authz | [PASS/WARN/FAIL] | [notes] |
| Injection Prevention | [PASS/WARN/FAIL] | [notes] |
| Data Protection | [PASS/WARN/FAIL] | [notes] |
| Dependencies | [PASS/WARN/FAIL] | [notes] |

### Issues Found

#### 🔴 Critical (Must Fix Before Commit)
- [Issue description and location]
- Suggested fix: [how to fix]

#### 🟠 High (Should Fix Before Commit)
- [Issue description and location]
- Suggested fix: [how to fix]

#### 🟡 Medium (Recommend Fixing)
- [Issue description and location]
- Suggested fix: [how to fix]

#### 🟢 Low (Consider for Future)
- [Issue description and location]
- Suggested improvement: [suggestion]

### Verdict

**[ ] PASS** - No security issues found, safe to commit
**[ ] WARN** - Minor issues found, review before committing
**[ ] FAIL** - Critical issues found, must fix before committing
```

## 6. Actions Based on Verdict

### If PASS:
```
✅ Security review passed. You may proceed with:
git add .
git commit -m "your message"
```

### If WARN:
```
⚠️ Security warnings found. Please review the issues above.
If you've verified they are false positives or acceptable:
git add .
git commit -m "your message"
```

### If FAIL:
```
❌ Critical security issues found. Do NOT commit until resolved.

Issues to fix:
1. [Issue 1]
2. [Issue 2]

After fixing, run /security-review again.
```

## Notes

- Run this command BEFORE committing sensitive changes
- This is a supplement to `/review`, not a replacement
- For comprehensive security audits, consider additional tools:
  - `npm audit` for Node.js
  - `pip-audit` for Python
  - `trivy` for container images
  - `gitleaks` for secret detection
