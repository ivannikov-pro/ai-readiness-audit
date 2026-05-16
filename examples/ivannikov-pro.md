# AI Readiness Audit: ivannikov.pro

> Sample audit report — the methodology applied to its own author's site as a meta self-case.

**Score**: 80/100 (automated subset) / ~69/100 (full manual)
**Date**: 2026-05-16
**E1 gate**: PASS
**Tool**: `scripts/check-ai-readiness.sh`

---

## Automated check output

```
AI-Readiness Audit: https://ivannikov.pro
User-Agent: GPTBot impersonation

✅ E1 / no-JS access (6/6) — HTML content visible without JS execution
✅ A1 / llms.txt with H1 (6/6) — Present, 42 lines
✅ A2 / llms-full.txt (5/5) — Present
✅ A3 / robots.txt AI policy (4/4) — 8 AI crawler entries found
✅ A4 / sitemap.xml with lastmod (3/3) — Has lastmod tags
❌ B2 / JSON-LD schema (0/5) — No JSON-LD detected (script v0.1 regex bug — actually present)
✅ B3 / canonical link (4/4) — Present
❌ B5 / OpenGraph tags (0/3) — No OpenGraph tags (script v0.1 regex bug — actually present)
✅ E2 / Stable URLs (4/4) — No hash routing observed

Score: 32/40 (automated subset) — normalized 80/100
Status: AI-ready (strong citation prospect)
```

**Note**: the script v0.1 has known regex issues for JSON-LD and OpenGraph detection — the actual site has both (verified manually). Full manual audit gives ~88/100 after correcting for false negatives.

---

## Per-category breakdown (manual audit)

### A. Discovery: 18/18
- `/llms.txt`: present, llmstxt.org-compliant. ✅
- `/llms-full.txt`: present, ~3000 words. ✅
- `/robots.txt`: explicit Allow for 20+ AI crawlers (GPTBot, ClaudeBot, PerplexityBot, Google-Extended, etc.). ✅
- `/sitemap.xml`: generated via Next.js `app/sitemap.ts`, 43 pages, lastmod present. ✅

### B. Per-page artifacts: ~12/22
- `.md` mirrors per page: **MISSING** — recommended Quick win (+6 pts).
- JSON-LD: Person + Organization schema with `alternateName`, `worksFor`, `knowsAbout` (15 terms). ✅ (3/5 — could be +2 with per-page TechArticle on blog posts).
- canonical: present in layout `alternates`. ✅
- Last-Modified / dateModified: partial — Next.js doesn't set Last-Modified for SSG, but JSON-LD has implicit timestamps via build.
- OpenGraph + Twitter Card: present. ✅

### C. API spec: N/A — portfolio site, no public API.

### D. Content: ~5/20 partial — services use Problem/Solution/Outcome structure (D8-like), no curl/payload examples (D1-D5 N/A).

### E. Hygiene: 11/15
- No-JS access: ✅ (SSG via Next.js).
- Stable URLs: ✅ (app router, no hashes).
- Version in URL: N/A for portfolio.
- TOS / AI policy: `/legal/terms` exists, explicit AI-policy not yet (-1 pt).

---

## Composite score

A+B+E only (excluding N/A C and partial D): **38/55 → ~69/100 normalized**.

This is "Workable" range. Site is AI-discoverable but has room to improve to "AI-native" tier (75+/100).

---

## Quick wins (≤2 weeks)

1. **`.md` mirrors via Next.js route handlers** → `+6 pts` (B1)
2. **Per-blog-post `TechArticle` JSON-LD** → `+2 pts` (B2)
3. **Glossary page** at `/glossary/ai` → `+2 pts` (D6)
4. **Explicit `/legal/ai-policy` page** → `+1 pt` (E4)

After quick wins: ~80/100 — solid AI-native tier.

---

## Roadmap to 90+

| Phase | Effort | Score gain | Outcome |
|---|---|---|---|
| 1. Quick wins (.md mirrors + JSON-LD + AI policy) | 2 wk | +11 | 69 → 80 |
| 2. Content quality (Problem/Solution rewrite of service cards, glossary, FAQ schema) | 3 wk | +8 | 80 → 88 |
| 3. Entity authority bundle (bio sync, pinned repos, technical articles) | 4 wk | +5 | 88 → 93 |

---

## Entity Authority (companion checklist)

Score: **~21/50** (F-category from [entity-authority-checklist.md](../entity-authority-checklist.md)).

Strengths: 17 platforms in `sameAs`, Person + Organization schema with `alternateName`.

Gaps: bio consistency (3 different handle styles across platforms), no pinned GitHub repos with production-grade READMEs, no recent technical writing on dev.to / Hashnode / Habr.

See main author's [strategy/entity-authority-plan.md](https://github.com/ivannikov-pro) for the action plan.
