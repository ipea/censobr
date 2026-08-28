# Project Memory — censobr

Corrections and learned facts that persist across sessions for **censobr**.
When a mistake is corrected, or a non-obvious approach is confirmed, append a `[LEARN:category]`
entry below. Most recent at the bottom.

> The workflow template's own development history (inherited when `.claude/` was vendored into this
> repo) was removed on 2026-08-27 — it documented the Beamer/Quarto template, not censobr. It
> remains available in `R:\Dropbox\git\claude-code-my-workflow` (`MEMORY.md`), which has a GitHub
> remote, so nothing was lost.

---

## Package architecture

[LEARN:data-release] `R/onLoad.R:7` (`censobr_env$data_release`) is a **single pin** that does two
jobs: it builds the download URL for all six `read_*()` functions, and it versions the cache
directory (`R/utils.R:22` → `{cache_dir}/data_release_{tag}`). **Bumping it silently invalidates
every user's cache and forces a full re-download.** Treat it as a deliberate release decision with
a `NEWS.md` entry — never a drive-by edit. Package version and data release are independent
decisions that merely happen to both read `v0.6.0` today.

[LEARN:data-release] The three documentation functions (`data_dictionary()`, `questionnaire()`,
`interview_manual()`) use a **fixed** release tag `censo_docs`, *not* the data-release pin. This
looks like an inconsistency but is correct — documentation is not re-released per data version.
Do not "unify" it with the pin.

[LEARN:cache] `censobr_cache()` deliberately lists files recursively from the cache **root**, not
from the versioned subdirectory — the versioning line at `R/cache.R:162` is commented out on
purpose. This lets users see and delete files left behind by *older* data releases. Uncommenting
it would hide exactly the files users most need to clean up.

[LEARN:arrow] `read_*()` returning an arrow `Dataset` (`as_data_frame = FALSE`) is the package's
core promise, not a default worth tuning. Never change it, and never introduce a step that
silently `collect()`s into memory — that would break the larger-than-memory guarantee the package
is built on.

[LEARN:drift] Year availability is hard-coded as `years <- c(...)` in **9 separate files** with
genuinely different sets per dataset. There is no shared constant. Any change to supported years
must touch every relevant copy — the reference table is in [CLAUDE.md](CLAUDE.md).

---

## Known defects (logged 2026-08-27, not yet fixed)

[LEARN:defect] **FIXED 2026-08-28.** `R/read_tracts.R:91-92` — the `year == 2000` branch validates against
`data_sets_2000` but its error message reports `data_sets_2010`. A user passing an invalid
`dataset` for 2000 is told about `DomicilioRenda`/`PessoaRenda`/`Entorno` (not available in 2000)
and is *not* told about `Instrucao`/`Morador` (which are). One-word fix:
`error_missing_datasets(data_sets_2000)`.

[LEARN:org] **RESOLVED 2026-08-27 — `ipea` is canonical; `ipeaGIT` redirects.** `DESCRIPTION` was
already correct; the stale one was the git remote, now `https://github.com/ipea/censobr`. All 8
`ipeaGIT/` mentions across the repo were replaced.

[LEARN:org] **`r5r` has NOT migrated.** `ipea/geobr` and `ipea/censobr` resolve, but `ipea/r5r`
does **not** — only `ipeaGIT/r5r`. A blanket `ipeaGIT/ → ipea/` replace therefore breaks the r5r
install URL (`tests/tests_rafa/test_rafa.R:66`). Verify each org path with
`git ls-remote https://github.com/<org>/<repo>` before a bulk rename; the migration is per-repo,
not org-wide.

[LEARN:defect] `DESCRIPTION` has no `Config/testthat/edition: 3`, which
`.claude/rules/r-package-conventions.md` requires. The suite appears to be written in 3e style;
adding the field makes it explicit rather than incidental.

[LEARN:defect] **FIXED 2026-08-28** (now `assert_choice`). `read_population(year, add_labels = "pt")` validated `add_labels` for **any** year
(`R/read_population.R:42`) but `add_labels_population()` aborts unless `year == 2010`
(`R/add_labels_population.R:9-11`). The abort happens *after* the parquet download, so a user asking
for 2000 labels waits for a large file and then gets an error. Either validate the year/label
combination up front, or widen label coverage. Same shape is worth checking in the other
`add_labels_*` helpers.

[LEARN:pipeline] In every `read_*()`, **column selection runs before labelling**, and the labeller
guards each recode with `if ('VXXXX' %in% cols)` against the column list captured on entry. So a
narrow `columns =` argument silently skips labelling for the dropped variables — no warning. Order
matters if you ever refactor these steps.

---

## Workflow configuration

[LEARN:workflow] `/commit` Steps 0 and 0b call `scripts/quality_score.py` and
`scripts/check-surface-sync.sh`, which **do not exist here** — there is no `scripts/` directory.
They came from the Beamer/Quarto template this workflow was forked from. Skip Steps 0/0b; the real
release gate is `/r-package-check`. Steps 1–7 apply normally. Same caveat holds in flightsbr,
enderecobr, and geocodebr.

[LEARN:workflow] Any new top-level file or directory in this repo (`CLAUDE.md`, `MEMORY.md`,
`.claude/`, `quality_reports/`, `templates/`) **must** get an `.Rbuildignore` entry, or
`R CMD check --as-cran` raises a "Non-standard files/directories found at top level" NOTE and
breaks the 0/0/0 baseline recorded in `cran-comments.md`.

[LEARN:workflow] `flightsbr/.Rbuildignore` covers only three of the five workflow patterns — it
omits `^templates$` and `MEMORY.md`. If flightsbr ever gains those files, it will pick up a CRAN
NOTE. Censobr carries the complete set; consider back-porting to the siblings.

[LEARN:config] When vendoring the workflow template into a package repo, its `.claude/settings.json`
brings a `hooks` block and `defaultMode: "bypassPermissions"` that **conflict with the global
`~/.claude/settings.json`**: hook layers are additive (each hook fires twice) and the project-level
`defaultMode` overrides the global `auto`. Strip both from the project copy and let the global
settings own hooks, permission mode, and statusline.

[LEARN:config] The vendored `.claude/rules/` were byte-identical to `~/.claude/rules/` except
`meta-governance.md` — copying them into a project adds duplication, not content. What the project
copy *is* good for is pruning to the applicable subset (censobr: 7 rules / 12 skills / 4 agents)
so `CLAUDE.md` can honestly document what is live.

[LEARN:check] Running `R CMD check --as-cran` **without network access** halts twice unless two env
vars are set: `_R_CHECK_CRAN_INCOMING_=FALSE` (the incoming-feasibility step times out fetching
`CRAN.../PACKAGES`) and `_R_CHECK_FORCE_SUGGESTS_=FALSE` (`geobr`, `ggplot2`, `kableExtra` are
Suggests that can't be resolved offline). Neither indicates a package problem. Also note that
piping the check through `tail` masks its exit code — you get `tail`'s 0 even when the check died.

[LEARN:check] `--no-build-vignettes` on `R CMD build` produces two *spurious* WARNINGs on the
subsequent check ("Files in the 'vignettes' directory but no files in 'inst/doc'" and "Directory
'inst/doc' does not exist"). They are artifacts of the reduced build, not defects. A full
vignette build downloads real census parquet files, so prefer the reduced build for structural
checks and reserve the full run for pre-release.

[LEARN:config] **A path-scoped rule whose `paths:` globs match zero files in the repo is dead
weight** — it can never fire. Testing each rule's globs against the tree is a far better prune
criterion than judging by filename: it correctly flagged `quality-gates`, `single-source-of-truth`,
`r-code-conventions`, `replication-protocol`, `simulation-conventions`, `knowledge-base-template`,
`exploration-folder-protocol`, and `orchestrator-research` as unreachable here. Watch for false
positives, though: `verification-protocol` scored LIVE only via `docs/**` (gitignored pkgdown
output) while its body was entirely about rendering slides. After the prune all 7 surviving rules
are LIVE or unscoped-global.

[LEARN:config] Pruning `.claude/` cascades — deleting a module breaks every cross-reference to it,
including *pre-existing* broken links the vendored copy already carried (`audit-reproducibility`,
`coauthor-brief`, `data-analysis`, `skill-template` were referenced but never copied in). Always
finish a prune with a link-resolution sweep over `.claude/**/*.md`, not just a name grep — the
grep found 23 mentions, the link check found 11 more that the grep's pattern list missed.

