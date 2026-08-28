# Plan — Adapt the academic workflow configuration for censobr

**Status:** COMPLETED (2026-08-27) — see `quality_reports/session_logs/2026-08-27_adapt-workflow-config.md`
**Date:** 2026-08-27
**Scope:** Configuration only. No package source (`R/`, `tests/`, `DESCRIPTION`, `NAMESPACE`, `NEWS.md`) is modified.

---

## Context

**Why this is needed.** The user installed the Claude Code academic workflow (forked from
`pedrohcgs/claude-code-my-workflow`, now at `rafapereirabr/claude-code-my-workflow`) and asked
me to adapt it to censobr. Mid-session, the user vendored the upstream template's own `.claude/`,
`CLAUDE.md`, `MEMORY.md`, and `quality_reports/` into this repo.

**The problem.** What landed is the template **verbatim** — built for a Beamer/Quarto
lecture-slides project, not an R package. `CLAUDE.md` documents LaTeX compile commands, Beamer
environments, Quarto CSS classes, and a lecture-by-lecture status table; `MEMORY.md` is 171 lines
of the *template's own* development history. None of it describes censobr. Four verified
consequences:

| # | Finding | Consequence |
|---|---|---|
| 1 | The 20 vendored `.claude/rules/` are **byte-identical** to `~/.claude/rules/` (all but `meta-governance.md`) | The copy adds no content, only duplication |
| 2 | `.claude/settings.json` sets `defaultMode: "bypassPermissions"`; global is `"auto"`. Project settings win | `MEMORY.md:152` records that **auto** is the only mode that avoids prompts on protected `.claude/` paths — this reintroduces them |
| 3 | All 7 hooks registered twice (global absolute paths + local `$CLAUDE_PROJECT_DIR`) | Hook layers are additive → `git-guardrails`, `log-reminder`, etc. likely fire twice per trigger |
| 4 | 4 new top-level entries; `.Rbuildignore` covers none | `R CMD check --as-cran` raises a "non-standard files" NOTE, breaking the `cran-comments.md` baseline of **0 errors, 0 warnings, 0 notes** |

**Intended outcome.** A repo whose config describes *censobr* — so a future session can open
`CLAUDE.md` and know the release gate, the data-release contract, and the year×dataset matrix
without re-deriving any of it — while keeping the CRAN check clean.

**User decisions (2026-08-27):**
1. **Prune** `.claude/` to an R-package kit (exact list below — no expansion beyond what was approved).
2. **Keep** `.claude/settings.json`, stripped of the conflicting `hooks` block and `defaultMode`.
3. **Delete** the inherited `MEMORY.md` content and `quality_reports/did_validation.md` outright.
   Both verified recoverable from `R:\Dropbox\git\claude-code-my-workflow` (git repo with GitHub remote).

---

## Censobr facts that drive the customization

| Finding | Why it goes in CLAUDE.md |
|---|---|
| `censobr_env$data_release <- 'v0.6.0'` (`R/onLoad.R:7`) is a **single pin** that all six `read_*()` interpolate into download URLs *and* that versions the cache dir (`R/utils.R:24`) | Highest-consequence, least-obvious invariant in the package |
| Data + pipeline migrated to `ipea/censobr_prep_data` in v0.6.0; local `data_prep/` is legacy, `.Rbuildignore`d | Without this, a future session edits the dead local folder |
| Year availability hard-coded in **9 files** (`years <- c(...)`), genuinely different per dataset | Document the matrix once + flag the drift risk |
| `read_*()` returns an **arrow `Dataset`** by default (`as_data_frame = FALSE`); `merge_households` routes through DuckDB | The larger-than-memory promise is a contract that must not silently regress |
| Every test/example is network-bound (`@examplesIf NOT_CRAN`, GitHub Releases) | Offline failures are not code bugs |
| `.claude/skills/commit/SKILL.md` Steps 0/0b call `scripts/quality_score.py` + `scripts/check-surface-sync.sh` — **neither exists here** (no `scripts/` dir) | Must be documented as skipped, as the sibling repos do |

**Two defects — logged in MEMORY.md, not fixed:**
- `DESCRIPTION` `URL`/`BugReports` say `github.com/ipea/censobr`; `git remote` is `ipeaGIT/censobr`.
  Consistent with the `enderecobr` note that the org migrated `ipeaGIT → ipea` with redirects — plausibly deliberate, but undocumented.
- `DESCRIPTION` lacks `Config/testthat/edition: 3`, which `r-package-conventions.md` requires.

---

## Phase 1 — Prune `.claude/` to an R-package kit

Delete exactly the 13 modules approved, nothing more:

- **Rules (2):** `no-pause-beamer.md`, `content-invariants.md` → 18 remain
- **Skills (6):** `qa-quarto`, `translate-to-quarto`, `deploy`, `pedagogy-review`, `scaffold-exercises`, `validate-bib` → 23 remain
- **Agents (5):** `quarto-critic`, `quarto-fixer`, `pedagogy-reviewer`, `domain-referee`, `editor` → 8 remain

**Dangling references (accepted, not chased).** Pruning leaves references in ~7 surviving files.
I will fix only the **load-bearing rules** whose tables steer behavior — `model-routing.md`,
`orchestrator-protocol.md`, `post-flight-verification.md`. The four `.claude/references/`
catalogs (`agent-fleet`, `audit-pet-peeves`, `orchestration-schemas`, `v2.0-backlog`) are
*intentionally* left intact: they document the complete fleet, which still exists globally at
`~/.claude/`. Editing them is scope creep and would make them wrong about the global install.

**Borderline modules kept, flagged dormant in CLAUDE.md** (not in the approved prune list, so
not touched): `seven-pass-review`, `submission-disclosures`, `devils-advocate`, `new-diagram`,
`data-management-plan`, `replication-package`, `domain-reviewer`.

## Phase 2 — Reconcile `.claude/settings.json`

Strip the two conflicting keys; keep the file:

- **Remove** the entire `hooks` block → global keeps sole ownership; ends the double-firing.
- **Remove** `permissions.defaultMode: "bypassPermissions"` → session falls back to global `"auto"`.
- **Keep** `permissions.allow`, `plansDirectory`, `statusLine`.

Then add `.claude/settings.local.json` (gitignored per Claude Code convention) for repo-local
permissions, matching the sibling-repo pattern.

## Phase 3 — Rewrite `CLAUDE.md` (the main deliverable)

Full replacement, in **English** (censobr's `DESCRIPTION` has no `Language:` field; NEWS, roxygen
and vignettes are English — unlike `geocodebr`, which is pt-BR). Structure follows the proven
`flightsbr` / `geocodebr` shape, kept under ~150 lines:

1. **Header** — project, maintainer + co-authors, Ipea as `cph`/`fnd`, repo, branch, v0.6.0
2. **Core principles** — plan-first; `R/` authoritative (`man/`+`NAMESPACE` generated); `R CMD check --as-cran` is the gate; `[LEARN]` tagging; **+ the data-release pin**
3. **The data-release contract** ← *the censobr-specific section*
   - `R/onLoad.R:7` is the single source of truth
   - URL shape: `.../ipea/censobr_prep_data/releases/download/{tag}/{year}_{dataset}_{tag}.parquet`
   - Cache is versioned by tag → **bumping it silently invalidates every user's cache**; a deliberate, NEWS-worthy decision, never a drive-by edit
   - Pipeline lives in `ipea/censobr_prep_data`; local `data_prep/` is legacy
4. **Year × dataset availability matrix** — authoritative table + warning that 9 `R/` copies move together
5. **Arrow / DuckDB contract** — `as_data_frame = FALSE` default is the core promise
6. **Folder structure** and **Commands** (`devtools::document/test/check`, `covr`, `pkgdown`, the CRAN release ritual)
7. **Quality gate table** — check / test / coverage / roxygen / CI matrix
8. **`/commit` caveat** — Steps 0/0b skipped, no `scripts/` dir; the real gate is `/r-package-check`
9. **Skills quick reference** — what is actually live after Phase 1, with dormant modules named
10. **Package functions table** — the 12 exported functions by family
11. **Testing notes** — network dependence, `NOT_CRAN` idiom, `# nocov` blocks
12. **Known follow-ups** — the two logged defects
13. **Onboarding check-in mode** — phase-boundary checkpoints, marked temporary

## Phase 4 — MEMORY.md, templates, deletions, `.Rbuildignore`

- **`MEMORY.md`** — replace wholesale with a censobr header + `[LEARN]` convention, seeded with: the two `DESCRIPTION` defects; the data-release/cache-invalidation rule; the 9-file year-matrix drift risk; the `/commit` Step 0/0b gap.
- **Delete** `quality_reports/did_validation.md`.
- **Create `templates/`** — `session-log.md`, `requirements-spec.md`, `quality-report.md` (from `flightsbr`, retargeted to `/r-package-check`). Referenced by both `CLAUDE.md` and the `session-logging` rule, but currently absent.
- **Append to `.Rbuildignore`** — required, not cosmetic; without it the CRAN NOTE fires:
  ```
  ^\.claude$
  ^quality_reports$
  ^templates$
  CLAUDE\.md
  MEMORY\.md
  ```
  > `flightsbr/.Rbuildignore` covers only three of these five (omits `^templates$` and `MEMORY.md`) — censobr gets the complete set; I'll note the sibling gap in `MEMORY.md`.

---

## Verification

1. **CRAN cleanliness — the one that matters.** Fast pre-check first:
   ```bash
   R CMD build . && tar -tzf censobr_0.6.0.tar.gz | grep -E 'CLAUDE|MEMORY|quality_reports|templates|\.claude'
   ```
   → must return **nothing**. Then the full gate in background (~12 min per `cran-comments.md`):
   `R CMD check --as-cran censobr_0.6.0.tar.gz` → expect **0 / 0 / 0**.
2. **No source drift:** `git status` shows only config changes plus the single `.Rbuildignore` append; `R/`, `tests/`, `DESCRIPTION`, `NAMESPACE` untouched.
3. **No dangling refs in load-bearing rules:** grep the 18 surviving rules for the 13 pruned module names → only the 4 intentionally-untouched `references/` catalogs may match.
4. **Factual accuracy of CLAUDE.md:** re-read `R/onLoad.R`, the 9 `years <- c(...)` sites, and `NAMESPACE` to confirm the pin, the matrix, and the 12-function table match source.
5. **Hooks fire once:** trigger one `Write` and confirm a single `claim-reconcile` invocation.

**Not run:** `devtools::test()` — every test is network-bound and no package code changes.

---

## Out of scope

- Any edit to `R/`, `tests/`, `DESCRIPTION`, `NAMESPACE`, `NEWS.md`
- Any edit to `~/.claude/` (global install)
- Fixing the two logged defects
- Committing — config is left uncommitted for review; `/commit` is a separate, explicit invocation

---

## Checkpoints

Reporting at each phase boundary (per the onboarding setting), with Phase 3's `CLAUDE.md`
presented in full for review as the main deliverable.
