# Plan — `add_labels_*()` vs. the v0.7.0 retype (character → integer)

**Status:** COMPLETED (not committed) — see
`quality_reports/session_logs/2026-09-14_add-labels-v070-retype.md` for the verification results
**Date:** 2026-09-14
**Branch:** dev

---

## Context

The `ipea/censobr_prep_data` **v0.7.0** release assets were re-uploaded today
(every asset `updated_at` between `2026-09-14T08:26Z` and `08:40Z`). The re-release changed the
*storage types* of the microdata: virtually every categorical column that used to be `string` is
now `int32` (a few became `double`).

Verified without downloading the data: for all 34 microdata assets (15 in v0.6.0, 19 in v0.7.0) the
parquet footer was fetched with two HTTP range requests and opened with `arrow` — schemas saved in
the scratchpad. Result, per file, of *what is still `string` in v0.7.0*:

| file | remaining `string` columns |
|---|---|
| 1960 pop/hh | `name_region`, `abbrev_state`, `name_state`, `name_muni`, `censobr_diag_*_vars` |
| 1970–2010, all datasets | `name_region`, `abbrev_state`, `name_state` only |
| 2000 population | + `M4522`, `M4621`, `M4622`, `M4671`, `M4672` (these went **int32 → string**) |
| 2022 families / mortality | + `F0101`, `M0101` (ids, by design) |

**Nothing that `add_labels_*()` labels is a string any more.** Representative deltas:
`2010_population`: 237 columns changed type, e.g. `V0601 string→int32`, `V1006 string→int32`,
`V0011 string→double`; `1980_population`: 96 changes; `1991_households`: 54; `2000_households`: 61.

### Why this breaks the package

The 1980 / 1991 / 2000 / 2010 label blocks compare against **quoted** codes
(`V0601 == '1'`). Against an `int32` column, Arrow has no kernel for that comparison, so:

* on an arrow **`Dataset`** (what `read_*()` returns by default) it is a **hard error**:
  `Expression not supported in Arrow → Call collect() first to pull data into R.`
* on an in-memory **`Table`** it silently **pulls the whole dataset into R** — the exact opposite of
  the package's larger-than-memory promise.

Reproduced live against the real new file (`2010_emigration_v0.7.0.parquet`, downloaded):
`add_labels_emigration(ds, year = 2010, lang = 'pt')` → `Error: Expression not supported in Arrow`.

So `read_population/households/families/mortality/emigration(add_labels = "pt")` is **broken for
1980, 1991, 2000 and 2010** once the pin points at v0.7.0 (`R/onLoad.R:7` already says `v0.7.0`).
The **1960, 1970 and 2022** blocks already use numeric literals and are unaffected — they were
written against numeric data.

### Intended outcome

`add_labels = "pt"` works again for every year, with all comparisons evaluated natively inside
Arrow (no silent `collect()`), and a network-free regression test that would have caught this.

---

## The change

Rewrite every quoted numeric literal in the label files as a numeric literal, stripping leading
zeros — the style the 1960/1970/2022 blocks already use.

```r
V0601 == '1'   →   V0601 == 1
V0402 == '01'  →   V0402 == 1
V4002 == '64'  →   V4002 == 64
.x %in% c('0', '2')  →  .x %in% c(0, 2)      # R/add_labels_population.R:1591
```

Left untouched: `lang == 'pt'`, the `'V0601' %in% cols` guards, and every label string on the
right-hand side of `~`.

### Files and blocks in scope

| file | blocks to rewrite | quoted comparisons |
|---|---|---|
| `R/add_labels_population.R` | ALL-YEARS (`V1006`), 2010, 2000, 1980, 1991 | ~1,645 |
| `R/add_labels_households.R` | ALL-YEARS (`V1006`), 2010, 2000, 1980, 1991 | ~422 |
| `R/add_labels_emigration.R` | 2010 | 208 |
| `R/add_labels_families.R` | 2000 | 133 |
| `R/add_labels_mortality.R` | 2010 | 26 |

≈ **2,434 comparisons over ~200 variables**. Every one of those variables was confirmed numeric in
the v0.7.0 schemas, so the rewrite is unconditional within those blocks — no per-variable exceptions.

Method: a scripted regex pass (`== *'0*([0-9]+)'` → `== \1`, applied only inside the listed blocks),
then a manual read of the diff, paying attention to (a) the ~179 zero-padded literals, where
`'01' → 1` is the substantive change, and (b) the handful of comparisons that wrap across two lines
(`V4001 ==\n  '02' ~`), which get re-joined onto one line.

---

## Also in scope (found while auditing)

1. **Tests that assert on raw codes as strings.** Two will now fail outright because the code is
   zero-padded: `tests/testthat/test_labels_families.R:28` (`'01' %in% test1a$CODV0404_2`) and
   `test_labels_households.R:39` (`'01' %in% test1c$V4001`). Six more (`'1' %in% test1a$V1006`,
   `sum(test2a$V3061 == '8000826')`, …) still pass only because `%in%`/`==` coerce int to character.
   All of them get numeric literals.

2. **A new network-free regression test** — `tests/testthat/test_labels_types.R`: build a one-row
   arrow `Table` from each v0.7.0 schema shape (int columns), run every `add_labels_*()` year block
   over it, and assert (a) no error and (b) `query$.data` stays an Arrow query — i.e. the expression
   never fell back to R. This is the guard that was missing; it costs no download and would have
   failed the day the types changed.

3. **Stale comments.** `R/add_labels_population.R:2312` and `R/add_labels_households.R:1059` say
   *"The 1960 microdata carry no abbrev_state/name_state columns, so the state code is labelled
   here"* — v0.7.0 1960 files now ship `code_region`, `name_region`, `code_state`, `abbrev_state`,
   `name_state`, `name_muni`. The `uf` labelling stays (it is the 1960 territorial division, not
   today's UF list), but the justification is rewritten.

4. **`NEWS.md`** — a dev-section entry: labels fixed for the v0.7.0 microdata retype.

### Flagged, no code change

* `2000_population` `M4522`, `M4621`, `M4622`, `M4671`, `M4672` went **int32 → string**. Not
  referenced by any labeller (only by `R/import_microdata22_controlado.R` docs), so nothing to do.
* Column-set changes, all harmless because every block is guarded by `%in% cols`: 1980 dropped
  `Observation`; 1991 population gained `numb_family_members`, `family_income_per_cap`; 1970
  households gained `numb_residents`, `numb_families`; 1960 gained the six geography columns above.
* The local cache at `.../R/cache/R/censobr/data_release_v0.7.0` holds files downloaded **Sep 13**,
  i.e. *before* today's re-upload — including tracts. A cache hit is never re-validated
  (`R/utils.R:33-35`), so those must be deleted before any verification run, or the old schema comes
  back. The tracts files are stale for the same reason and should be refreshed at some point.

---

## Execution phases (check-in mode: pause and report at each boundary)

**Phase 1 — clear the stale cache.** Delete the pre-re-upload microdata parquets under
`data_release_v0.7.0` so the sweep downloads the real new files.

**Phase 2 — rewrite the literals.** Scripted pass over the five files, block-scoped; then read the
full diff. `devtools::document()` is not needed (no roxygen touched); `devtools::load_all()` to
confirm it parses.

**Phase 3 — tests, comments, NEWS.** Items 1–4 above.

**Phase 4 — full real-data verification sweep** (user-selected). For each of the 19 microdata
datasets — population and households for 1960/1970/1980/1991/2000/2010/2022, families 2000/2022,
mortality 2010/2022, emigration 2010 (≈4–5 GB, downloaded through `read_*()` into the normal cache)
— run a script that:
   * reads with `add_labels = NULL` and with `add_labels = "pt"`, both as Datasets (so any Arrow
     type error surfaces rather than being masked by a `collect()`);
   * for every variable the year block touches, compares the raw code distribution with the labelled
     one and reports: variables that came back **all-NA** (map missed the codes — the signature of a
     leading-zero mistake), and raw codes present in the data with **no label** (pre-existing gaps,
     reported but not necessarily fixed here);
   * writes the report to `quality_reports/` so the coverage table survives the session.

**Phase 5 — the gate.** `devtools::check(pkg = ".", cran = FALSE, env_vars = c(NOT_CRAN = "true"))`
(runs examples/tests/vignettes), then `devtools::check(cran = TRUE, NOT_CRAN = "false")` for the
CRAN-policy pass. Bar: 0 errors / 0 warnings, every NOTE already justified in `cran-comments.md`.

**Not in this plan:** committing (needs an explicit `/commit`), and the data-release pin — already
at `v0.7.0` in `R/onLoad.R:7`.
