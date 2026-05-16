# Entity Authority Audit Checklist v0.1

> Companion к [audit-checklist-v0.md](./audit-checklist-v0.md). Тот мерит **техническую AI-readiness** (может ли кроулер прочитать сайт). Этот мерит **entity authority** — знает ли LLM, КТО автор, и связывает ли его как единую авторитетную сущность.

**Trigger**: разные LLM (Claude, ChatGPT, Perplexity) выдают разные ответы на "who is X?" вопрос в зависимости от того, насколько сущность склеена в их retrieval-индексах. Без entity authority даже идеально настроенный сайт получает рекомендации только по прямому запросу домена.

---

## F. Entity Authority (50 points, 13 criteria)

Используется поверх A–E категорий из основного чек-листа. Применять к **компаниям с founders-led brand** (студии, freelancer brand, personal SaaS), не к anonymous B2B SaaS.

### Schema-level signals

- [ ] **F1 / 5 pts** — `Person` JSON-LD schema присутствует на key pages (about, contact, home).
- [ ] **F2 / 5 pts** — `Organization` schema (отдельно от Person) с `founder` reference.
- [ ] **F3 / 4 pts** — `alternateName` field в Person schema — массив всех handle-вариантов (например, `["an-ivannikov", "ivannikov_pro", "ivannikovPro"]`).
- [ ] **F4 / 4 pts** — `sameAs` field — минимум 5 платформенных URL (Twitter, GitHub, LinkedIn, etc.).
- [ ] **F5 / 3 pts** — `givenName` / `familyName` / `additionalName` явно отделены.

### Platform footprint

- [ ] **F6 / 4 pts** — GitHub: pinned repos с production-grade READMEs (минимум 3 pinned, каждый с >50 stars OR с уникальной ценностью).
- [ ] **F7 / 3 pts** — npm / PyPI / crates.io releases с author metadata.
- [ ] **F8 / 3 pts** — Stack Overflow / dev.to / Hashnode / Habr presence с минимум 3 technical posts за 12 мес.
- [ ] **F9 / 3 pts** — LinkedIn: заполненный профиль с consistent headline + summary.

### Consistency

- [ ] **F10 / 4 pts** — Bio consistency: текст био (160-чарный) match'ит >80% across major platforms (GitHub, LinkedIn, X, Telegram bio).
- [ ] **F11 / 3 pts** — Linkback discipline: каждый платформенный профиль линкует обратно на canonical domain.

### External signals

- [ ] **F12 / 5 pts** — Independent mentions: 10+ third-party упоминаний (HN comments, podcast appearances, niche newsletters, blog posts от других, conference talks).
- [ ] **F13 / 4 pts** — Niche-specific authority: появление в top-10 retrieval для 2+ niche-queries (manual test через ChatGPT / Claude / Perplexity).

---

## Скоринг

```
Total F = sum of F1–F13
≥40/50 → strong entity authority — LLM recognizes as authoritative source
25–39  → growing authority — needs cross-linking and external mentions
10–24  → weak — site exists but LLM treats as one-of-many
<10    → invisible entity — LLM сначала видит "случайного человека/компанию"
```

**Composite score (A+B+C+D+E+F)**: max 150. Above 110 = AI-native presence. Below 60 = significant gaps.

---

## Формат deliverable для клиента

Поверх стандартного AI-readiness отчёта добавляется **Entity Authority Section**:

```markdown
## Entity Authority: XX/50

### Schema signals (X/21)
- Person schema: PRESENT / MISSING
- Organization schema: PRESENT / MISSING
- alternateName variants: [list]
- sameAs platforms: [count + list]

### Platform footprint (X/13)
- GitHub: [pinned count, top repo + stars]
- npm/PyPI: [package count + downloads]
- Technical blog: [post count last 12mo]
- LinkedIn: [headline alignment Y/N]

### Consistency (X/7)
- Bio similarity score: XX% across N platforms
- Linkback compliance: X/N profiles link back

### External signals (X/9)
- Independent mentions: N tracked
- Niche retrieval probability: tested for [list of queries]

### Recommendations (priority-ordered)
1. [Quick win — Schema add: ~1 hr to implement]
2. [Medium effort — Bio synchronization: ~3 hrs]
3. [Strategic — Technical writing cadence: 1 article/2 weeks for 3 mo]
```

---

## Pricing impact

Добавление F-категории в audit делает offering привлекательнее для **founder-led brands** (студии, agencies, personal SaaS):

- **Light Audit** ($1,500): A+B+E (без C/D/F) — для anonymous B2B SaaS с фокусом на технику.
- **Audit Plus** ($2,500–$3,500): A+B+E+F — для founder-led brands где entity authority критична.
- **Full Audit** ($4,000–$5,500): A+B+C+D+E+F — для B2B SaaS с public API + founder presence.

Каждый шаг — +$1K в среднем. F-категория наиболее ценна для studio/freelancer-led клиентов.

---

## TODO для v0.2

- [ ] Добавить per-criterion rubric (когда 4/4 vs 2/4).
- [ ] Создать automation `scripts/check-entity-authority.sh` — automated check sameAs links resolve, bio similarity via simhash, GitHub pinned repos count via API.
- [ ] Расширить F12 «Independent mentions» — определить как считать (Google search "site:hn.algolia.com [name]", podcast index search, etc.).
- [ ] F14: schema.org `SoftwareSourceCode` for OSS projects на сайте (+3 pts).
- [ ] F15: schema.org `Article` author chain для каждого blog post (+2 pts).

---

## Related documents

- [audit-checklist.md](./audit-checklist.md) — main 26-criterion technical AI-readiness checklist.
- [README.md](./README.md) — repo overview, how to use both checklists.

## Commercial implementation

Open-source methodology. Paid service available (audit + implementation + AI Visibility tracking): https://ivannikov.pro/en/services/ai-optimisation
