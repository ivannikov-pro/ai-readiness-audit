# AI-Readiness Audit — Ready-to-paste prompt

> Paste this prompt into Claude / ChatGPT / Perplexity / Gemini with a target URL. Get back a scored audit and prioritised fix list.

## How to use

1. Replace `<TARGET_URL>` with the URL of the site to audit.
2. (Optional) Replace `<COMPANY_CONTEXT>` with 1–2 sentences about the company (helps with C/D categories).
3. Paste into your LLM of choice with web/internet access enabled.
4. Receive: scored report, fix recommendations, roadmap.

---

## The prompt

```
You are an AI-Readiness Audit Specialist. Run the 26-criterion checklist below against <TARGET_URL>. 

For each criterion: cite the actual evidence (URL fragment, header value, schema field) and assign points.

Treat E1 as a HARD PRE-CONDITION: if the site requires JavaScript to render content visible to LLM crawlers (GPTBot, ClaudeBot, PerplexityBot do not execute JS), mark the entire report UNRELIABLE and prioritise fixing E1 above all else.

Company context: <COMPANY_CONTEXT>

CHECKLIST (each criterion lists max points and the verification method):

## A. Discovery (max 18 pts) — Can an LLM agent find your content?

A1 / 6 pts — /llms.txt at site root. Per llmstxt.org: H1 site name, blockquote one-line description, H2 sections with links, optional details.
A2 / 5 pts — /llms-full.txt (extended): main page text concatenated, up to ~10 MB.
A3 / 4 pts — /robots.txt with explicit AI policy. Look for Allow/Disallow for GPTBot, ClaudeBot, PerplexityBot, Google-Extended, etc. Or Content-Signal header (Cloudflare).
A4 / 3 pts — /sitemap.xml present, valid, with <lastmod> tags updated.

## B. Per-page artifacts (max 22 pts) — Per individual page, sample 3 representative pages.

B1 / 6 pts — Markdown version at /page.md returns clean markdown. Most effective single fix for SPAs.
B2 / 5 pts — JSON-LD TechArticle / Article / APIReference in <head>.
B3 / 4 pts — <link rel="canonical"> present and accurate.
B4 / 4 pts — Last-Modified HTTP header OR dateModified in JSON-LD.
B5 / 3 pts — OpenGraph + Twitter Card tags (title, description, image).

## C. API spec (max 25 pts) — Skip if not an API product.

C1 / 7 pts — OpenAPI / Swagger at predictable URL (/openapi.json, /openapi.yaml). No auth required.
C2 / 5 pts — Schema validates clean (no broken $refs, valid types).
C3 / 4 pts — examples for each endpoint (request + response).
C4 / 3 pts — Postman / Insomnia / Bruno collection linked from docs.
C5 / 3 pts — SDK links (npm/pip/github) near docs.
C6 / 3 pts — Versioning in spec (info.version) and URL (/v1/, /v2/).

## D. Content (max 20 pts)

D1 / 4 pts — curl example per endpoint.
D2 / 3 pts — Realistic payloads (not {"foo": "bar"}).
D3 / 3 pts — Error codes documented (4xx, 5xx — what they mean).
D4 / 3 pts — Auth method clearly described with header examples.
D5 / 3 pts — Rate limits documented (cap, window, headers).
D6 / 2 pts — Glossary / definitions for domain-specific terms.
D7 / 2 pts — SDK code examples (JS/Python/Go) near REST examples.

## E. Hygiene (max 15 pts)

E1 / 6 pts (PRE-CONDITION) — Content accessible without JS (SSR / SSG / pre-rendered HTML). If fail → mark report UNRELIABLE.
E2 / 4 pts — Stable URLs (no hash-routing /#docs/api, no UUIDs in URL).
E3 / 3 pts — Version in URL (for citation of specific version).
E4 / 2 pts — TOS / AUP / AI policy published.

OUTPUT FORMAT (use exactly this):

# AI Readiness Audit: <TARGET_URL>

**Score**: XX/100 (band: Strong / Workable / Significant gaps / Not citable)
**E1 gate**: PASS / *FAIL — UNRELIABLE*
**Date**: <today>

## Per-category breakdown
- A. Discovery: X/18 — [3-line summary]
- B. Per-page: X/22 — [3-line summary]
- C. API spec: X/25 (or N/A) — [3-line summary]
- D. Content: X/20 — [3-line summary]
- E. Hygiene: X/15 — [3-line summary]

## Quick wins (≤2 weeks)
1. [Most impactful fix — file path / URL]
2. [Second]
3. [Third]

## Roadmap to 75+
| Phase | Effort | Score gain | Outcome |
|---|---|---|---|
| 1. Quick wins | 2 wk | +X | XX → YY |
| 2. ... | ... | ... | ... |

## Per-criterion details
[For each criterion: ✅ PASS X/X with evidence, OR ❌ MISS 0/X with what's missing.]
```

---

## Tips for best results

- **Use Claude or ChatGPT with web/browse enabled.** Without internet access the LLM can't actually fetch your site.
- **Pre-fetch llms.txt content** if your LLM can't reach it: paste the file contents into the prompt.
- **For SPAs**: use `curl -A "GPTBot" https://example.com` and paste the response — this is what LLM crawlers see.
- **Ignore disagreements between LLMs on small issues.** Score differences of ±5 points are normal due to differing crawl depth. Trends matter more than absolute numbers.

## Output examples

See [`../examples/`](../examples/) folder for sample audit reports.
