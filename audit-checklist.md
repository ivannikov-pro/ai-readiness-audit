# AI Readiness Audit — Checklist v0.1

> Working draft адаптации 26-критерийной методологии Gumeniuk + дополнения под B2B SaaS ICP. Используется (1) как self-audit для собственного сайта, (2) как deliverable Light-аудита для клиентов, (3) как лид-магнит на странице услуги.

**Что мерим**: насколько публичный продукт клиента (сайт + docs + API + контент) понятен и цитируем для AI-агентов и LLM-ответчиков (ChatGPT, Claude, Perplexity, Gemini, Google AI Overview).

**Итог аудита**: оценка 0–100 + конкретные fix-recommendations + roadmap до 75+.

---

## Условие достоверности (E1 gate)

**Если страница не отдаёт контент без выполнения JavaScript → оценка UNRELIABLE.** Проверка: `curl -s https://domain.com/page | grep -c "<main>"`. Если SPA рендерится клиентом и контент не SSR/SSG — все остальные баллы не показательны.

LLM-кроулеры (GPTBot, ClaudeBot, PerplexityBot) JS не исполняют. Это первый барьер.

---

## A. Discovery (18 points, 4 items)

Может ли агент найти ваш контент с нуля?

- [ ] **A1 / 6 pts** — `/llms.txt` в корне сайта. Должен содержать (per [llmstxt.org](https://llmstxt.org)):
  - H1 с названием сайта
  - Blockquote с одним предложением что это
  - H2 секции (Services / Docs / Blog) с ссылками
  - Опционально "Optional" секция с deeper content
- [ ] **A2 / 5 pts** — `/llms-full.txt` (расширенный): полный текст ключевых страниц конкатенированный. Размер до 10 MB.
- [ ] **A3 / 4 pts** — `/robots.txt` с явной AI-политикой:
  - `User-agent: GPTBot` / `ClaudeBot` / `PerplexityBot` / `Google-Extended` / etc. — Allow/Disallow
  - Опционально `Content-Signal: ai-train=yes/no, search=yes` (Cloudflare стандарт)
- [ ] **A4 / 3 pts** — `/sitemap.xml` присутствует, валиден, `<lastmod>` обновляется.

---

## B. Per-page artifacts (22 points, 5 items)

Может ли агент быстро прочитать конкретную страницу без шумов?

- [ ] **B1 / 6 pts** — `.md`-версия страницы: `https://domain.com/page.md` отдаёт чистый markdown того же контента. **Самый эффективный single fix** — снимает SPA-проблему.
- [ ] **B2 / 5 pts** — JSON-LD `TechArticle` (или `Article` / `APIReference`) в `<head>`:
  ```json
  {"@context":"https://schema.org","@type":"TechArticle","headline":"…","dateModified":"…","author":{"@type":"Person","name":"…"}}
  ```
- [ ] **B3 / 4 pts** — `<link rel="canonical">` присутствует и точен.
- [ ] **B4 / 4 pts** — `Last-Modified` HTTP-заголовок или `dateModified` в JSON-LD (для свежести цитат).
- [ ] **B5 / 3 pts** — OpenGraph + Twitter Card теги (title, description, image) — для preview в чат-агентах.

---

## C. API spec (25 points, 6 items)

Доступна ли спецификация так, что её можно сразу скормить в Claude/ChatGPT?

- [ ] **C1 / 7 pts** — OpenAPI / Swagger на **предсказуемом URL**: `/openapi.json`, `/openapi.yaml`, или `/api/openapi.json`. Не за auth.
- [ ] **C2 / 5 pts** — Schema валидна по [openapi-validator](https://apitools.dev/swagger-parser/online/) — нет broken `$ref`, нет невалидных типов.
- [ ] **C3 / 4 pts** — В spec есть `examples` для каждого endpoint (request + response).
- [ ] **C4 / 3 pts** — Postman collection / Insomnia / Bruno ссылка опубликована рядом с docs.
- [ ] **C5 / 3 pts** — SDK ссылки (npm/pip/github) рядом с docs.
- [ ] **C6 / 3 pts** — Версионирование в spec (`info.version`) и URL (`/v1/` / `/v2/`).

---

## D. Content (20 points, 7 items)

Достаточно ли контекста, чтобы LLM сгенерировала рабочий пример без галлюцинаций?

- [ ] **D1 / 4 pts** — `curl` пример рядом с описанием каждого endpoint.
- [ ] **D2 / 3 pts** — Реалистичный payload в примере (не `{ "foo": "bar" }`, а реальные fields).
- [ ] **D3 / 3 pts** — Все error codes документированы (4xx, 5xx — что значит, что делать).
- [ ] **D4 / 3 pts** — Auth-метод явно описан с примером headers.
- [ ] **D5 / 3 pts** — Rate limits документированы (cap, window, что в headers).
- [ ] **D6 / 2 pts** — Глоссарий / definitions для domain-specific терминов.
- [ ] **D7 / 2 pts** — SDK code example (JS/Python/Go) рядом с REST примером.

---

## E. Hygiene (15 points, 4 items)

Может ли агент ВСЕГДА получить тот же контент по той же ссылке?

- [ ] **E1 / 6 pts** — Контент доступен без JS (SSR / SSG / pre-rendered HTML). См. gate выше.
- [ ] **E2 / 4 pts** — Стабильные URLs (нет hash-routing типа `/#docs/api`, нет UUID в URL).
- [ ] **E3 / 3 pts** — Версия в URL (для возможности цитировать конкретную версию доков).
- [ ] **E4 / 2 pts** — TOS / Acceptable Use / AI-policy опубликована (что разрешено LLM-кроулерам).

---

## Скоринг

```
Total = A + B + C + D + E
≥75/100 → AI-ready (strong citation prospect)
50–74   → Workable, conversion gaps
30–49   → Significant gaps, AI agents miss content
<30     → Not citable, urgent fix needed
```

**E1 fail (контент за JS)** → отметить *UNRELIABLE* в отчёте независимо от total. Это первый fix перед любой другой работой.

---

## Формат отчёта клиенту

После прогона по чек-листу:

```markdown
# AI Readiness Audit: [client.com]

**Score**: 47/100 (Workable, conversion gaps)
**Date**: 2026-MM-DD
**E1 gate**: PASS / *FAIL — UNRELIABLE*

## Quick wins (≤2 weeks of work)
1. [Specific fix #1 — recommended score boost]
2. [Specific fix #2]
3. [Specific fix #3]

## Roadmap to 75+
| Phase | Effort | Score gain | Outcome |
|---|---|---|---|
| 1. Quick wins | 2 wk | +15 | 47 → 62 |
| 2. Per-page artifacts | 3 wk | +13 | 62 → 75 |
| 3. API spec polish | 2 wk | +8 | 75 → 83 |

## Per-category breakdown
- A. Discovery: X/18 — [details]
- B. Per-page: X/22 — [details]
- C. API spec: X/25 — [details]
- D. Content: X/20 — [details]
- E. Hygiene: X/15 — [details]
```

---

## Что отличает v0.1 от Gumeniuk-методологии

- **Adapted под B2B SaaS ICP**: акцент на public API (C-категория weight 25 — самый высокий).
- **E1 gate выделен** как pre-condition, не баллы — соответствует реальной механике LLM-кроулеров.
- **Deliverable orientation**: отчёт сразу с roadmap'ом, не просто scoring.
- **Open для расширения**: GEO-метрики (AI Visibility Score, Prominence) — отдельный документ Q2.

---

## TODO для v0.2

- [ ] Verify llms.txt спецификацию через Context7 / llmstxt.org — actualize формат.
- [ ] Добавить scoring rubric per criterion (когда 6/6 vs 3/6 vs 0/6).
- [ ] Конвертировать в claude-skill format (`.skill.json` или markdown skill) для публикации в OSS репо.
- [ ] Связать с GEO-аудитом (отдельный документ): AI Visibility Score, Prominence, citation tracking.
- [ ] Прогон на 5–10 popular B2B SaaS (Stripe, Twilio, OpenAI, Anthropic, Linear, Notion, Vercel) для baseline-данных в маркетинге.
