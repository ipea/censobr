# Plan — Bugfix batch 2

**Status:** COMPLETED 2026-08-28 — adversarial review applied: **B1 DROPPED** (motivation was false: only 2 of 17 test calls use verbose=FALSE, and gating contradicts the documented @return); **A1 message text corrected** (branch 2 is a truncated fresh download, not local corruption); **B2 required devtools::document()** or the check would have raised a code/documentation mismatch; **B3 deferred** (waldo/expect_equal risk under 3e).
**Date:** 2026-08-28
**Baseline to preserve:** full suite green (`NOT_CRAN=true`), `R CMD check --as-cran` 0 errors / 0 notes.

Split deliberately: **Group A** is unambiguous bug fixing. **Group B** changes the signature or
observable behaviour of exported functions and needs a back-compat judgement.

---

# Group A — unambiguous

## A1 — `download_file()` failure messages are swapped

**Bug.** `R/utils.R:48-63`. Branch 1 fires when the *transfer/write* failed
(`any(!downloaded_files$success)`) and says *"Local file seems to be corrupted. Please download it
again using `cache = FALSE`"*. Branch 2 fires when the file is **missing or under 5000 bytes** — i.e.
actually truncated/corrupt — and says *"Internet connection not working properly."* Each branch
prints the other's diagnosis. This is what made batch-1 #1 so confusing: a write failure recommended
`cache = FALSE`, which was the cause.

**Change** — swap the two messages, keeping the `delete_file` remedy with the corrupt-file branch:

```diff
  if (any(!downloaded_files$success | is.na(downloaded_files$success))) {
-       msg <- paste(
-       "Local file seems to be corrupted. Please download it again using 'cache = FALSE'.",
-       sprintf("Alternatively, ... censobr_cache(delete_file = \"%s\")'", basename(local_file)),
-       sep = "\n")
-       cli::cli_alert_danger(msg)
+       cli::cli_alert_danger("Download failed. Please check your internet connection and try again.")
        return(invisible(NULL))
        }

  if (!file.exists(local_file) | file.info(local_file)$size < 5000) {
-   cli::cli_alert_danger("Internet connection not working properly.")
+   msg <- paste(
+     "Local file seems to be corrupted. Please download it again using 'cache = FALSE'.",
+     sprintf("Alternatively, you can remove the corrupted file with 'censobr::censobr_cache(delete_file = \"%s\")'", basename(local_file)),
+     sep = "\n")
+   cli::cli_alert_danger(msg)
    return(invisible(NULL))
  }
```

**Test.** The batch-1 test at `test_z_censobr_cache.R` already drives branch 1 via an unreachable
URL. Extend it to assert the message no longer says "corrupted":
`expect_message(..., "internet")` is fragile against `cli` formatting — prefer asserting the return
is `NULL` (already done) and leave message text untested. **Recommend no new test.**

## A2 — `censobr_cache()` errors on an empty cache when `verbose = FALSE`

**Bug.** `R/cache.R:169-174`. The `length(files) == 0` early return is nested **inside**
`if (isTRUE(verbose))`. With `verbose = FALSE` and an empty or absent cache dir, execution falls
through; `delete_file = "all"` then reaches `fs::dir_delete()` at `:205` on a missing directory and
throws ENOENT. Found by the batch-1 reviewer; same function and class as batch-1 #6.

**Change** — hoist the early return out of the verbose guard:

```diff
- if (isTRUE(verbose)) {
-   if (length(files)==0) {
-     cli::cli_alert_info("Cache directory is currently empty.")
-     return(character(0))
-   }
- }
+ if (length(files)==0) {
+   if (isTRUE(verbose)) { cli::cli_alert_info("Cache directory is currently empty.") }
+   return(character(0))
+ }
```

Also removes the `dir_delete`-on-missing-dir path entirely, since an empty cache now returns before
reaching it. Behaviour with `verbose = TRUE` is unchanged.

**Test.** No network. Point the cache dir at an empty temp dir and assert
`expect_no_error(censobr_cache(delete_file = "all", verbose = FALSE))`.

---

# Group B — behaviour changes, need a judgement call

## B1 — `questionnaire()` / `interview_manual()` ignore `verbose`

**Bug.** v0.6.0 fixed `data_dictionary()` to only open the file when `verbose = TRUE`
(`R/data_dictionary.R:107`, closing issue #72). The same fix was never applied to the two sibling
docs functions: `R/docs_questionnaire.R:72` and `R/docs_interview_manual.R:56` call
`utils::browseURL()` unconditionally.

**Evidence this is a real gap, not a design choice:** `tests/testthat/test_docs_interview_manual.R:19`
already asserts `expect_no_message(interview_manual(year = 1970, verbose = FALSE))` — the test
passes today because `cache_message()` *is* gated, while the PDF still opens. So `verbose = FALSE`
already means "be quiet" for these functions; opening a browser window is the loudest thing they do.
Side effect worth noting: running the suite currently opens ~7 PDF windows.

**Change** — 2 sites, mirroring `data_dictionary.R:107`:
```diff
- utils::browseURL(url = local_file)
+ if (isTRUE(verbose)) { utils::browseURL(url = local_file) }
```

**Back-compat.** A caller relying on `verbose = FALSE` *and* still wanting the file to open would
break. That combination is incoherent, and `data_dictionary()` already behaves the new way, so the
inconsistency is the bug. **Recommend proceeding.**

**Test.** Existing `expect_no_message(... verbose = FALSE)` lines become meaningful. Optionally add
the same to `test_docs_questionnaire.R`.

## B2 — two defaults that cannot work

**Bug.** `interview_manual(year = NULL)` → `checkmate::assert_numeric(year)` with no `null.ok`
aborts. `questionnaire(type = NULL)` → `checkmate::assert_string(type)` aborts. Calling either
function with its own documented default fails.

**Change** — drop the impossible defaults, making the arguments required:
```diff
- interview_manual <- function(year = NULL,
+ interview_manual <- function(year,

- questionnaire <- function(year = 2010, type = NULL,
+ questionnaire <- function(year = 2010, type,
```

**Back-compat: none broken.** Any call that worked before either passed the argument (unchanged) or
relied on the default (which already errored). The error message improves from a `checkmate` type
complaint to R's *"argument "year" is missing, with no default"*.

**Consistency question — NOT proposed here.** `NEWS.md:40` (v0.5.0) records *"The `year` parameter
no longer defaults to `2010`"*, and all seven `read_*` / `data_dictionary` functions take `year` with
no default. `questionnaire(year = 2010)` is the lone survivor of the old convention. Removing it
would align the API but **is** a genuine breaking change for `questionnaire(type = "long")`.
Flagging for the user; not changing.

## B3 — `Config/testthat/edition: 3` is not a one-liner

**Finding that changes scope.** Adding the field alone would emit deprecation warnings across the
whole suite. Verified under testthat 3.3.2:
- `context()` → *"`context()` was deprecated in the 3rd edition"* — used in **all 16** test files, line 1
- `expect_is()` → *"deprecated in the 3rd edition"* — `test_z_censobr_cache.R:65`

**Change** — 18 lines: add `Config/testthat/edition: 3` to `DESCRIPTION`, delete the 16 `context()`
calls, and replace the one `expect_is(temp, "character")` with `expect_type(temp, "character")`.

**Reviewer question:** is this worth doing now, or is it churn better left to a dedicated commit?
The suite is already written in 3e style otherwise. **Recommend deferring** unless the reviewer
disagrees — it touches every test file and gains nothing behavioural.

---

## Execution

Per the batch-1 lesson: apply all agreed changes, run `devtools::test()` once with `NOT_CRAN=true`,
then **one** `R CMD check --as-cran`. NEWS bullets appended to the existing `# censobr dev` section
in the established style. No `DESCRIPTION` version bump (already `0.6.0.999`).
