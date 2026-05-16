#!/usr/bin/env bash
#
# check-ai-readiness.sh — automated subset of the AI-Readiness Audit
# Detects approximately 60% of criteria via HTTP fetches (no JS execution).
# For full audit, complement with the manual checklist or the audit-prompt.md.
#
# Usage:
#   ./check-ai-readiness.sh https://example.com
#
# Exit codes:
#   0 — score ≥ 75 (AI-ready)
#   1 — score 50–74 (workable)
#   2 — score 30–49 (significant gaps)
#   3 — score < 30 OR E1 fail (not citable / unreliable)

set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <url>"
  exit 64
fi

URL="${1%/}"  # strip trailing slash
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# User-Agent: pretend to be GPTBot to see what LLM crawlers see
UA="Mozilla/5.0 (compatible; GPTBot/1.0; +https://openai.com/gptbot)"

# Helpers
fetch() {
  curl -s -A "$UA" -L --max-time 10 -o /dev/null -w "%{http_code}" "$1" || echo "000"
}

fetch_body() {
  curl -s -A "$UA" -L --max-time 10 "$1" 2>/dev/null || echo ""
}

score=0
maxscore=0
notes=()

check() {
  local pts="$1" name="$2" status="$3" detail="$4"
  maxscore=$((maxscore + pts))
  if [ "$status" = "PASS" ]; then
    score=$((score + pts))
    notes+=("✅ ${name} (${pts}/${pts}) — ${detail}")
  elif [ "$status" = "PARTIAL" ]; then
    local half=$((pts / 2))
    score=$((score + half))
    notes+=("🟠 ${name} (${half}/${pts}) — ${detail}")
  else
    notes+=("❌ ${name} (0/${pts}) — ${detail}")
  fi
}

echo "AI-Readiness Audit: $URL"
echo "Timestamp: $TS"
echo "User-Agent: GPTBot impersonation"
echo "---"

# E1 (PRE-CONDITION) — content without JS
root_html=$(fetch_body "$URL")
if echo "$root_html" | grep -qiE "<main|<article|<section.*content"; then
  e1="PASS"
  e1_detail="HTML content visible without JS execution"
else
  e1="FAIL"
  e1_detail="Body appears empty or JS-rendered — LLM crawlers cannot read content"
fi
check 6 "E1 / no-JS access" "$e1" "$e1_detail"

# A1 — /llms.txt
llms_status=$(fetch "$URL/llms.txt")
if [ "$llms_status" = "200" ]; then
  llms_body=$(fetch_body "$URL/llms.txt")
  if echo "$llms_body" | head -1 | grep -q "^# "; then
    check 6 "A1 / llms.txt with H1" "PASS" "Present, $(echo "$llms_body" | wc -l | tr -d ' ') lines"
  else
    check 6 "A1 / llms.txt present but malformed" "PARTIAL" "Present but missing H1 header"
  fi
else
  check 6 "A1 / llms.txt" "FAIL" "HTTP $llms_status — file missing"
fi

# A2 — /llms-full.txt
llms_full_status=$(fetch "$URL/llms-full.txt")
if [ "$llms_full_status" = "200" ]; then
  check 5 "A2 / llms-full.txt" "PASS" "Present"
else
  check 5 "A2 / llms-full.txt" "FAIL" "HTTP $llms_full_status — file missing"
fi

# A3 — /robots.txt with AI policy
robots_status=$(fetch "$URL/robots.txt")
if [ "$robots_status" = "200" ]; then
  robots_body=$(fetch_body "$URL/robots.txt")
  ai_agents=$(echo "$robots_body" | grep -ciE "(GPTBot|ClaudeBot|PerplexityBot|Google-Extended|cohere-ai|anthropic-ai|meta-externalagent|Applebot-Extended)" || true)
  if [ "$ai_agents" -ge 3 ]; then
    check 4 "A3 / robots.txt AI policy" "PASS" "$ai_agents AI crawler entries found"
  elif [ "$ai_agents" -ge 1 ]; then
    check 4 "A3 / robots.txt AI policy" "PARTIAL" "Only $ai_agents AI crawler entries — add more"
  else
    check 4 "A3 / robots.txt AI policy" "FAIL" "Generic robots.txt, no AI directives"
  fi
else
  check 4 "A3 / robots.txt" "FAIL" "HTTP $robots_status — missing"
fi

# A4 — /sitemap.xml
sitemap_status=$(fetch "$URL/sitemap.xml")
if [ "$sitemap_status" = "200" ]; then
  sitemap_body=$(fetch_body "$URL/sitemap.xml")
  if echo "$sitemap_body" | grep -q "<lastmod>"; then
    check 3 "A4 / sitemap.xml with lastmod" "PASS" "Has lastmod tags"
  else
    check 3 "A4 / sitemap.xml" "PARTIAL" "Present but no lastmod tags"
  fi
else
  check 3 "A4 / sitemap.xml" "FAIL" "HTTP $sitemap_status"
fi

# B2 — JSON-LD on home page
if echo "$root_html" | grep -qE 'type="application/ld\+json"'; then
  if echo "$root_html" | grep -qE '"@type":\s*"(TechArticle|Article|APIReference|Person|Organization)"'; then
    check 5 "B2 / JSON-LD schema" "PASS" "TechArticle/Person/Organization schema present"
  else
    check 5 "B2 / JSON-LD schema" "PARTIAL" "JSON-LD present but generic"
  fi
else
  check 5 "B2 / JSON-LD schema" "FAIL" "No JSON-LD detected"
fi

# B3 — canonical link
if echo "$root_html" | grep -qiE '<link[^>]+rel="canonical"'; then
  check 4 "B3 / canonical link" "PASS" "Present"
else
  check 4 "B3 / canonical link" "FAIL" "Missing"
fi

# B5 — OpenGraph
og_count=$(echo "$root_html" | grep -ciE '<meta[^>]+property="og:' || true)
if [ "$og_count" -ge 4 ]; then
  check 3 "B5 / OpenGraph tags" "PASS" "$og_count og:* tags found"
elif [ "$og_count" -ge 2 ]; then
  check 3 "B5 / OpenGraph tags" "PARTIAL" "Only $og_count og:* tags — add og:title, og:description, og:image, og:url"
else
  check 3 "B5 / OpenGraph tags" "FAIL" "No OpenGraph tags"
fi

# E2 — Stable URLs (heuristic: no hash routing in nav)
if echo "$root_html" | grep -qE 'href="#/' || echo "$root_html" | grep -qE 'href="/#'; then
  check 4 "E2 / Stable URLs" "FAIL" "Hash-routing detected — bad for LLM crawlers"
else
  check 4 "E2 / Stable URLs" "PASS" "No hash routing observed"
fi

# Output
echo "---"
for note in "${notes[@]}"; do
  echo "$note"
done
echo "---"

# Normalize to 0-100 scale (out of partial max)
normalized=$(awk -v s="$score" -v m="$maxscore" 'BEGIN { printf "%.0f\n", (s/m)*100 }')
echo "Score: $score/$maxscore (automated subset) — normalized $normalized/100"

if [ "$e1" = "FAIL" ]; then
  echo "⚠️  *UNRELIABLE* — E1 pre-condition failed. Site requires JS for content."
  exit 3
fi

if [ "$normalized" -ge 75 ]; then
  echo "Status: AI-ready (strong citation prospect)"
  exit 0
elif [ "$normalized" -ge 50 ]; then
  echo "Status: Workable, conversion gaps"
  exit 1
elif [ "$normalized" -ge 30 ]; then
  echo "Status: Significant gaps — AI agents miss content"
  exit 2
else
  echo "Status: Not citable — urgent fix needed"
  exit 3
fi
