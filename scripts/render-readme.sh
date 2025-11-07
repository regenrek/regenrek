#!/usr/bin/env bash
set -euo pipefail
OWNER=regenrek
ORG=instructa
# Fetch all personal repos
PERSONAL=$(gh repo list "$OWNER" --limit 400 --json name,stargazerCount,description,url,primaryLanguage --jq 'map({name,stars:.stargazerCount,desc:(.description // ""),url,lang:(.primaryLanguage.name // "")})')
# Must-haves
MUST_JSON=$(echo "$PERSONAL" | jq '[.[] | select(.name=="codefetch" or .name=="deepwiki-mcp" or .name=="aidex" or .name=="oplink")]')
# Top additional six
TOP_JSON=$(jq -n --argjson all "$PERSONAL" --argjson must "$MUST_JSON" '
  [$all[], $must[]] as $both | 
  ($all | map(select(.name as $n | ($must | map(.name) | index($n)) | not)) 
  | sort_by(.stars) | reverse | .[0:6])')
# Instructa top 8 public
INSTRUCTA=$(gh repo list "$ORG" --limit 400 --json name,stargazerCount,description,url,primaryLanguage,isPrivate --jq 'map(select(.isPrivate==false)) | sort_by(.stargazerCount) | reverse | .[0:8] | map({name,stars:.stargazerCount,desc:(.description // ""),url,lang:(.primaryLanguage.name // "")})')

render_cards(){
  jq -r '.[] | "- **[\(.name)](\(.url))** — ⭐ \(.stars)\n  - \(.desc)\n"'
}

{
cat << 'HDR'
<!-- Auto-generated: Profile README for @regenrek -->

# Hi, I’m Rene 👋

Builder of AI‑first developer tools. Shipping fast, learning faster.

<p>
  <a href="https://x.com/kregenrek"><img alt="X" src="https://img.shields.io/badge/-@kregenrek-000000?style=flat&logo=x&logoColor=white"></a>
  <a href="https://instructa.ai/"><img alt="Instructa" src="https://img.shields.io/badge/-instructa.ai-2563EB?style=flat"></a>
  <a href="https://www.macherjek.at/"><img alt="Macherjek" src="https://img.shields.io/badge/-macherjek.at-10B981?style=flat"></a>
</p>

> Building tools that make agents and developers more effective, with a bias for simple CLIs and MCP servers.

## Featured Personal Projects
HDR
echo "$MUST_JSON" | render_cards
cat << 'MID'
### More Personal Picks
MID
echo "$TOP_JSON" | render_cards
cat << 'INSTR'
## Instructa Highlights
INSTR
echo "$INSTRUCTA" | render_cards
cat << 'FTR'
## Activity

![GitHub Contribution Graph](https://ghchart.rshah.org/regenrek)

---

<details>
<summary>How this page works</summary>
This README is generated via `gh` and `jq`. Want an update? Run `scripts/render-readme.sh`.
</details>
FTR
} > README.md
