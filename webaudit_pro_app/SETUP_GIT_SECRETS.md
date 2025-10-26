# Git Secrets Setup Guide

This guide helps you set up git-secrets to prevent accidental credential commits.

## Installation

### Option 1: Manual Installation (Windows)

1. **Download git-secrets**
   - Visit: https://github.com/awslabs/git-secrets/releases
   - Download the latest release (e.g., `git-secrets-1.3.0.windows.zip`)

2. **Extract and Setup**
   ```powershell
   # Extract to a location in PATH (or add location to PATH)
   # Example: C:\Program Files\git-secrets\

   # Verify installation
   git secrets --version
   ```

3. **Initialize git-secrets in repository**
   ```powershell
   cd C:\Users\Ntro\weblser\webaudit_pro_app
   git secrets --install
   ```

### Option 2: Using Git Bash or WSL

```bash
cd /c/Users/Ntro/weblser/webaudit_pro_app

# Clone and build from source
git clone https://github.com/awslabs/git-secrets.git
cd git-secrets
make install

# Initialize in repository
cd /c/Users/Ntro/weblser/webaudit_pro_app
git secrets --install
```

## Configuration

After installation, configure patterns to detect:

```bash
cd C:\Users\Ntro\weblser\webaudit_pro_app

# Register AWS patterns
git secrets --register-aws

# Add custom pattern for JWT tokens (Supabase/Firebase)
git secrets --add 'eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*'

# Add pattern for Supabase tokens
git secrets --add 'sbp_[a-f0-9]{40}'

# List all registered patterns
git secrets --list
```

## Usage

### Before Committing
```bash
# Scan current changes
git secrets --scan

# Scan all files
git secrets --scan-history
```

### Automatic Checks
Once installed, git-secrets automatically:
- Scans before each commit (via pre-commit hook)
- Blocks commits with detected secrets
- Shows warning messages with matched patterns

### Example Output
```
[main 851a154] security: Implement environment variables
 ...
.env:1: Matched pattern: eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*

[secrets] Matched 1 pattern(s)

Aborting commit due to detected secrets in:
  .env

To ignore a specific match, add it to .gitignore and remove from staging area
```

## Troubleshooting

### "git secrets: command not found"
- Check installation location is in PATH
- Restart terminal/IDE after installation
- Verify `git secrets --version` works

### False Positives
If you have legitimate non-secret strings matching patterns:

```bash
# Temporarily allow a specific commit
git commit --no-verify

# Remove pattern (if too many false positives)
git secrets --remove 'pattern-text'

# Add allowlist patterns
git secrets --add --allowed 'allowed-pattern'
```

## Integration with CI/CD

Add to your CI/CD pipeline (e.g., GitHub Actions):

```yaml
- name: Install git-secrets
  run: |
    git clone https://github.com/awslabs/git-secrets.git
    cd git-secrets && make install

- name: Scan for secrets
  run: git secrets --scan-history
```

## Additional Security Measures

1. **Use pre-commit framework**
   ```bash
   pip install pre-commit
   ```

   Create `.pre-commit-config.yaml`:
   ```yaml
   repos:
     - repo: https://github.com/awslabs/git-secrets
       rev: master
       hooks:
         - id: git-secrets
   ```

2. **Enable GitHub secret scanning**
   - Go to repository Settings → Security & analysis
   - Enable "Secret scanning"
   - Enable "Push protection"

3. **Regular audits**
   ```bash
   # Monthly scan
   git secrets --scan-history
   ```

## References

- Git Secrets GitHub: https://github.com/awslabs/git-secrets
- GitHub Secret Scanning: https://docs.github.com/en/code-security/secret-scanning
- OWASP Secrets Management: https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html

---

**Note**: After completing setup, run `git secrets --scan-history` to verify no secrets exist in commit history.
