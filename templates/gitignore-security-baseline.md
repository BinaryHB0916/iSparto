# iSparto Security .gitignore Baseline
# /init-project and /migrate must include the entries below when generating .gitignore.
# Projects may append additional entries based on their tech stack, but must not remove baseline entries.

## ── Sensitive Credential Files ──
.env
.env.*
.env.local
.env.production
*.pem
*.key
*.p12
*.pfx
*.cert
*.crt
*.keystore
*.jks
*.mobileprovision
*.secret
*.secrets
id_rsa
id_ed25519
id_ecdsa
credentials.json
service-account*.json

## ── Claude Code Runtime ──
.claude/

## ── iSparto Security Audit ──
.secureignore

## ── System Files ──
.DS_Store
Thumbs.db
*.swp
*.swo
*~

## ── Dependency Directories (select per tech stack) ──
# Node.js
# node_modules/

# Python
# __pycache__/
# *.pyc
# .venv/

# iOS
# Pods/
# *.xcuserdata/

# Rust
# target/

## ── Build Artifacts ──
*.map
*.dSYM/
proguard-mapping.txt
mapping.txt
*.ipa
*.apk
*.aab
*.tgz

## ── Build Output Directories (select per tech stack) ──
# Web
# dist/
# build/
# out/
# .next/
# .nuxt/
# .output/

# iOS/macOS
# DerivedData/
# *.xcuserdata/

## ── Infrastructure ──
terraform.tfstate
terraform.tfstate.backup
*.tfvars
.terraform/

## ── Debug & Runtime Artifacts ──
*.hprof
*.dmp
npm-debug.log*
yarn-debug.log*
yarn-error.log*

## ── IDE Sensitive Files ──
.idea/workspace.xml
.idea/dataSources.xml
.idea/dataSources.local.xml
.vscode/settings.json
.vscode/launch.json

## ── Backup Files ──
*.bak
*.backup
*.sql
