#!/usr/bin/env bash
set -euo pipefail
OWNER=regenrek
ORG=instructa

# Fetch all personal repos
PERSONAL=$(gh repo list "$OWNER" --limit 400 --json name,stargazerCount,description,url,primaryLanguage \
  --jq 'map({name,stars:.stargazerCount,desc:(.description // ""),url,lang:(.primaryLanguage.name // "")})')

# Must-haves (ensure these appear; order by stars desc)
MUST_JSON=$(echo "$PERSONAL" | jq '[.[] | select(.name=="codefetch" or .name=="deepwiki-mcp" or .name=="aidex" or .name=="oplink")] | sort_by(.stars) | reverse')

# Instructa top 8 public
INSTRUCTA=$(gh repo list "$ORG" --limit 400 --json name,stargazerCount,description,url,primaryLanguage,isPrivate \
  --jq 'map(select(.isPrivate==false)) | sort_by(.stargazerCount) | reverse | .[0:8] | map({name,stars:.stargazerCount,desc:(.description // ""),url,lang:(.primaryLanguage.name // "")})')

render_table(){
  # prints a markdown table from JSON array of {name, url, desc, stars}
  echo "| Name | Description | Stars |"
  echo "|---|---:|---:|" | sed 's/---:/---/2' # keep simple separators
  jq -r '.[] | 
    "| [\(.name)](\(.url)) | " +
    (.desc | gsub("\n"; " ") | gsub("\\|"; "\\|")) +
    " | " + ("\(.stars)") + " |"'
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

## Personal Projects
HDR
echo
render_table <<< "$MUST_JSON"
echo
cat << 'INSTR'
## Instructa Highlights
INSTR
echo
render_table <<< "$INSTRUCTA"
cat << 'FTR'
## Activity

![GitHub Contribution Graph](https://ghchart.rshah.org/regenrek)

---

<details>
<summary>How this page works</summary>
This README is generated via `gh` and `jq`. Update by running `scripts/render-readme.sh`.
</details>
FTR
} > README.md
