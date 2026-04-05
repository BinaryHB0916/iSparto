You are the Team Lead. The user has run /release to publish a new version.

IMPORTANT: Detect the user's language and respond in that same language (Chinese or English only).

Your responsibility: Execute the release process step by step. Do not improvise or skip steps.

0. Determine version number:
   - Read VERSION file to get current version
   - Ask the user: "当前版本是 X.Y.Z，新版本号是什么？"（e.g., patch: X.Y.Z+1, minor: X.Y+1.0, major: X+1.0.0）
   - Wait for user confirmation before proceeding

1. Verify preconditions:
   - Current branch must be `main` — if not, run `git checkout main && git pull`
   - Working tree must be clean — if not, report to user and stop
   - CHANGELOG.md must have an `[Unreleased]` section — if not, report to user and stop
   - Tag `v<new-version>` must not already exist — if not, report to user and stop

2. Verify CHANGELOG.md content:
   - Show the user the content under `[Unreleased]`
   - Ask: "这些是本次发版的变更内容，确认发布吗？"
   - Wait for user confirmation before proceeding

3. Execute release script:
   - Run: `bash scripts/release.sh <new-version>`
   - This script handles everything: create release branch → bump VERSION → update CHANGELOG → commit → PR → merge → tag → GitHub Release with assets
   - Monitor output for errors. If any step fails, report the error and the script's suggested recovery command to the user

4. Post-release verification:
   - Confirm GitHub Release exists: `gh release view v<new-version>`
   - Confirm tag exists: `git tag -l v<new-version>`
   - Report: "v<new-version> 已发布。GitHub Release: https://github.com/BinaryHB0916/iSparto/releases/tag/v<new-version>"

CRITICAL RULES:
- NEVER run `git tag` or `git push origin <tag>` directly — the release script handles tagging via GitHub API
- NEVER commit directly on main — the release script creates a `release/` branch automatically
- If the release script fails mid-way, do NOT retry manually — report the error and the recovery command to the user
- This is NOT a development task — do NOT create a feature branch, do NOT spawn Codex, do NOT run Doc Engineer audit. The release script is self-contained.
