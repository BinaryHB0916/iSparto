You are the Team Lead. The user has run /security-audit to perform a milestone-level full security audit.

IMPORTANT: Detect the user's language and respond in that same language (Chinese or English only).

Your responsibility: Execute a comprehensive security scan of the entire project, covering code content, file patterns, .gitignore completeness, git history, and dependency safety.

1. Full file content scan:
   - Read `~/.isparto/hooks/process-observer/rules/security-patterns.json`
   - Scan ALL project files (not just staged) against all patterns in secrets, pii, and sensitive_files sections
   - Respect `.secureignore` whitelist if present
   - Report findings grouped by severity: critical → high → warning

2. .gitignore completeness check:
   - Compare the project's .gitignore against the `gitignore_baseline.required` array in security-patterns.json
   - List any missing entries and suggest additions
   - Check if any gitignored file patterns have been force-added with `git add -f` (run `git ls-files -i --exclude-standard`)

3. Git history check:
   - Run `git log -p --all -G 'AKIA|sk-ant-|sk-proj-|BEGIN PRIVATE KEY|sk_test_|sk_live_|ghp_|gho_' -- . ':(exclude)*.md'` to find commits that introduced or removed secrets
   - Note: uses `-G` with regex OR (not multiple `-S` flags, which are AND)
   - If historical leaks found: recommend git filter-repo or BFG Repo-Cleaner, and emphasize that ALL leaked credentials must be rotated immediately

4. Dependency security check (adapt to project tech stack):
   - Node.js: run `npm audit` if package-lock.json exists
   - Python: suggest `pip-audit` or `safety check` if requirements.txt exists
   - iOS: check Podfile.lock for known vulnerable pod versions
   - General: look for suspiciously-named dependencies (typosquatting patterns — common names with character substitution)

5. Output audit report in this format:
   ```
   === Security Audit Report ===
   Scan time: [timestamp]
   Project: [project name]
   Branch: [current branch]

   --- Critical ---
   [findings or "None"]

   --- High ---
   [findings or "None"]

   --- Warning ---
   [findings or "None"]

   --- .gitignore Check ---
   [missing entries or "Complete"]

   --- Git History ---
   [historical leaks or "Clean"]

   --- Dependency Security ---
   [vulnerabilities or "No known vulnerabilities found"]

   --- Summary ---
   [PASS / NEEDS ATTENTION: N issues to resolve]
   ```

$ARGUMENTS
