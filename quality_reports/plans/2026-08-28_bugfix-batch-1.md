# Plan — Bugfix batch 1 (four one-liners)

**Status:** COMPLETED 2026-08-28 — adversarial review applied (test for #1 replaced; NEWS/DESCRIPTION steps dropped as wrong; single check instead of four)
**Date:** 2026-08-28
**Scope:** Four independent bugs, each fixed, tested, and given a `NEWS.md` bullet before moving to
the next. Baseline to preserve: `R CMD check --as-cran` = 0/0/0.

---

## Fix #1 — `cache = FALSE` fails on a fresh install

**Bug.** `R/utils.R:23` creates the cache directory only when `cache = TRUE`, but `local_file`
(`:27`) points into that directory either way. On a first-ever call with `cache = FALSE` the
directory is absent, `curl::multi_download` cannot write there (verified: returns
`success = FALSE`, error column `"Failure writing output to destination"`), and `:48-53` reports
*"Local file seems to be corrupted. Please download it again using `cache = FALSE`"* — advice that
causes the failure.

**Why there is no design intent to preserve.** `cache = FALSE` never meant "do not write to disk":
- `man/roxygen/templates/cache.R` — *"the function will download the data again and **overwrite the
  local file**"*
- `R/utils.R:133` (the `cache = FALSE` message) — *"File will be stored locally at: {dir_name}"*

**Change** — `R/utils.R:23`:
```diff
- if (isTRUE(cache) & !dir.exists(cache_dir)) { dir.create(cache_dir, recursive=TRUE) }
+ if (!dir.exists(cache_dir)) { dir.create(cache_dir, recursive=TRUE) }
```

**CRAN.** Same `tools::R_user_dir("censobr", "cache")` path already written under `cache = TRUE`,
which is what `R_user_dir` exists for. Write is user-initiated. No behaviour change for
`cache = TRUE`.

**Rejected:** routing `cache = FALSE` to `tempdir()` — contradicts both doc strings above, breaks
`resume = cache` (`:43`), and makes the "stored locally at" message false.

**Test.** `tests/testthat/test_z_censobr_cache.R` runs after the cache already exists, so it cannot
catch this. Needs a genuinely empty cache root:
```r
withr::with_tempdir({
  set_censobr_cache_dir(path = getwd(), verbose = FALSE)
  df <- read_families(year = 2000, cache = FALSE, showProgress = FALSE, verbose = FALSE)
  expect_s3_class(df, "Dataset")
})
```
`read_families()` is the probe — one year only, smaller file. Needs `skip_on_cran()` +
`skip_if_offline()`. **Restore the cache dir afterwards** so later tests are unaffected.

---

## Fix #2 — unsupported `add_labels` silently returns unlabelled data

**Bug.** `checkmate::assert_string(add_labels, pattern = 'pt')` is a **regex** match, so `"ptbr"`
passes. The labeller's own guard (`add_labels_population.R:27`, `lang == 'pt'`) is then FALSE, the
recode block is skipped, and an unlabelled Dataset is returned with **no error and no warning**.
This is the only bug in this batch that yields wrong output rather than a failure.

**Change** — 5 sites, one line each: `read_population.R:42`, `read_households.R:42`,
`read_families.R:40`, `read_mortality.R:49`, `read_emigration.R:49`:
```diff
- checkmate::assert_string(add_labels, pattern = 'pt', null.ok = TRUE)
+ checkmate::assert_choice(add_labels, choices = 'pt', null.ok = TRUE)
```
Verified against checkmate 2.3.4: `NULL` passes, `"pt"` passes, `"ptbr"` aborts with
*"Must be element of set {'pt'}"*.

**Open question for the reviewer.** The five `add_labels_*.R:8` helpers carry the same loose
`assert_string(lang, pattern = 'pt', na.ok = TRUE)`. They are internal and only reachable through
the readers. Tightening them too is 5 more lines for defence in depth; leaving them is lower
intervention. **Recommend leaving them** — the reader is the user-facing boundary.

**Test.** `expect_error(read_population(2010, add_labels = "ptbr"), "element of set")` — no network
needed, the assert fires before the download.

---

## Fix #4 — `read_tracts()` reports the wrong dataset list for 2000

**Bug.** `R/read_tracts.R:91-92` — the `year == 2000` branch validates against `data_sets_2000` but
its error message reports `data_sets_2010`. A user given a bad `dataset` for 2000 is told about
`DomicilioRenda` / `PessoaRenda` / `Entorno` (absent in 2000) and not told about `Instrucao` /
`Morador` (present).

**Change** — `R/read_tracts.R:92`:
```diff
- error_missing_datasets(data_sets_2010)
+ error_missing_datasets(data_sets_2000)
```

**Test.** `expect_error(read_tracts(2000, dataset = "nonsense"), "Instrucao")` — no network needed.

---

## Fix #6 — `censobr_cache(delete_file = "all", print_tree = TRUE)` errors

**Bug.** `R/cache.R:205` deletes the cache directory; `:230` then calls `fs::dir_tree(cache_dir)` on
the now-missing path and errors. Only triggers with `list_files = TRUE` (default) +
`print_tree = TRUE` + `delete_file = "all"`.

**Change** — `R/cache.R:229-231`, guard the walk:
```diff
- if(isTRUE(print_tree)){
+ if(isTRUE(print_tree) & dir.exists(cache_dir)){
    fs::dir_tree(cache_dir)
  }
```

**Alternatives for the reviewer to weigh:**
- (a) `return(invisible(NULL))` right after the delete — arguably cleaner intent, but changes the
  function's exit path and skips the "Files currently cached:" line.
- (b) Recreate the directory after deleting — restores the invariant that the cache dir exists, but
  writes to disk as a side effect of a *delete* call.
- (c) The guard above — smallest diff, no behaviour change in any other path.

**Recommend (c).** Note `message(paste0(fs::path(files), collapse = '\n'))` at `:225` already
degrades gracefully to an empty line when `files` is empty, so the non-tree path needs no change.

**Test.** No network needed — point the cache dir at a temp dir, touch a dummy file, then call with
`delete_file = "all", print_tree = TRUE` and assert no error.

---

## Per-bug loop

For each fix, in order #1 → #2 → #4 → #6:
1. Apply the change.
2. Add the regression test.
3. Run the targeted test file; then `R CMD check --as-cran` offline-reduced
   (`_R_CHECK_CRAN_INCOMING_=FALSE _R_CHECK_FORCE_SUGGESTS_=FALSE`, per MEMORY.md).
4. Add a `NEWS.md` bullet under a new `# censobr v0.6.0.9000` dev heading.
5. Only then move to the next bug.

**Not doing:** version bump in `DESCRIPTION` beyond the dev suffix, or a CRAN submission.

## Verification

- Targeted: `devtools::test(filter = ...)` per fix.
- Full: `R CMD check --as-cran` at the end of the batch — must stay 0 errors / 0 warnings, with
  vignette WARNINGs only if the build was vignette-reduced.
- `git diff --stat` must show only the four `R/` files, their tests, and `NEWS.md`.
