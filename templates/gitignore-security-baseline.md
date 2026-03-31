# iSparto Security .gitignore Baseline
# /init-project 和 /migrate 在生成 .gitignore 时必须包含以下条目。
# 项目可以在此基础上根据技术栈追加条目，但不得删除基线条目。

## ── 敏感凭证文件 ──
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

## ── Claude Code 运行时 ──
.claude/

## ── iSparto 安全审计 ──
.secureignore

## ── 系统文件 ──
.DS_Store
Thumbs.db
*.swp
*.swo
*~

## ── 依赖目录（按技术栈选用） ──
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

## ── 构建产物 ──
*.map
*.dSYM/
proguard-mapping.txt
mapping.txt
*.ipa
*.apk
*.aab
*.tgz

## ── 构建输出目录（按技术栈选用） ──
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

## ── 基础设施 ──
terraform.tfstate
terraform.tfstate.backup
*.tfvars
.terraform/

## ── 调试与运行时产物 ──
*.hprof
*.dmp
npm-debug.log*
yarn-debug.log*
yarn-error.log*

## ── IDE 敏感文件 ──
.idea/workspace.xml
.idea/dataSources.xml
.idea/dataSources.local.xml
.vscode/settings.json
.vscode/launch.json

## ── 备份文件 ──
*.bak
*.backup
*.sql
