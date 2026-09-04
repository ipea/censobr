# CLAUDE.md — censobr

**Project:** censobr — R package to download microdata and aggregate data from Brazil's Population
Censuses (1960 onward), built on Arrow so users can work with larger-than-memory census data using
familiar {dplyr} verbs.
**Maintainer:** Rafael H. M. Pereira (aut, cre) · **Authors:** Rogério J. Barbosa (aut);
Diego Rabatone Oliveira, Neal Richardson (ctb) · **Copyright/funding:** Ipea
**Repo:** https://github.com/ipea/censobr · **Site:** https://ipea.github.io/censobr/
**Branch:** main · **Version:** 0.6.0.999 (dev) · **Language:** English (NEWS, roxygen, vignettes, messages)

---

## Core Principles

- **Plan first** — enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **`R/` is authoritative** — `man/` and `NAMESPACE` are *generated* by roxygen2. Never hand-edit
  them; edit the roxygen blocks in `R/` and run `devtools::document()`
- **The release gate is `R CMD check --as-cran`** — 0 errors, 0 warnings, every remaining NOTE
  justified in `cran-comments.md`. Run `/r-package-check` before any release or merge touching
  `R/`, `tests/`, or `DESCRIPTION`. The v0.6.0 baseline is **0 / 0 / 0** — keep it there
- **Never bump the data-release pin casually** — see the contract below; it invalidates every
  user's cache
- **`[LEARN]` tags** — when corrected, or when a non-obvious approach is confirmed, save
  `[LEARN:category] wrong → right` to [MEMORY.md](MEMORY.md)

Cross-session context lives in [MEMORY.md](MEMORY.md); plans, specs, and session logs in
[quality_reports/](quality_reports/).

---

## The data-release contract (censobr-specific — read before touching `read_*()`)

`R/onLoad.R:7` holds a single pin:

```r
censobr_env$data_release <- 'v0.6.0'
```

It is the **single source of truth** for where data comes from, and it does two things:

1. **Builds every download URL** in the six `read_*()` functions:
   `https://github.com/ipea/censobr_prep_data/releases/download/{tag}/{year}_{name}_{tag}.parquet`
   (`read_tracts()` inserts a lowercased `dataset`: `{year}_tracts_{dataset}_{tag}.parquet`)
2. **Versions the cache directory** — `R/utils.R:22` writes into `{cache_dir}/data_release_{tag}`

**Therefore bumping the pin silently invalidates every user's cache and re-downloads everything.**
It is a deliberate, NEWS-worthy release decision — never a drive-by edit. The package version
(`DESCRIPTION`) and the data release are *separate* decisions that happen to both read `v0.6.0` today.

**Two deliberate asymmetries — do not "fix" them:**

- The **documentation** functions (`data_dictionary()`, `questionnaire()`, `interview_manual()`)
  use a *fixed* tag `censo_docs`, **not** the pin — docs are not re-released per data version.
- `censobr_cache()` lists recursively from the cache **root**, not the versioned subdir
  (`R/cache.R:162` is commented out on purpose), so users can see and delete files from older releases.

**Data lives elsewhere.** As of v0.6.0 all data and the pipeline that builds it moved to
`ipea/censobr_prep_data`. The local `data_prep/` folder is **legacy** and `.Rbuildignore`d —
do not edit it expecting an effect.

---

## Year × dataset availability

Registered once in `R/availability.R` as `.censobr_availability`, read through `censobr_years(key)`.
A new census release is added there, not in the nine call sites.

| Function / dataset | Years |
|---|---|
| `read_population()`, `read_households()` | 1960, 1970, 1980, 1991, 2000, 2010, 2022 |
| `read_tracts()` | 2000, 2010, 2022 |
| `read_families()` | 2000, 2022 |
| `read_mortality()` | 2010, 2022 |
| `read_emigration()` | 2010 |
| `questionnaire()`, `interview_manual()` | 1960, 1970, 1980, 1991, 2000, 2010, 2022 |
| `data_dictionary(dataset = "microdata")` | 2000, 2010, 2022 |
| `data_dictionary(dataset = "tracts")` | 1970, 1980, 1991, 2000, 2010, 2022 |

`read_tracts()` datasets differ per census — 2000 (6), 2010 (8), 2022 (9); the authoritative lists
are in `R/read_tracts.R:77-86` and mirrored in that function's roxygen `@param dataset`.

---

## The `year` contract

**No function assumes a year.** All 9 functions taking `year` guard with
`if (missing(year) || is.null(year)) { error_year_not_declared() }` (`R/utils.R`), so both an
omitted `year` and an explicit `year = NULL` return *"Please declare the `year` of the census."*
Keep the signature as bare `year` - a `year = NULL` default would advertise a default in
\usage{} and imply NULL is a meaningful value.

---

## The Arrow / DuckDB contract

- `read_*()` returns an **arrow `Dataset`** by default (`as_data_frame = FALSE`). This *is* the
  package's core promise — larger-than-memory census data via {dplyr}. Never change the default,
  and never add a step that silently collects into memory.
- `merge_households = TRUE` routes through DuckDB (`R/merge_household.R`) over a `tempfile()`
  connection. Writes must stay inside `tempdir()` (CRAN policy).
- Column selection happens **lazily** via `dplyr::select()` on the Dataset before any `collect()`.

---

## Folder Structure

```
censobr/
├── CLAUDE.md / MEMORY.md         # This file / [LEARN] store
├── DESCRIPTION / NAMESPACE       # Metadata / GENERATED exports (never hand-edit NAMESPACE)
├── NEWS.md                       # User-facing changelog (bump per release)
├── cran-comments.md              # CRAN notes — justify every remaining NOTE here
├── R/                            # Source: 6 read_*, 3 docs, 3 cache fns + utils/onLoad
├── tests/testthat/               # 16 test files; tests/tests_rafa/ is scratch (Rbuildignored)
├── man/                          # GENERATED .Rd — edit roxygen in R/
│   └── roxygen/templates/        # 9 shared @template blocks (year, cache, columns, verbose, ...)
├── vignettes/                    # censobr, census_tracts_data, documentation, larger_than_memory
├── inst/CITATION                 # How to cite
├── pkgdown/_pkgdown.yml          # Site config
├── data_prep/                    # LEGACY — real pipeline is in ipea/censobr_prep_data
├── .github/workflows/            # R-CMD-check, R-CMD-check-CRAN, pkgdown, test-coverage
├── quality_reports/              # Plans, specs, session logs, merges
├── .claude/                      # Pruned R-package kit (state/ is gitignored)
└── templates/                    # session-log / requirements-spec / quality-report / skill-template
```

---

## Commands

```r
devtools::document()                    # Regenerate man/ + NAMESPACE after editing roxygen
devtools::test()                        # Test suite (network-dependent — see below)
devtools::check(args = "--as-cran")     # Full CRAN check (~12 min — run in background)
covr::package_coverage()                # Coverage
pkgdown::build_site()                   # Docs site
```

```r
# The release gate is BOTH modes. A check run with --no-examples/--no-tests
# executes no package code and must never be reported as passing.
devtools::check(pkg = ".", cran = TRUE,  env_vars = c(NOT_CRAN = "false")) # CRAN policy
devtools::check(pkg = ".", cran = FALSE, env_vars = c(NOT_CRAN = "true"))  # runs examples/tests/vignettes
```

**CRAN submission:** update `NEWS.md`, bump `Version` in `DESCRIPTION`, refresh `cran-comments.md`
with a justification for every remaining NOTE, then `devtools::release()` (maintainer-only).

---

## Quality Gate

| Check | Bar |
|---|---|
| `R CMD check --as-cran` | 0 errors, 0 warnings, every NOTE explained in `cran-comments.md` |
| `devtools::test()` | All pass; every exported function has ≥1 test |
| Coverage (`covr`) | No exported function at 0% |
| roxygen docs | Every exported fn: `@param` (all args), `@return`, runnable `@examples` |
| CI | R-CMD-check + R-CMD-check-CRAN + test-coverage green |

Full standard: [`.claude/rules/r-package-conventions.md`](.claude/rules/r-package-conventions.md).

**Note on `/commit`:** Steps 0 and 0b call `scripts/quality_score.py` and
`scripts/check-surface-sync.sh` — built for the Beamer/Quarto template this workflow was forked
from. **Neither exists here; there is no `scripts/` dir. Skip Steps 0/0b.** The real gate is
`/r-package-check`. Steps 1–7 (branch, stage, commit, PR, merge) apply normally.

---

## Testing notes

- **Every test and example hits the network** (GitHub Releases). Examples use
  `@examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")`. An offline failure is an
  environment problem, not a code bug — confirm connectivity before debugging.
- Download/cache internals are wrapped in `# nocov start/end` (`R/utils.R`, `R/cache.R`);
  low coverage there is expected.
- `tests/tests_rafa/` is a scratch directory, not part of the suite.

---

## Skills live in this repo

`.claude/` was pruned to an R-package kit — **7 rules, 12 skills, 4 agents**. Nothing lecture-,
manuscript-, or grant-related remains; the full fleet stays at `~/.claude/` and can be invoked from
there if ever needed.

- **Package dev:** `/r-package-check` (the release gate), `/review-r`, `/diagnose`, `/deep-audit`
- **Workflow:** `/commit` (Steps 0/0b skipped), `/checkpoint`, `/context-status`, `/compress-session`
- **Memory:** `/learn`, `/promote-memory`
- **Meta:** `/permission-check`, `/new-skill`

**Rules:** `r-package-conventions` (the standard) · `plan-first-workflow` · `session-logging` ·
`orchestrator-protocol` · `model-routing` · `prompt-shaping` · `summary-parity`
**Agents:** `r-package-reviewer` · `r-reviewer` · `verifier` · `promote-memory-council`

---

## Exported functions (12)

| Family | Functions |
|---|---|
| Microdata | `read_population()` `read_households()` `read_families()` `read_mortality()` `read_emigration()` |
| Census tracts | `read_tracts()` |
| Documentation | `data_dictionary()` `questionnaire()` `interview_manual()` |
| Cache | `censobr_cache()` `set_censobr_cache_dir()` `get_censobr_cache_dir()` |

All `read_*()` share the `year`, `columns`, `add_labels`, `as_data_frame`, `showProgress`, `cache`,
`verbose` roxygen `@template`s in `man/roxygen/templates/` — check those before adding a parameter
with the same shape.

---

## Pipeline of each function

Line references are to the current source; re-check them after refactors.

### `read_population(year, columns, add_labels, as_data_frame, showProgress, cache, verbose)`

Returns an arrow `Dataset` (default) or a `data.frame`. Returns `invisible(NULL)` — **not** an
error — if the download fails.

1. **Validate inputs** — `R/read_population.R:37-42`. `checkmate` asserts on `year` (numeric),
   `columns` (vector or `NULL`), `as_data_frame` / `verbose` (logical), `add_labels` (string
   matching `pt`, or `NULL`).
2. **Check year availability** — `:45-48`. `years <- c(1960, 1970, 1980, 1991, 2000, 2010)`;
   anything else calls `error_missing_years()` (`R/utils.R:147`), which `cli::cli_abort`s with
   `call = rlang::caller_env()` so the error is attributed to `read_population()`, not the helper.
3. **Build the URL** — `:51-53`. Interpolates the data-release pin twice:
   `…/ipea/censobr_prep_data/releases/download/{tag}/{year}_population_{tag}.parquet`.
4. **Download or resolve from cache** — `:57-60` → `download_file()` (`R/utils.R:11-66`):
   - `:21-23` resolve the versioned cache dir `{cache_dir}/data_release_{tag}`, creating it
     **only when `cache = TRUE`** — with `cache = FALSE` and no pre-existing dir, `curl` cannot
     create the parent and the download fails at `:48`;
   - `:26-27` build the local path from `basename(file_url)`;
   - `:30` `cache_message()` reports which of the four cache states applies (gated on `verbose`);
   - `:33-35` **cache hit short-circuits** — an existing local file is returned unread and
     unvalidated when `cache = TRUE`;
   - `:38-45` otherwise `curl::multi_download()`, with `resume = cache`;
   - `:48-63` on failure (unsuccessful download, or a file smaller than 5000 bytes) emit a
     `cli_alert_danger` and return `invisible(NULL)`.
5. **Bail out on failed download** — `:63`. `NULL` propagates straight to the caller as
   `invisible(NULL)`.
6. **Open as an Arrow Dataset** — `:66` → `arrow_open_dataset()` (`R/utils.R:78-92`), which wraps
   `arrow::open_dataset()` in `tryCatch` and, on a corrupt Parquet file, aborts with a message
   naming the exact `censobr_cache(delete_file = …)` call to fix it. **This is where a corrupted
   cache hit from step 4 is finally caught.**
7. **Merge household variables** — `:68-74`, **currently commented out** (along with its assertion
   at `:41`). `read_population()` does not expose a `merge_households` parameter at all. The live
   users of that path are `read_emigration()` (`:75-76`) and `read_mortality()` (`:76-77`), which
   call `merge_household_var()` (`R/merge_household.R:12`); it is also commented out in
   `read_families()`. So the DuckDB join is unreachable from here.
8. **Select columns** — `:77-79`. `dplyr::select(df, dplyr::all_of(columns))` on the Dataset, so
   the projection is **lazy** — unselected columns are never read off disk.
9. **Add labels** — `:82-86` → `add_labels_population()` (`R/add_labels_population.R:3-446`).
   Recodes categorical variables to Portuguese via `case_when()`, guarded per variable by
   `if ('V0601' %in% cols)` against the column list captured at `:14`.
10. **1960 warning** — `:89-91`. A base `warning()` explaining that the 1960 microdata combines two
    IBGE releases (25% sample + 1.27% sub-sample); see the `1960_census_section` `@template`.
11. **Return** — `:94-97`. `as_data_frame = TRUE` triggers `dplyr::collect(df)` — **the only point
    where data enters memory** (except the merge path, below). Otherwise the lazy Dataset is returned.

**Gotchas worth knowing**

- **Labeller coverage is narrower than reader coverage.** Step 1 accepts `add_labels = "pt"` for
  *any* valid year, but each labeller aborts on years it doesn't cover — and only *after* the
  parquet has downloaded. `read_population()` reads 6 years but labels only 2010
  (`R/add_labels_population.R:9-11`); `read_households()` reads 6 but labels 2000 + 2010
  (`R/add_labels_households.R:9-11`). So `read_population(2000, add_labels = "pt")` downloads a
  large file, then errors.
- **Steps 8 and 9 are order-dependent.** Columns are selected *before* labels are applied, and the
  labeller only touches variables still present. Selecting a narrow `columns` set silently skips
  labelling for everything dropped — no warning.
- **The 1960 warning ignores `verbose`.** Every other message in the pipeline is gated on it; this
  one fires even with `verbose = FALSE`.
- **`assert_string(add_labels, pattern = "pt")` is a regex match**, not equality — `"ptbr"` passes
  both asserts, then silently skips the `lang == 'pt'`-guarded labelling block
  (`R/add_labels_population.R:27`) — no error, no labels.
- **A cache hit is never integrity-checked** (step 4), only size-checked on fresh download. Corrupt
  cached files surface later, at step 6.

### Microdata readers — deltas from `read_population()`

All five share steps 1-6 and 11 above. Differences only:

| Function | Years | `merge_households` | Labeller | Notes |
|---|---|---|---|---|
| `read_population()` | 1960-2010 (6) | commented out | `add_labels_population()` (2010 only) | 1960 `warning()` |
| `read_households()` | 1960-2010 (6) | not present | `add_labels_households()` (2000 + 2010) | 1960 `warning()`; no merge block at all |
| `read_families()` | 2000 | commented out (`:66-72`) | `add_labels_families()` (2000 + 2010) | no 1960 warning; labeller's 2010 branch is unreachable |
| `read_mortality()` | 2010 | **live** (`:76-82`) | `add_labels_mortality()` (2010) | merge runs **before** select+labels |
| `read_emigration()` | 2010 | **live** (`:75-81`) | `add_labels_emigration()` (2010) | merge runs **before** select+labels |

**`merge_household_var()`** (`R/merge_household.R:12-113`), reached only from `read_mortality()` and
`read_emigration()`: calls `censobr::read_households()` for the same year (`:19-25`), picks join keys
per census year (`:33-56` — 1970 `id_household`, 1980 `V601`, 1991 `V0109`, 2000/2010 `V0300`; the
1960 branch is commented out at `:28-31`), drops duplicated columns (`:60-62`), then joins through
a temporary DuckDB database (`tempfile()`, `:77-110`) and returns an arrow Table.
**It breaks the lazy contract before step 11**: `:68` `collect()`s the key values and `:73`
`compute()`s the household table into memory.

### `read_tracts(year, dataset, as_data_frame, showProgress, cache, verbose)`

1. **Validate** — `R/read_tracts.R:62-67`. Note there is **no `columns` or `add_labels` parameter**;
   both blocks exist but are commented out (`:121-131`).
2. **Check year** — `:71-74`, `c(2000, 2010, 2022)`.
3. **Check dataset** — per-census lists at `:77-86` (2000: 6, 2010: 8, 2022: 9). Input is lowercased
   at `:89` and compared against `tolower()` of each list, so `dataset` is case-insensitive.
4. **Build URL** — `:104-107`. `dataset` first gets `'_'` appended (`:104`), giving
   `{year}_tracts_{dataset}_{tag}.parquet` with the dataset name **lowercased**.
5. **Download → open → return** — `:110-138`, identical to steps 4-6 and 11 above.

### Documentation functions

All three fetch from the **fixed** `censo_docs` release tag, not the data-release pin.

| Function | Validates | File built | Opens with |
|---|---|---|---|
| `data_dictionary(year, dataset, …)` | `dataset` against 2 names (`microdata`, `tracts`) (`R/data_dictionary.R:50-53`), then year per dataset (`:56-62`) | 3 branches (`:76-93`): `microdata`→`.xlsx`; the 5 microdata types→`.html`; `tracts`→`.pdf`, swapped to `.xlsx` for 2022 (`:92`) | `browseURL()` for pdf/html, else `open_file()` (`:107-113`) |
| `questionnaire(year, type, …)` | year (7 options) + `type` in `c("long","short")` (`R/docs_questionnaire.R:40-57`) | `{year}_questionnaire_{type}.pdf` | `utils::browseURL()` (`:72`) |
| `interview_manual(year, …)` | year (7 options) (`R/docs_interview_manual.R:33-40`) | `{year}_interview_manual.pdf` | `utils::browseURL()` (`:56`) |

All three bail with `NULL` if the download fails. Only `data_dictionary()` returns `NULL`
explicitly (`:115`); the other two return the value of `utils::browseURL()`.

### Cache functions

- **`set_censobr_cache_dir(path, verbose)`** — `R/cache.R:39-70`. `NULL` resets to the default
  (`tools::R_user_dir("censobr", "cache")`); otherwise normalises `path`. Writes the chosen path as
  a single line into the config file `R_user_dir("censobr","config")/cache_dir` (`:58-67`), creating
  it if absent. **This is what makes the setting persist across sessions.** Returns the path
  invisibly. Note it does **not** create the cache directory itself, only records the path.
- **`get_censobr_cache_dir()`** — `R/cache.R:87-100`. Reads the config file if present, else falls
  back to the default. Every download resolves its destination through this.
- **`censobr_cache(list_files, print_tree, delete_file, verbose)`** — `R/cache.R:146-233`. Lists
  recursively from the cache **root** (`:165`), so files from *all* data releases are visible.
  `delete_file` is a `grepl()` **pattern**, not an exact name (`:181-194`) — it deletes every match.
  `delete_file = "all"` calls `fs::dir_delete()` on the whole cache dir (`:205`).

**Gotchas across these**

- **`verbose` gating is inconsistent in the docs functions.** `data_dictionary()` only opens the
  file when `verbose = TRUE` (`:107`, the fix for issue #72 in v0.6.0), but `questionnaire()` and
  `interview_manual()` call `browseURL()` unconditionally. The same fix was never applied to them.
- **Two defaults are unusable.** `interview_manual(year = NULL)` and `questionnaire(type = NULL)`
  both hit `checkmate` asserts with no `null.ok`, so calling either with its own default errors.
- **`read_tracts()` cannot subset columns**, unlike every microdata reader — the whole tract table
  is opened.
- **`censobr_cache()`'s empty-cache early return is gated on `verbose`** (`R/cache.R:169-174`), so
  with `verbose = FALSE` and an empty/absent cache dir it falls through to the listing code.


---

## Known follow-ups

See [MEMORY.md](MEMORY.md) for detail.

1. **Vignette prose/output drift (open).** `vignettes/census_tracts_data.Rmd:90` calls
   `data_dictionary()` in an evaluated chunk; knitting is non-interactive, so it now prints a
   machine-specific cache path instead of opening the file, and the prose above it still says the
   function "will open the file".
2. **`Config/testthat/edition: 3`** — deferred to its own commit. 16 `context()` calls and one
   `expect_is()` need removing first, and 3e switches `expect_equal` to waldo against ~10
   arrow-collected numeric totals.
3. **`download_file()` latent** — if `try()` catches a real throw, `downloaded_files` is undefined
   and `R/utils.R:48` errors with "object not found".

**Fixed 2026-08-28** (commits `9110ef1`, `b7213eb`, `10a24b9`; see `NEWS.md` dev section):
`cache = FALSE` on a fresh install; `add_labels` accepting non-`"pt"` strings; `read_tracts()` 2000
error list; two `censobr_cache()` errors; swapped `download_file()` messages; the `year` contract;
and informative option lists for `questionnaire(type)` / `read_tracts(dataset)` /
`data_dictionary(dataset)`.

## Onboarding: check-in mode (temporary)

While the user is learning this workflow, execution after plan approval **pauses and reports at
each numbered phase boundary** before starting the next. Relax to full contractor mode on request.
