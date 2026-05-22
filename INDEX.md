# `ai-readiness-audit/` — navigational map

> Open-source 26-criterion audit framework for measuring how well a website or API is understood by LLM agents (ChatGPT, Claude, Perplexity, Google AI Overview). Lead magnet for the AI-optimisation service. Independent `.git`. MIT.

**Type**: methodology repo — markdown checklists + bash CLI + prompt + examples. No build step.

---

## Files

<!-- prettier-ignore -->
| Path | Purpose |
|---|---|
| `ai-readiness-audit/audit-checklist.md` | 26-criterion checklist with scoring (0-100), grouped into 5 categories (A Discovery / B Per-page / C API spec / D Content / E Hygiene). |
| `ai-readiness-audit/entity-authority-checklist.md` | Companion 13-criterion checklist for entity authority (50 pts). For founder-led brands. |
| `ai-readiness-audit/prompts/audit-prompt.md` | Ready-to-paste Claude / ChatGPT prompt that runs the audit and produces a report. |
| `ai-readiness-audit/prompts/sample-prompts-saas-ai.txt` | Sample prompts for SaaS / AI category. |
| `ai-readiness-audit/scripts/check-ai-readiness.sh` | Bash automation for ~80% of category A + E checks (`/llms.txt`, `/robots.txt` policy, `/sitemap.xml`, JSON-LD, no-JS, canonical, OpenGraph). |
| `ai-readiness-audit/scripts/track-ai-visibility.sh` | Tracker variant (work in progress). |
| `ai-readiness-audit/examples/ivannikov-pro.md` | Reference audit report — self-audit of IVANNIKOV.PRO site. |

---

## Meta files

<!-- prettier-ignore -->
| File | Purpose |
|---|---|
| [`README.md`](README.md) | Human-facing — how to use the framework, scoring, when to use, methodology background, contributing. |
| [`AGENTS.md`](AGENTS.md) | Local rules: methodology integrity, scoring discipline, sync with `ai-visibility-tracker/`. |
| [`LICENSE`](LICENSE) | MIT. |

---

## Cross-references

This repo is the **methodology source**. Two siblings consume it:

- `ai-visibility-tracker/` — hosted product implementation of this checklist.
- `ai-optimisation/` — the service direction that runs audits and ships fixes; uses `audit-checklist-v0.md` (workspace-local draft) that should track this repo's `audit-checklist.md`.

---

## ⚠️ Gotchas

- The roadmap in README (`v0.2`, `v0.3`, `v0.4`, `v0.5`) is **public-facing**. When updating, keep it consistent with `strategy/roadmap.md` (workspace).
- E1 gate ("content without JS") is a **hard pre-condition**, not a scoring criterion. Audit reports MUST mark the whole result UNRELIABLE if E1 fails — do not silently average it in.
- Scoring weighting is opinionated: Category C (API spec) carries 25 pts because the ICP is B2B SaaS with a public API. Do NOT rebalance without updating the README methodology section.
- The checklist is published OSS. PRs from outsiders should be triaged: methodology changes require a strategy-level decision; tooling / typo fixes can land directly.
