#!/usr/bin/env bash
#
# track-ai-visibility.sh — v0.1 AI Visibility Tracker
#
# Queries Perplexity API with category prompts and parses results for:
#   1. Direct brand mentions in answer text
#   2. Domain citations in source panel
#   3. Competitor presence
#
# Usage:
#   ./scripts/track-ai-visibility.sh <brand_domain> <prompt_file>
#
# Example:
#   ./scripts/track-ai-visibility.sh ivannikov.pro prompts/saas-engineering.txt
#
# Requires:
#   - PPLX_API_KEY environment variable
#   - jq command
#   - curl command
#
# Cost estimate: $0.005 per query × 10 queries = $0.05 per tracking run.
# Run weekly via cron for trend tracking.

set -euo pipefail

# ---- Args ----
if [ $# -lt 2 ]; then
  echo "Usage: $0 <brand_domain> <prompts_file>"
  echo ""
  echo "  brand_domain: bare domain (e.g., ivannikov.pro) — script searches answer for both 'ivannikov.pro' and 'IVANNIKOV')"
  echo "  prompts_file: text file with one prompt per line (e.g., 'best AI optimization services for B2B SaaS')"
  echo ""
  echo "Example prompts file:"
  echo "  best AI readiness audit tools 2026"
  echo "  how to improve LLM citation rate for B2B SaaS"
  echo "  Perplexity vs ChatGPT for B2B research"
  exit 64
fi

BRAND_DOMAIN="${1}"
PROMPTS_FILE="${2}"

if [ ! -f "$PROMPTS_FILE" ]; then
  echo "Error: prompts file '$PROMPTS_FILE' not found"
  exit 1
fi

if [ -z "${PPLX_API_KEY:-}" ]; then
  echo "Error: PPLX_API_KEY environment variable not set"
  echo "Get a key at https://www.perplexity.ai/settings/api"
  exit 1
fi

# Required tools
command -v jq >/dev/null || { echo "Error: jq required"; exit 1; }
command -v curl >/dev/null || { echo "Error: curl required"; exit 1; }

# Extract brand name (assume domain root, e.g., ivannikov.pro → "ivannikov")
BRAND_NAME=$(echo "$BRAND_DOMAIN" | awk -F. '{print $1}')

TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "AI Visibility Tracker v0.1"
echo "=========================="
echo "Brand: $BRAND_DOMAIN ($BRAND_NAME)"
echo "Prompts: $PROMPTS_FILE"
echo "Timestamp: $TS"
echo "API: Perplexity Sonar"
echo ""

# Counters
TOTAL=0
MENTIONS=0
CITATIONS=0
declare -a UNMENTIONED_PROMPTS=()

# Iterate prompts
while IFS= read -r prompt || [ -n "$prompt" ]; do
  # Skip empty lines and comments
  [ -z "$prompt" ] && continue
  case "$prompt" in \#*) continue ;; esac
  TOTAL=$((TOTAL + 1))

  echo "──────────────────────────────────────────────"
  echo "[$TOTAL] Prompt: $prompt"

  # Call Perplexity API
  response=$(curl -s -X POST "https://api.perplexity.ai/chat/completions" \
    -H "Authorization: Bearer $PPLX_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg p "$prompt" '{
      model: "sonar",
      messages: [{role: "user", content: $p}]
    }')")

  # Check API error
  if echo "$response" | jq -e '.error' >/dev/null 2>&1; then
    echo "  ⚠️  API error: $(echo "$response" | jq -r '.error.message // .error')"
    continue
  fi

  # Extract answer text + citations
  answer=$(echo "$response" | jq -r '.choices[0].message.content // ""')
  citations=$(echo "$response" | jq -r '.citations[]? // empty' 2>/dev/null || true)

  # Check brand mention in answer (case-insensitive, both domain and brand name)
  brand_mentioned="no"
  if echo "$answer" | grep -qiE "(${BRAND_DOMAIN}|${BRAND_NAME})"; then
    brand_mentioned="yes"
    MENTIONS=$((MENTIONS + 1))
    echo "  ✅ Mentioned in answer"
  else
    echo "  ❌ Not mentioned in answer"
    UNMENTIONED_PROMPTS+=("$prompt")
  fi

  # Check domain in citations
  domain_cited="no"
  if [ -n "$citations" ] && echo "$citations" | grep -qiE "$BRAND_DOMAIN"; then
    domain_cited="yes"
    CITATIONS=$((CITATIONS + 1))
    echo "  ✅ Cited as source"
  else
    echo "  ❌ Not in source citations"
  fi

  # Show top citation domains (for competitor analysis)
  if [ -n "$citations" ]; then
    echo "  Top 3 cited sources:"
    echo "$citations" | head -3 | awk '{ split($0, a, "/"); print "    - " a[3] }'
  fi

  # Throttle to avoid hitting rate limits
  sleep 2
done < "$PROMPTS_FILE"

# ---- Summary ----
echo ""
echo "═══════════════════════════════════════════════"
echo "SUMMARY ($TS)"
echo "═══════════════════════════════════════════════"
echo "Brand: $BRAND_DOMAIN"
echo "Total prompts: $TOTAL"
echo "Answer mentions: $MENTIONS / $TOTAL ($(awk -v m=$MENTIONS -v t=$TOTAL 'BEGIN { printf "%.1f", m/t*100 }')%)"
echo "Source citations: $CITATIONS / $TOTAL ($(awk -v c=$CITATIONS -v t=$TOTAL 'BEGIN { printf "%.1f", c/t*100 }')%)"
echo ""

# Visibility score = weighted average (mentions weighted 1x, citations 0.7x — both signal but mentions stronger)
score=$(awk -v m=$MENTIONS -v c=$CITATIONS -v t=$TOTAL 'BEGIN {
  if (t == 0) { print 0; exit }
  score = ((m / t * 100) + (c / t * 70)) / 2
  printf "%.1f", score
}')

echo "AI Visibility Score (0-100): $score"
echo ""

# Unmentioned prompts list
if [ ${#UNMENTIONED_PROMPTS[@]} -gt 0 ]; then
  echo "Unmentioned prompts (opportunity targets):"
  for p in "${UNMENTIONED_PROMPTS[@]}"; do
    echo "  - $p"
  done
  echo ""
fi

# JSON output for programmatic tracking
JSON_OUTPUT="ai-visibility-$BRAND_NAME-$(date -u +%Y%m%d-%H%M%S).json"
jq -n \
  --arg brand "$BRAND_DOMAIN" \
  --arg ts "$TS" \
  --argjson total "$TOTAL" \
  --argjson mentions "$MENTIONS" \
  --argjson citations "$CITATIONS" \
  --arg score "$score" \
  '{
    brand: $brand,
    timestamp: $ts,
    total_prompts: $total,
    mentions: $mentions,
    citations: $citations,
    visibility_score: ($score | tonumber)
  }' > "$JSON_OUTPUT"

echo "JSON snapshot saved: $JSON_OUTPUT"
echo ""
echo "To track over time, run this weekly via cron and compare JSON snapshots."
echo ""

# Exit code based on score
if [ "$(echo "$score >= 50" | awk '{print ($1)}')" = "1" ]; then
  exit 0
elif [ "$(echo "$score >= 25" | awk '{print ($1)}')" = "1" ]; then
  exit 1
else
  exit 2
fi
