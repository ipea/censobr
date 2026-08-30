# Plan — `merge_households` for `read_population()`

**Status:** IMPLEMENTED (v3 plan, implemented 2026-08-30; `R CMD check --as-cran` 0/0/0 in
both modes; see the "Implementation notes" section at the end for what changed from the
plan during coding)
**Date:** 2026-08-30
**Files touched:** `R/merge_household.R`, `R/read_population.R`, `R/read_mortality.R`,
`R/read_emigration.R`, `tests/testthat/test_read_population.R`,
`tests/testthat/test_zz_graceful_failure.R`, `README.md`, `vignettes/censobr.Rmd`,
`NEWS.md`, `man/*` (generated)

> **v1 → v2.** Three adversarial reviews (correctness, memory/perf, CRAN/API) plus a
> measurement round overturned v1's central diagnosis and three of its four claimed bug
> fixes. §7 records what was wrong, so the same mistakes are not re-made. Read §2 first:
> **the join is nearly free; the parquet writer is the entire cost.** That inverts the
> design.

---

## 1. The problem

`read_mortality(merge_households = TRUE)` works because the mortality table is small.
`merge_household_var()` ends at `R/merge_household.R:107` with `duckdb_fetch_arrow()`,
which materialises the **whole join result** as an in-memory Arrow `Table`. At population
scale that is 20.6M x 312, and it also breaks the package's core contract by returning an
in-memory `Table` where a lazy `Dataset` is documented (`MEMORY.md` `[LEARN:arrow]`).

| table | rows | cols | parquet |
|---|---|---|---|
| `2010_population` | 20,635,472 | 251 | 803 MB |
| `2010_households` | 6,192,332 | 83 | 143 MB |
| common columns | — | 22 (3 keys, 19 dropped) | — |
| merged | 20,635,472 | 312 | 0.87 GB |

## 2. What the measurements actually say

Peak RSS measured per scenario, one OS process each (`PeakWorkingSet64`), DuckDB
`memory_limit = 2GB` unless stated. Full table in §5.

| scenario | result | time | peak RSS |
|---|---|---|---|
| **join alone**, `count(*)`, no writer | **OK** | **0.8 s** | **0.59 GB** |
| **writer alone**, 251 cols, no join | **FAIL** (OOM) | — | 2.72 GB |
| full merge, 4 GB limit | FAIL (OOM) | — | 4.50 GB |
| full merge, 8 GB limit | FAIL (OOM) | — | 9.28 GB |
| full merge, default limit (31 GiB) | OK | 131 s | not measured |
| `register_arrow` variant, default limit | OK | 165 s | **26.73 GB** |
| **narrow: `columns=` push-down (4 requested)** | **OK** | **2.6 s** | 0.05 GB out |

**The join is not the problem.** It completes in 0.8 s inside 0.59 GB. A plain 251-column
copy *with no join at all* fails at 2 GB. The cost is the **parquet writer**, and it scales
as:

```
peak writer memory  ≈  row_group_size × n_columns × bytes_per_value × threads
```

Checked against the measurement: `122,880 × 251 × 8 × 12 ≈ 2.96 GB` vs. **2.72 GB measured**
in the writer-alone run. That is the mechanism, and it is now the design constraint.

Then the full-width merge was measured across memory limits (§5), and the picture closed:

| memory limit | result | time | peak RSS |
|---|---|---|---|
| default (31 GiB) | OK | 135 s | **20.14 GB** |
| 16 GB | OK | 381 s | 16.87 GB |
| 12 GB | FAIL | — | 12.98 GB |
| 8 GB | FAIL | — | 8.70 GB |
| 2 GB (thr 2, rg 20k) | OK | **97 min** | 2.81 GB |

### The conclusion that reshapes the feature

**The full-width (312-column) merge is not a shippable default.** It needs ~20 GB of RAM to
run in 135 s, degrades 3x at 16 GB, fails below 12 GB, and at 2 GB takes an hour and a half.
No CRAN package can make that the behaviour of its flagship reader. Tuning the writer does
not rescue it (§5) — at a tight limit the *join payload*, not the writer, is what spills.

**The narrow path is excellent**: 2.6 s, 0.05 GB, on any machine.

So `columns` stops being an optimisation and becomes **part of the contract**:

1. **Width, not length, is what hurts.** Chunking by row (state, year) does not help — the
   cost has no row-count term. This is worth stating because it is the obvious first idea
   and it would have been wasted work.
2. **`read_population(merge_households = TRUE)` requires `columns`.** With `columns = NULL`
   it aborts with an informative error stating the cost and telling the user to name the
   variables they want, from either table. A user who genuinely wants all 312 can pass them
   explicitly — which makes a 20 GB operation an informed choice instead of an ambush.
3. **`read_mortality()` / `read_emigration()` are unaffected** — small tables, `columns`
   stays optional, current behaviour preserved.

## 3. Implementation phases

### Phase 0 — Verify before writing code (blocking)

The per-year key table (`R/merge_household.R:33-58`) has **only ever run for 2010**, via
mortality/emigration. `read_population()` supports six years.

- [ ] **1960 has no branch** (`:28-31` commented out) — `key_vars` would be undefined and
      the user gets `object 'key_vars' not found`. Find the key or refuse 1960.
- [ ] 1970 / 1980 / 1991 / 2000: confirm the listed keys exist in **both** files.
- [ ] **Key uniqueness** per year. *Verified 2010:*
      `count(*) = count(DISTINCT (code_state, code_muni, V0300)) = 6,192,332`.
- [ ] **Match rate** per year — `nrow` equality is **not** sufficient. A LEFT JOIN against a
      unique key preserves row count at a **0% match rate**, so the row-count test cannot
      detect a broken key. Measure `count(<a household-only column>) / count(*)`.
      *Verified 2010: 100%.* Without this, `read_population(1980, merge_households = TRUE)`
      could ship a table of all-`NA` household columns with every test green.
- [ ] 1980 specifically: `key_vars` lists **four** columns (`code_state`, `code_muni`, `V6`,
      `V601`) while `key_key = 'V601'`. Confirm `V6` exists in both.
- [ ] Record **rows / cols / file size per year** while the footers are open (free — no data
      scan). The memory rule is a function of `n_columns`, and 2010 is *assumed*, not shown,
      to be the widest year.

Deliverable: a six-row go/no-go table in the session log. Years that fail are refused by
the Phase 3 year guard.

### Phase 1 — (dropped)

v1 proposed splitting `open_censobr_data()` into `censobr_data_path()`. **Dropped.**
Reasons: it broke the corrupt-cache contract (see below), it broke a test's call signature,
and the `register_arrow` architecture it was meant to enable measured *slower and far
heavier* than the native path (165 s / 26.7 GB vs. 131 s). The population side keeps going
through `open_censobr_data()` → `arrow_open_dataset()`, which is the **only** thing in the
package that detects a corrupt cached parquet, unlinks it, and returns `invisible(NULL)`.
Handing raw paths to DuckDB's `read_parquet()` would have lost that self-healing and
surfaced a raw `IO Error` instead.

The one path DuckDB still needs is the population file's location, which
`arrow::open_dataset()` already exposes as `Dataset$files` — valid here because the
population side is always a plain `FileSystemDataset` at that point (labels are applied
*after* the merge, never before).

### Phase 2 — Rewrite the guts of `merge_household_var()` (`R/merge_household.R`)

Signature keeps `df` first, so the two existing callers and
`tests/testthat/test_zz_graceful_failure.R:114` (`merge_household_var(df = NULL, ...)`)
keep working:

```r
merge_household_var(df, year, columns = NULL, add_labels = ..., showProgress = ...,
                    cache = ..., verbose = ...)
```

1. **Household side keeps going through `read_households()`** — unchanged, including
   `add_labels`. This is load-bearing: reading the household parquet directly with DuckDB
   would bypass `add_labels_households()` and silently return raw codes for ~16 household
   variables that ship labelled today (`V4001 V4002 V0201 V0202 V0205-V0212 V0402 V6210
   V6600`). Also **forward `cache`**, which the current code drops — today
   `read_mortality(cache = FALSE, merge_households = TRUE)` still caches the household file.
2. `if (is.null(df_household)) return(invisible(NULL))` — graceful-failure contract.
3. Keep the existing `nrow(df) < nrow(df_household)` pre-filter (`:69-74`). It is what makes
   the mortality/emigration path fast and it does not fire for population.
4. **Column push-down** when `columns` is a character vector: restrict each side to
   `union(intersect(columns, <side>), key_vars)` before the join. §2 consequence 2.
   Guarded on `is.character()` because `columns` also takes numeric indices — and note in
   the roxygen that numeric `columns` **bypasses the mitigation** and costs the full-width
   price.
5. **Build the SQL from explicit quoted column lists. No `SELECT * EXCLUDE (...)`.**
   v1's `EXCLUDE` template is computed from the *full* schemas but applied to the
   *push-down-restricted* subquery. Both failure modes verified on duckdb 1.5.5:
   ```
   SELECT * EXCLUDE (dup) FROM (SELECT k,z FROM R)   Binder Error: Column "dup" in EXCLUDE list not found
   SELECT * EXCLUDE () FROM R                        Parser Error: syntax error at or near ")"
   ```
   Explicit lists fix both, and let the output column order be chosen rather than inherited.
   Quote identifiers with `duckdb::dbQuoteIdentifier()`, and the tempfile paths with
   `dbQuoteLiteral()`, rather than pasting them into `glue::glue()`.
6. **DuckDB session settings.** Because `columns` is now required (§2), the pathological
   full-width write is off the table and aggressive writer tuning is no longer
   load-bearing — do **not** ship the `thr 4 / rg 10k` values from the writer-only sweep,
   which failed on the real merge. Leave `ROW_GROUP_SIZE` at DuckDB's default and threads
   to DuckDB, except forcing ≤ 2 when `_R_CHECK_LIMIT_CORES_` is set. Still wrap the `COPY`
   in `tryCatch()` so an OOM returns `invisible(NULL)` per the graceful-failure contract
   rather than propagating a raw DuckDB error.
   Set `temp_directory` into `tempdir()`, `preserve_insertion_order = false`, and an
   explicit `memory_limit` — **never** DuckDB's default of ~80% of system RAM, which lets
   the merge evict everything else the user has open.
   Pass these through **`duckdb::duckdb(config = list(...))`**, not `DBI::dbExecute()`:
   `DBI` is in **Suggests**, and `duckdb` does **not** export `dbExecute` (verified), so a
   `DBI::` call would put a Suggests-only package in `R/`.
7. `COPY (<join>) TO <tempfile.parquet> (FORMAT PARQUET, COMPRESSION ZSTD, ROW_GROUP_SIZE <rg>)`.
8. `on.exit({duckdb::dbDisconnect(con); unlink(db_path)}, add = TRUE)` — the real leak is
   that `db_path` is **never** unlinked. (v1 also claimed a Windows file lock from omitting
   `shutdown = TRUE`; that was **wrong** — `?duckdb` states the instance shuts down
   automatically, and the file unlinks cleanly. See §7.)
9. Open the result with `arrow::open_dataset()` and a **merge-specific** error handler —
   **not** `arrow_open_dataset()`, whose failure path unlinks the file and tells the user
   *"Please run the function again to download it"*, which for a freshly written temp file
   means deleting 0.87 GB of work and re-running the join to hit the same wall.
10. Return type: a lazy `Dataset` for `read_population()`; `read_mortality()` and
    `read_emigration()` `compute()` it back to a `Table` to preserve their current return
    exactly — see Decision (a).

### Phase 3 — Wire into `read_population()`

- Add `merge_households = FALSE` **at the end of the signature** (after `verbose`), not at
  position 4 — Decision (b).
- `checkmate::assert_flag(merge_households)`, **not** `assert_logical()`: `assert_logical()`
  passes `NA` and passes length-2 vectors (verified), and `isTRUE()` then silently treats
  both as `FALSE`.
- **Hoist the `add_labels` x `year` compatibility check above the download.**
  `add_labels_population()` aborts for any year ≠ 2010 and it runs *after* the merge, so
  `read_population(2000, add_labels = 'pt', merge_households = TRUE)` would download
  ~950 MB, run the join, write ~0.9 GB, and only then error.
- Year guard against the Phase-0 go-list, before any download.
- Graceful-failure line copied from `read_mortality.R:74`.
- **Keep the post-merge `dplyr::select(df, dplyr::all_of(columns))`.** It is lazy and free,
  and dropping it would return the join keys the user never asked for (`columns = 'V0601'`
  → 4 columns, not 1) and lose the user's requested column order.
- `verbose` message before the join, carrying the expected cost.
- **`merge_households = TRUE` requires `columns`** (§2). With `columns = NULL`, abort before
  any download:
  *"Merging household variables into the population microdata produces ~312 columns and
  requires roughly 20 GB of memory. Please use `columns` to select the variables you need
  (they may come from either the population or the household data)."*
  This is the single most consequential design change from v1 — Decision (c).
- `as_data_frame = TRUE` stays permitted, because `columns` is now always set and the
  collected result is bounded by the user's own selection.

### Phase 4 — Docs, NEWS, tests

- `@template merge_households` on `read_population()` (template already exists).
- **`README.md:56-66` and `vignettes/censobr.Rmd:164-174`** both print the canonical
  signature under *"all {censobr} functions … operate on the same logic"*. Both need
  updating; neither was in v1's file list. No vignette documents `merge_households` at all.
- `NEWS.md`: the feature; `cache` now forwarded; the `db_path` leak. **Not** the two
  fabricated fixes (§7). If `preserve_insertion_order = false` is applied to the shared
  helper, row order of the *existing* `read_mortality()`/`read_emigration()` merge output
  changes — that needs its own bullet.
- `cran-comments.md` refresh.
- Tests, gated as the suite already gates: `nrow` equality; **match rate > 0**;
  `all(names(read_households(y)) %in% names(merged))`; a `columns=` request spanning both
  sides returning **exactly and only** those columns, in order; `columns = 'banana'` still
  erroring with "not found" **and attributed to `read_population()`**, not to the internal
  helper (`error_columns_absent()` uses `rlang::caller_env()`).
- Un-comment `merge_households` in the `tester()` helper (`test_read_population.R:10,19`).
- No `@examples` with `merge_households = TRUE`.
- **Note honestly:** `NOT_CRAN: false` in both CI workflows, and covr does not set
  `NOT_CRAN`, so every one of these tests is skipped in CI and runs only on the maintainer's
  machine. Either add an opt-in `workflow_dispatch` job with `NOT_CRAN: true`, or state in
  the plan that merge correctness is manually verified — Decision (e).

## 4. Verification

- [ ] `devtools::document()` clean
- [ ] `devtools::test()` green
- [ ] `devtools::check(cran = TRUE,  env_vars = c(NOT_CRAN = "false"))` — 0 / 0 / 0
- [ ] `devtools::check(cran = FALSE, env_vars = c(NOT_CRAN = "true"))`
- [ ] `read_population(2010, merge_households = TRUE)` — **peak RSS ≤ 4 GB**, measured by
      `PeakWorkingSet64` on a dedicated process (not "stays flat by eye")
- [ ] `read_mortality(2010, merge_households = TRUE)` — identical content **and** identical
      labels to the current release, diffed column by column

## 5. Measurements

Prototypes in `scratchpad/proto*.R`. Machine: 39.7 GiB RAM, 12 threads, duckdb 1.5.5,
arrow 25.0.0. Warm page cache; single runs.

| # | scenario | limit | result | time | out | peak RSS |
|---|---|---|---|---|---|---|
| A | writer alone, 251 cols, no join | 2 GB | FAIL | — | — | 2.72 GB |
| B | join alone, `count(*)`, no writer | 2 GB | **OK** | 0.8 s | — | 0.59 GB |
| C | full merge | 8 GB | FAIL | — | — | 9.28 GB |
| D | full merge | 4 GB | FAIL | — | — | 4.50 GB |
| E | full merge | default | OK | 131 s | 0.87 GB | not measured |
| F | `register_arrow` variant | default | OK | 165 s | 0.87 GB | 26.73 GB |
| G | narrow, `columns=` 4 requested | 2 GB | **OK** | 2.6 s | 0.05 GB | — |
| H | full merge (explicit col lists) | default | OK | 135 s | 0.87 GB | **20.14 GB** |
| I | full merge | 16 GB | OK | 381 s | 0.87 GB | 16.87 GB |
| J | full merge | 12 GB | FAIL | — | — | 12.98 GB |
| K | full merge | 8 GB | FAIL | — | — | 8.70 GB |

Writer tuning sweep (`proto5.R`, writer isolated at 251 cols, `memory_limit = 2GB`):

| threads | `ROW_GROUP_SIZE` | result | time | output | peak RSS |
|---|---|---|---|---|---|
| 1 | 122,880 (default) | OK | 302 s | 0.78 GB | 2.21 GB |
| 2 | 20,000 | OK | 158 s | 0.89 GB | 2.01 GB |
| **4** | **10,000** | **OK** | **107 s** | 0.97 GB | **2.20 GB** |
| 12 | 5,000 | **FAIL** | 0.9 s | — | 1.07 GB |

**Tuned, the operation is both lighter and faster than untuned**: 107 s / 2.20 GB against
131 s / >9 GB. Smaller row groups cost ~24% in file size (0.78 → 0.97 GB) — the ZSTD
dictionary resets per column chunk — and add footer metadata that
`arrow::open_dataset()` parses on every open. Neither was material at this scale.

**But the writer-only winner does not survive the real merge.** Validated at full width
(312 cols, `memory_limit = 2GB`, `proto6.log`):

| threads | `ROW_GROUP_SIZE` | result | time | output | peak RSS |
|---|---|---|---|---|---|
| 4 | 10,000 | **FAIL** | 15.8 s | — | 2.42 GB |
| 2 | 20,000 | OK | **5,831 s (97 min)** | 1.02 GB | 2.81 GB |

Ninety-seven minutes, against 131 s for the same merge given RAM. Constraining the
full-width merge to 2 GB does not make it bounded-and-fine; it makes the join payload spill
continuously and the feature unusable. **Tuning the writer solves the isolated writer and
does not solve the merge.** The 251-column writer-only sweep was measuring the wrong thing.

**The last row of the writer sweep falsifies the tidy version of the formula.** By `rg × ncol × threads`,
`12 × 5,000` should have been the *cheapest* configuration of the four; it failed in under
a second. So `row_group_size × n_columns × threads` is a **useful heuristic for the
direction of the effect, not a predictive model** — there is evidently a per-thread,
per-column fixed allocation the formula omits. Consequences for Phase 2.6:

- Do **not** compute `rg` from a formula and trust it. Ship the empirically validated
  `threads = 4, ROW_GROUP_SIZE = 10000`, and treat any change to those numbers as
  requiring a re-run of this sweep.
- Wrap the `COPY` in `tryCatch()` and, on an OOM, retry once at `threads = 1`,
  `ROW_GROUP_SIZE = 20000` before failing gracefully with `invisible(NULL)`. The failure is
  cheap to detect (0.9 s) and the retry is the difference between a working feature and an
  opaque `Out of Memory Error` on a machine we have not tested.

**Not measured, and therefore not claimed:** cold-cache timings (the ~950 MB of downloads
are excluded throughout); any year other than 2010; the labelled path (all figures above
are `add_labels = NULL`, and labels widen the household side); spill volume
(`duckdb_temporary_files()`); free-space behaviour when `TMPDIR` is small, quota'd, or a
RAM-backed tmpfs — on a tmpfs `/tmp`, "disk-backed" is a fiction and the output counts
against RAM.

## 6. Decisions for you

| # | Decision | Recommendation |
|---|---|---|
| (a) | Should `read_mortality()`/`read_emigration()` start returning a lazy `Dataset` instead of an in-memory `Table`? | **No.** v1 said yes and called it "a fix". Verified: `$` and `[[` on a `Dataset` return **`NULL` with no error**, so `df$V0704` in existing user scripts would silently yield nothing. They keep returning a `Table`. |
| (b) | Where does `merge_households` go in `read_population()`'s signature? | **At the end.** Position 4 (matching `read_mortality()`) silently reinterprets `read_population(2010, cols, 'pt', TRUE)` from `as_data_frame = TRUE` to `merge_households = TRUE`, and both are logical so nothing errors. Costs family symmetry; a future major version can realign all six. |
| (c) | **`merge_households = TRUE` without `columns` on `read_population()`** — measured at ~20 GB RAM / 135 s, failing below 12 GB, 97 min at 2 GB | **Require `columns`.** Abort before downloading, with the estimate and instructions. The alternative is a function that OOMs or runs for 90 minutes on an ordinary laptop. This is the biggest open question in the plan and the one I most want your view on — it makes `read_population()`'s merge behave differently from `read_mortality()`'s. |
| (d) | Writer threads / row-group size | The writer-only sweep found `thr 4 / rg 10k`; it **failed** on the real merge. Since `columns` is now required, the full-width path largely disappears and aggressive tuning is no longer load-bearing. Set a modest explicit `memory_limit` and leave threads to DuckDB, except forcing ≤2 when `_R_CHECK_LIMIT_CORES_` is set (CRAN's actual requirement — it applies during checks, not always). |
| (e) | Merge tests never run in CI (`NOT_CRAN: false` everywhere; covr doesn't set it) | Add an opt-in `workflow_dispatch` job. The match-rate check is the only thing standing between users and silently all-`NA` output on five **unvalidated** join keys. |
| (f) | Re-running a merge re-runs the whole join and writes another ~0.87 GB into `tempdir()`, never freed until the session ends | Reconsider v1's "out of scope": a content-keyed temp file (year + sorted columns + data_release) is ~10 lines. Phase 4's own test suite pays this cost four times. |

## 7. What the review round overturned (kept so it is not re-made)

| v1 claim | Verdict |
|---|---|
| `duckdb::duckdb()` writes to `~/.duckdb` → **CRAN policy violation** in released code | **False.** duckdb's default resolves to a per-session temp dir; it used `~/.duckdb` here only because that directory already existed on this machine from another DuckDB client. This was headed for `NEWS.md` as a fixed bug that never existed. The *real* defect is smaller: duckdb 1.5.5 prints a 5-line message that ignores censobr's `verbose = FALSE`, which would break the existing `expect_no_message()` test. `shared_home = FALSE` silences it — but it needs duckdb ≥ 1.5.5, which `Depends: R (>= 4.2.0)` while censobr advertises 4.1.0, so **`suppressMessages()` is the cheaper fix and no version pin is added.** |
| `dbDisconnect()` without `shutdown = TRUE` leaves a Windows file lock | **False.** `?duckdb`: the instance shuts down automatically. Only the missing `unlink(db_path)` is real. |
| The 1.8 GiB in the OOM message "exactly matches" row-group buffering | **Numerology.** 2×10⁹ B *is* 1.86 GiB — DuckDB was echoing its own limit. The 1 GB run likewise reports "953.6 MiB", which is 1×10⁹ B. The mechanism turned out to be right anyway, but only scenario A (writer alone) actually establishes it. |
| `ROW_GROUP_SIZE 20000` fixes the OOM | **Already falsified in v1's own log** — it failed at a 2 GB limit, at a *different* allocation site. |
| The design is "out-of-core / bounded memory" | **Unearned.** Every constrained full-width run failed; the one success needed ~31 GiB of headroom. Bounded memory is a property the Phase 2.6 tuning must now *earn*, and §4 verifies with a number. |
| Splitting out `censobr_data_path()` "keeps every caller working" | True for the five callers, but it silently dropped corrupt-cache detection and broke `test_zz_graceful_failure.R:114`. Phase dropped. |
| `register_arrow` was rejected for forfeiting native parquet scan | Rejected on an untested claim, then measured: **165 s / 26.7 GB** vs. 131 s. The rejection stands, but now on evidence. |

## 8. Implementation notes (what changed while coding)

- **Phase 0 was run for real**, via DuckDB's `httpfs` extension reading the release
  parquet files' footers directly over HTTPS (range requests, no multi-GB downloads).
  Confirmed empirically for every year: 1960 has no key; **1980's household variables
  already all exist in the population file** (zero household-only columns — merging
  would add nothing); **1991's key `(code_state, code_muni, V0109)` is not unique**
  (1,285,449 distinct values across 4,024,543 household rows) and a real LEFT JOIN on it
  inflates 17,045,653 population rows to **1,264,701,251** — a 74x explosion. Final
  supported years: **1970, 2000, 2010**, exactly as guessed in §3 Phase 2, now confirmed
  rather than assumed. 1970's match rate is 98.1% (some population rows legitimately have
  no household record); 2000 and 2010 are 100%.
- **The SQL construction changed from the plan's sketch.** The plan proposed reading the
  household side directly via `read_parquet()` with `SELECT * EXCLUDE (...)`. The
  implementation instead keeps calling `read_households()` (preserving labels, as
  planned) and registers the already-select()ed household table via
  `duckdb_register_arrow()`; only the main table is read natively via
  `read_parquet(path)`. This sidesteps `EXCLUDE` entirely.
- **Two defects found only by running the real code, not caught by the review round:**
  1. The main-table `SELECT` list in the `COPY` query listed only the main table's
     requested columns, so a `columns=` request naming a household-only variable was
     silently dropped from the output — caught by the merged Dataset's `names()` not
     containing the requested column, which then surfaced as a (correct, but
     confusingly-attributed) `error_columns_absent()` from the post-merge `select()`.
     Fixed by projecting the main table inside a subquery and using `SELECT *` on the
     outer join, so both sides' already-narrowed columns survive.
  2. Numeric `columns` indices were resolved to names *inside* `merge_household_var()`,
     but that reassignment is local to the function and never propagates back to the
     caller's own `columns` variable — so the post-merge `select()` in
     `read_population()`/`read_mortality()`/`read_emigration()` re-applied the
     *original* (now out-of-range) indices against the narrower merged result. Fixed by
     resolving numeric indices in each of the three callers, before calling the merge.
- **`duckdb::dbExecute()` does not exist** (confirmed by the CRAN reviewer, re-confirmed
  by hitting the actual error) — implemented with `dbSendQuery()` + `dbClearResult()`,
  both of which `duckdb` exports, so `DBI` never needs to move to Imports.
- **Decisions (a)-(c) implemented as recommended**: mortality/emigration `compute()` the
  merge result back to a `Table`; `merge_households` sits at the end of
  `read_population()`'s signature; `columns` is required when `merge_households = TRUE`
  on `read_population()`, checked and erroring before any download.
- **Decision (d) simplified**: since `columns` is now required, the pathological
  full-width write the writer-tuning sweep was fighting no longer arises in normal use.
  Implemented as a flat `memory_limit = '4GB'`, `preserve_insertion_order = false`, and
  `threads = 2` only when `_R_CHECK_LIMIT_CORES_` is set.
- **Decision (e) not implemented**: no opt-in CI workflow was added — that is a change to
  shared CI infrastructure and was flagged rather than made unilaterally. Merge
  correctness was instead verified manually this session for all three supported years
  (1970, 2000, 2010): exact row-count preservation, non-zero match rate, label
  preservation under `add_labels = 'pt'`, correct column set/order under `columns=`,
  numeric-index equivalence, `cache` forwarding, and `read_mortality()`'s `Table` return
  type/`$`-accessor. New tests were added to `test_read_population.R` gated the same way
  as the rest of the suite (`skip_on_cran()`), so they run under `NOT_CRAN = "true"`.
- **Decision (f) left out of scope**, as originally suggested — no temp-file reuse across
  repeated calls in the same session.
- **`R CMD check --as-cran` result: 0 errors, 0 warnings, 0 notes**, in both the
  CRAN-mode (`NOT_CRAN=false`) and full (`NOT_CRAN=true`, examples+tests+vignettes) runs.

### Post-implementation fix (user-reported)

The user caught that the initial implementation resolved numeric `columns` indices to
names inside `merge_household_var()` (and its three callers), even though the documented
type of `columns` (`man/roxygen/templates/columns.R`) is "String" — a vector of column
*names*. Numeric-index support is real but undocumented pre-existing behaviour elsewhere
in the package (`dplyr::all_of()` happens to accept it, see `MEMORY.md`'s `[LEARN:api]`
entry on the topic); extending it into the new merge path added three near-duplicated
resolution blocks for something outside the documented contract.

**Fix**: `merge_households = TRUE` now requires `columns` to be a character vector.
Numeric input is rejected with a new informative error
(`error_merge_households_columns_character()` in `R/utils.R`), checked before any
download in all three callers (`read_population()` always, `read_mortality()`/
`read_emigration()` only when `columns` is supplied, since it stays optional there). The
numeric-resolution code was deleted from `merge_household_var()` and all three callers;
`merge_household_var()`'s `@param columns` now documents that it only accepts a
character vector or `NULL`. Tests updated: `test_read_population.R`'s numeric-index test
now asserts an error instead of success, and `test_read_mortality.R`/
`test_read_emigration.R` each gained a one-line check for the new guard.
`R CMD check --as-cran` re-run clean (0/0/0) after the fix.

### Post-implementation fix #2: `columns` is character-only package-wide (user-reported)

The first fix scoped the character-only requirement to `merge_households = TRUE`. The
user then pointed out this was too narrow: `columns` is documented as "String" for
**every** reader, with or without `merge_households`, and gave a concrete failing
example with no `merge_households` involved at all --
`read_emigration(year = 2010, showProgress = T, columns = c(1, 3))` -- which the
merge-scoped fix did not catch, since `read_emigration()`'s base `columns` handling
(`checkmate::assert_vector(columns, null.ok = TRUE)`) still silently accepted numeric
indices, a pre-existing, undocumented behaviour across all five readers (see
`MEMORY.md`'s `[LEARN:api]` entry on the topic, now updated).

**Fix**: `checkmate::assert_vector(columns, null.ok = TRUE)` → `assert_character(columns,
null.ok = TRUE)` in all five readers (`read_population()`, `read_households()`,
`read_families()`, `read_mortality()`, `read_emigration()`), enforced at function entry
before any download. This also made the merge-specific character checks from Fix #1
unreachable, so they (and `error_merge_households_columns_character()`) were removed as
dead code -- `error_merge_households_needs_columns()` (the "columns is required" check)
stays, since `columns = NULL` is still a valid character-or-`NULL` value that
`merge_households = TRUE` on `read_population()` specifically disallows. Each reader's
post-Select block also simplified: the `if (is.character(columns))` branch around the
absent-column check is now always true when `columns` is non-`NULL`, so it was removed
(five files, same pattern each time). Tests: a general `columns = c(1, 3)` → "character"
error check added to all five `test_read_*.R` files' error blocks (matching the user's
exact example for emigration). `R CMD check --as-cran` re-run clean (0/0/0) after this
fix too.
