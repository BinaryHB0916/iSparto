You are the Team Lead. The user has run /release to publish a new version.

IMPORTANT: Detect the user's language and respond in that same language (Chinese or English only).

Your responsibility: Execute the release process fully automatically. No confirmations, no pauses.

## Version calculation

Parse the user's argument (if any) to determine bump type:
- `/release` or `/release patch` → patch (X.Y.Z+1)
- `/release minor` → minor (X.Y+1.0)
- `/release major` → major (X+1.0.0)

Read the VERSION file, compute the new version number.

## Execution

1. Verify preconditions (all must pass — if any fails, report and stop):
   - Current branch must be `main` — if not, run `git checkout main && git pull`
   - Working tree must be clean
   - CHANGELOG.md must have an `[Unreleased]` section with content
   - Tag `v<new-version>` must not already exist

2. Execute release script:
   - Run: `bash scripts/release.sh <new-version>`
   - Monitor output for errors. If any step fails, report the error and the script's suggested recovery command to the user

3. Post-release verification:
   - Confirm GitHub Release exists: `gh release view v<new-version>`
   - Confirm tag exists locally: `git fetch --tags && git tag -l v<new-version>`
   - Output: "v<new-version> 已发布。GitHub Release: https://github.com/BinaryHB0916/iSparto/releases/tag/v<new-version>"

CRITICAL RULES:
- NEVER run `git tag` or `git push origin <tag>` directly — the release script handles tagging via GitHub API
- NEVER commit directly on main — the release script creates a `release/` branch automatically
- If the release script fails mid-way, do NOT retry manually — report the error and the recovery command to the user
- This is NOT a development task — do NOT create a feature branch, do NOT spawn Codex, do NOT run Doc Engineer audit. The release script is self-contained.
