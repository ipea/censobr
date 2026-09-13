# Plan — `R CMD check` after bumping the data release to v0.7.0

**Status:** DRAFT
**Date:** 2026-09-12
**Command:** `devtools::check(pkg = ".", cran = FALSE, env_vars = c(NOT_CRAN = "true"))`
**Result:** `1 error ✖ | 0 warnings ✔ | 0 notes ✔`

---

## What passed

`v0.7.0` is now published on `ipea/censobr_prep_data` (42 assets, all resolving),
so the earlier build-gate failure is gone. Every check step returned OK except
`checking tests`:

- `creating vignettes ... OK` — all 5 vignettes built (and re-built) successfully
- `checking examples ... OK` — every `@examplesIf NOT_CRAN` example downloaded fine
- `checking for missing documentation entries ... OK`
- `checking for code/documentation mismatches ... OK` — `man/` is in sync

Test totals: **FAIL 13 | WARN 13 | SKIP 0 | PASS 569**

---

## The one ERROR: `checking tests` — 13 failures, 2 clusters, 1 root cause

### Root cause: the `.publico` fallback is incomplete

`R/utils.R:147-166`:

```r
if (year == 2022) {
  file_name <- gsub("_v", ".controlado_v", file_name)
  local_file <- fs::path(get_censobr_cache_dir(),
                         paste0("data_release_", censobr_env$data_release),
                         file_name)

  if (isFALSE(file.exists(local_file))) {
    warning_microdata22_not_imported(call = rlang::caller_env())
    file_name <- gsub(".controlado", ".publico", file_name)   # computed...
  }

  return(arrow_open_dataset(local_file))   # ...and discarded: still the OLD path
}
```

Two defects:

1. `file_name` is reassigned to `.publico` but **`local_file` is never rebuilt**.
2. The branch **`return()`s before `download_file()`**, so nothing is ever downloaded.

The public files now exist and are exactly what this fallback was written for:

```
2022_population.publico_v0.7.0.parquet   (639 MB)
2022_households.publico_v0.7.0.parquet
2022_families.publico_v0.7.0.parquet
2022_mortality.publico_v0.7.0.parquet
```

Observed behaviour today (`read_population(2022)`, empty cache):

```
[warning] You are currently using the public version of the 2022 census microdata...
✖ The file cached locally seems to be corrupted, and has been removed.
returns: NULL
```

Nothing was cached and nothing is corrupt — it reports a missing `.controlado`
file while the `.publico` file sits published and untouched.

### Cluster A — 12 failures

`test_import_microdata22_controlado.R:297`, `:298`, `:299` × 4 readers
(`read_population`, `read_households`, `read_families`, `read_mortality`).

```
Expected `f(year = 2022)` to throw a error.
```

The test asserts the **pre-fallback contract**:

```r
testthat::expect_error(f(year = 2022), "not distributed")
testthat::expect_error(f(year = 2022), "import")
testthat::expect_error(f(year = 2022), "microdados.ibge.gov.br")
```

Its stated premise — *"an empty cache is not something a download can fix"* —
stopped being true when the public files were published. The code now warns and
falls back; the test still expects an abort. **The test is obsolete by design,
not broken.**

### Cluster B — 1 error

`test_labels_population.R:40`

```
Error in `UseMethod("filter")`: no applicable method for 'filter' applied to an object of class "NULL"
```

`read_population(year = 2022, columns = c('abbrev_state','P0120'))` returns
`NULL` (root cause above), which is then piped into `dplyr::filter()`.

**This test needs no change** — it passes as soon as the fallback works.
Verified by reading the public file's Parquet footer via an HTTP range request:
`P0120` and `abbrev_state` are both present.

---

## Fix plan

### Fix 1 — make the fallback real (`R/utils.R`, 2022 branch)

Short-circuit **only** when the controlled file is actually in the cache;
otherwise warn and let execution fall through to the existing download path.

```r
if (year == 2022) {
  file_name <- gsub("_v", ".controlado_v", file_name, fixed = TRUE)
  local_file <- fs::path(get_censobr_cache_dir(),
                         paste0("data_release_", censobr_env$data_release),
                         file_name)

  # controlled data is cache-only: censobr may not redistribute it
  if (file.exists(local_file)) return(arrow_open_dataset(local_file))

  warning_microdata22_not_imported(call = rlang::caller_env())
  file_name <- gsub(".controlado", ".publico", file_name, fixed = TRUE)
  # no return(): fall through to file_url / download_file() below
}
```

Also: both `gsub()` calls need `fixed = TRUE` (`.` is a regex wildcard, and
`"_v"` is unanchored). Building the name from parts would be sturdier still.

### Fix 2 — rewrite the obsolete test block (`test_import_microdata22_controlado.R:290-305`)

Assert the new contract: a **warning**, not an error, and real data back.

```r
for (f in list(read_population, read_households, read_families, read_mortality)) {
  testthat::expect_warning(f(year = 2022), "public version")
  testthat::expect_warning(f(year = 2022), "microdados.ibge.gov.br")
}

w <- rlang::catch_cnd(read_population(year = 2022))
testthat::expect_s3_class(w, "warning")
testthat::expect_match(deparse(conditionCall(w))[1], "read_population")
```

**Cost warning:** this test would now download the public files (639 MB for
population alone) on every run. Recommend keeping `skip_on_cran()` and asserting
the warning against a single reader rather than all four, or mocking the
download as `test_zz_graceful_failure.R` already does with httr2.

### Fix 3 — no action (`test_labels_population.R`)

Passes once Fix 1 lands.

---

## Secondary issues (not check failures, worth fixing)

1. **Misleading message.** `arrow_open_dataset()` reports *"The file cached
   locally seems to be corrupted, and has been removed"* for a file that never
   existed. Missing and corrupt should be distinguished.
2. **13 WARN in the suite.** These are the (now correctly signalled) `cli_warn`
   warnings. Tests should assert them explicitly rather than let them accumulate.
3. **3 labelled variables absent from the public file** — `P0160`, `P1030`,
   `P1040` (public has 100 `P####` columns vs 210 controlled; 76 of the 79
   labelled variables present). The labeller's `if ('P0160' %in% cols)` guards
   handle this gracefully — no action, but worth knowing that
   `add_labels = "pt"` on public data silently labels less.
4. **CLAUDE.md drift.** (a) `download_file()` is documented as
   `curl::multi_download()` with a 5000-byte size check; it now uses **httr2**
   (`req_perform()` + `download_is_incomplete()`). (b) The data-release contract
   section should document the new `.controlado` / `.publico` filename infixes.

---

## Verification

- [ ] `devtools::check(pkg = ".", cran = FALSE, env_vars = c(NOT_CRAN = "true"))` → 0 errors
- [ ] `devtools::check(pkg = ".", cran = TRUE,  env_vars = c(NOT_CRAN = "false"))` → 0/0, notes justified
- [ ] `read_population(2022)` on an empty cache warns once and returns a Dataset
- [ ] `read_population(2022)` with imported controlled data returns the controlled Dataset, no warning
