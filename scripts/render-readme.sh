#!/usr/bin/env bash
set -euo pipefail

OWNER=regenrek
ORG=instructa

# Fetch personal repos (all)
PERSONAL=$(gh repo list "$OWNER" --limit 400 --json name,stargazerCount,description,url,primaryLanguage \
  --jq 'map({name,stars:.stargazerCount,desc:(.description // ""),url,lang:(.primaryLanguage.name // "")})')

# Fetch instructa repos (all public)
INSTRUCTA_ALL=$(gh repo list "$ORG" --limit 400 --json name,stargazerCount,description,url,primaryLanguage,isPrivate \
  --jq 'map(select(.isPrivate==false)) | map({name,stars:.stargazerCount,desc:(.description // ""),url,lang:(.primaryLanguage.name // "")})')

# Keep both for lookup (prefer instructa when duplicate names exist)

# Helpers
table_header(){
  echo "| Name | Description | Stars |"
  echo "|---|---|---|"
}

map_alias(){
  case "$1" in
    "constructer-starter") echo "constructa-starter" ;;
    "codex 1-up") echo "codex-1up" ;;
    *) echo "$1" ;;
  esac
}

render_row(){
  local name="$1"; shift || true
  local tag="${1:-}"
  local canon
  canon=$(map_alias "$name")
  jq -nr --argjson instr "$INSTRUCTA_ALL" --argjson pers "$PERSONAL" --arg name "$canon" --arg tag "$tag" '
    ( ($instr | map(select(.name==$name))) + ($pers | map(select(.name==$name))) ) | .[0] as $r |
    select($r) |
    "| [\($r.name)](\($r.url))" + (if $tag=="NEW" then " <sup>NEW</sup>" else "" end) +
    " | " + ($r.desc // "") +
    " | " + ($r.stars|tostring) +
    " |"'
}

render_section(){
  local title="$1"; shift
  echo "## $title"
  echo
  table_header
  for spec in "$@"; do
    local name tag
    name="${spec%%:*}"
    tag="${spec#*:}"
    if [ "$name" = "$tag" ]; then tag=""; fi
    render_row "$name" "$tag" || true
  done
  echo
}

{
cat << 'HDR'
<!-- Auto-generated: Profile README for @regenrek -->

# Servus!

Building AI tools to driving my coding agent to the max.

<p>
  <a href="https://x.com/kregenrek"><img alt="X" src="https://img.shields.io/badge/-@kregenrek-000000?style=flat&logo=x&logoColor=white"></a>
  <a href="https://instructa.ai/"><img alt="Instructa" src="https://img.shields.io/badge/-instructa.ai-2563EB?style=flat"></a>
  <a href="https://www.macherjek.at/"><img alt="Macherjek" src="https://img.shields.io/badge/-macherjek.at-10B981?style=flat"></a>
</p>

HDR

# Sections in custom order
render_section "AI Workflow Tools" \
  "oplink:NEW" \
  "browser-echo" \
  "codefetch" \
  "aidex"

render_section "Starter Kits" \
  "constructa-starter-min" \
  "constructer-starter" \
  "mcp-starter" \
  "viber3d"

render_section "MCP Server" \
  "deepwiki-mcp"

render_section "CLI Tools" \
  "codex 1-up" \
  "slash-commands"

render_section "Other" \
  "ai-prompts" \
  "planr"
} > README.md
