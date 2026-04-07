# iSparto Security Audit System

## Three-Layer Defense

### Layer 1: Real-time Write Gate (PreToolUse hook extension)

Triggered in real time whenever the Write/Edit tool writes content.

Checks:
- 5 critical-level secret patterns (AWS Key, Anthropic Key, Private Key, Stripe Key, GitHub Token)
- On match → block the write and prompt the user to use an environment variable or config reference

Configuration:
- Rule definition: the `realtime_critical` field in `security-patterns.json`
- Execution script: `pre-tool-check.sh` (an extension of the existing script)

Characteristics:
- Intercepts before the secret reaches the file (one step earlier than pre-commit)
- Only the critical subset is checked, keeping hook performance unaffected

### Layer 2: Pre-commit Gate

Triggered automatically before each `/end-working` commit.

Checks:
- Full secret scan: all secrets and pii patterns (critical/high match → block commit)
- Sensitive file detection: whether files such as .env, .pem, .key are staged (match → block)
- PII detection: phone numbers, ID numbers, bank card numbers (match → warn, do not block)

Configuration:
- Rule definition: `~/.isparto/hooks/process-observer/rules/security-patterns.json`
- Scan script: `~/.isparto/hooks/process-observer/scripts/pre-commit-security.sh`
- Allowlist: `.secureignore` in the project root

### Layer 3: Milestone Audit

Triggered manually via the `/security-audit` command at Phase completion or before release.

Coverage:
- Full file scan (not just staged)
- .gitignore completeness against the baseline
- Leak traces in git history (regex scan via `git log -G`)
- Dependency security vulnerabilities

### Sensitive File Classification

The `sensitive_files` section of security-patterns.json is organized into the following categories:

| Category | Typical Files | Risk |
|----------|---------------|------|
| Credential files | .env, *.key, *.pem, *.p12 | Directly exposes keys |
| Build artifacts | *.map, *.dSYM, proguard-mapping.txt | Exposes full source code (source map incident) |
| Infrastructure state | terraform.tfstate, *.tfvars | Contains plaintext passwords and connection strings |
| Debug artifacts | core dump, *.hprof, hs_err_pid*.log | Contains sensitive data from memory |
| IDE configuration | .idea/dataSources.xml, .idea/tasks.xml | Contains database passwords and server credentials |
| Release artifacts | *.tgz, *.whl, *.ipa, *.apk | Should not enter the source repository |
| Backup files | *.bak, *.old, *.orig | May contain old credentials or sensitive data |

### Wave-level Review (embedded in the existing workflow)

Security checks are automatically included in each Wave's Codex code review and Doc Engineer documentation audit:

Codex review covers:
- Hardcoded credentials
- Debug logs leaking sensitive data
- Suspicious dependencies

Doc Engineer audit covers:
- Credentials in code
- .gitignore completeness
- Real credentials / personal information in documentation
- Trustworthiness of third-party dependencies

## Relationship with dangerous-operations.json

The two rule sets are complementary and do not overlap:

| Rule Set | Interception Layer | Interception Target |
|----------|--------------------|---------------------|
| dangerous-operations.json | Bash commands | Blocks **execution** of commands such as `git add .env`, `cat .env` |
| security-patterns.json | File contents | Blocks **writing/committing** code content that contains secrets |

## False-Positive Handling

Create a `.secureignore` file in the project root, one entry per line, in the following format:

```
# file_path:pattern_id:reason
# file_path:reason  (matches all patterns for this file)
test/fixtures/mock-credentials.json:test fixtures with fake data
src/constants.ts:email-hardcoded:support email is intentionally hardcoded
```

Before scanning, the pre-commit scanner reads this file and skips the matching file:pattern combinations.

## Leak Incident Response

If a leaked credential is discovered:
1. **Rotate immediately** — replace all leaked keys/tokens
2. Purge from git history using `git filter-repo` or `BFG Repo-Cleaner`
3. Force push to the remote repository
4. Notify all collaborators to re-clone
5. Record in the technical decision log of docs/plan.md
