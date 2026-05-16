# ai-readiness-audit

> Open-source 26-criterion audit framework for measuring how well a website or API is understood by LLM agents (ChatGPT, Claude, Perplexity, Google AI Overview).

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![ivannikov.pro](https://img.shields.io/badge/by-ivannikov.pro-black)](https://ivannikov.pro)

## Why this exists

In 2025–2026, an increasing share of B2B SaaS and developer-tool discovery happens **inside AI agents** (Claude, ChatGPT, Perplexity, Google AI Overview), not Google. Sites that are not optimised for LLM consumption lose visibility quarter-over-quarter. Most "AI SEO" advice on the internet is generic; this repo gives you a concrete, scored checklist.

## What's in here

| File | Purpose |
|---|---|
| [`audit-checklist.md`](./audit-checklist.md) | 26-criterion checklist with scoring (0–100), grouped into 5 categories. |
| [`entity-authority-checklist.md`](./entity-authority-checklist.md) | Companion 13-criterion checklist for entity authority (50 points). For founder-led brands. |
| [`prompts/audit-prompt.md`](./prompts/audit-prompt.md) | Ready-to-paste Claude / ChatGPT prompt that runs the audit and produces a report. |
| [`scripts/check-ai-readiness.sh`](./scripts/check-ai-readiness.sh) | Bash script that automates technical checks (~80% of category A + E). |
| [`examples/`](./examples/) | Sample audit reports for reference. |

## Quick start

### Manual audit (15–30 minutes per site)

1. Open [`audit-checklist.md`](./audit-checklist.md) and run through 26 criteria.
2. Or paste [`prompts/audit-prompt.md`](./prompts/audit-prompt.md) into Claude / ChatGPT with the target URL.
3. Get a 0–100 score with category breakdown.

### Automated check (30 seconds per site)

```bash
./scripts/check-ai-readiness.sh https://example.com
```

Output: per-category score for criteria the script can detect (`/llms.txt`, `/robots.txt` policy, `/sitemap.xml`, JSON-LD presence, no-JS access, canonical, OpenGraph).

## Scoring summary

```
Total = sum across 5 categories (max 100)
≥75/100 → AI-ready (strong citation prospect)
50–74   → Workable, conversion gaps
30–49   → Significant gaps, AI agents miss content
<30     → Not citable, urgent fix needed
```

**E1 gate**: if content requires JavaScript to be visible, the whole audit is marked **UNRELIABLE** regardless of total — fix this first.

## When to use

- **You run a B2B SaaS** and want to be cited in AI-generated answers for your category.
- **You are an agency / consultant** and want a structured deliverable for AI-optimisation engagements.
- **You are evaluating a vendor** and want to see how AI-ready their docs/API are.
- **You are a founder** preparing to launch and want to be discoverable from day one.

## Methodology background

This checklist adapts and extends the methodology described in [Gumeniuk.com — AI-ready API documentation](https://www.gumeniuk.com/ru/tech/api-docs-llm-era/) (the 26-criterion framework) and incorporates entity authority signals based on observed LLM retrieval behaviour in 2025–2026.

Differences from the original 26-criterion framework:
- Re-weighted under B2B SaaS ICP (Category C — API spec — carries 25 pts).
- E1 gate ("content without JS") is a hard pre-condition, not a scoring criterion.
- Companion **entity authority** checklist (13 criteria, 50 pts) for founder-led brands where personal/organisation entity recognition matters.

## Roadmap

- [x] v0.1 — checklist + manual prompt
- [ ] v0.2 — `scripts/check-ai-readiness.sh` covers all auto-detectable criteria
- [ ] v0.3 — npm package `@ivannikov-pro/ai-readiness` for programmatic use
- [ ] v0.4 — GitHub Action for AI-readiness CI gate
- [ ] v0.5 — Claude skill format for `~/.claude/skills/`

## Contributing

Issues and PRs welcome. Particularly valuable: real-world audit reports for popular B2B SaaS (Stripe, Twilio, Linear, Notion, Vercel, etc.) — drop them in `examples/` as anonymised case studies.

## Commercial implementation

This is the open-source methodology. If you want someone to actually run the audit, implement fixes, and track AI Visibility Score over time — that's a paid service. See [ivannikov.pro/en/services/ai-optimisation](https://ivannikov.pro/en/services/ai-optimisation).

## License

MIT — see [LICENSE](./LICENSE).

## Author

Aleksandr Ivannikov / [IVANNIKOV.PRO](https://ivannikov.pro) — premium engineering studio.

13+ years of shipping production systems for B2B SaaS, AI-native products, and Web3 teams.

- GitHub: [@ivannikov-pro](https://github.com/ivannikov-pro)
- LinkedIn: [an-ivannikov](https://linkedin.com/in/an-ivannikov)
- Telegram: [@ivannikov_pro](https://t.me/ivannikov_pro)
- X / Twitter: [@ivannikov_pro](https://x.com/ivannikov_pro)
