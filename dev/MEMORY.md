# Project Memory — censobr

Corrections and learned facts that persist across sessions for
**censobr**. When a mistake is corrected, or a non-obvious approach is
confirmed, append a `[LEARN:category]` entry below. Most recent at the
bottom.

> The workflow template’s own development history (inherited when
> `.claude/` was vendored into this repo) was removed on 2026-08-27 — it
> documented the Beamer/Quarto template, not censobr. It remains
> available in `R:\Dropbox\git\claude-code-my-workflow` (`MEMORY.md`),
> which has a GitHub remote, so nothing was lost.

------------------------------------------------------------------------

## Package architecture

\[LEARN:data-release\] `R/onLoad.R:7` (`censobr_env$data_release`) is a
**single pin** that does two jobs: it builds the download URL for all
six `read_*()` functions, and it versions the cache directory
(`R/utils.R:22` → `{cache_dir}/data_release_{tag}`). **Bumping it
silently invalidates every user’s cache and forces a full re-download.**
Treat it as a deliberate release decision with a `NEWS.md` entry — never
a drive-by edit. Package version and data release are independent
decisions that merely happen to both read `v0.6.0` today.

\[LEARN:data-release\] The three documentation functions
([`data_dictionary()`](https://ipeagit.github.io/censobr/dev/reference/data_dictionary.md),
[`questionnaire()`](https://ipeagit.github.io/censobr/dev/reference/questionnaire.md),
[`interview_manual()`](https://ipeagit.github.io/censobr/dev/reference/interview_manual.md))
use a **fixed** release tag `censo_docs`, *not* the data-release pin.
This looks like an inconsistency but is correct — documentation is not
re-released per data version. Do not “unify” it with the pin.

\[LEARN:cache\]
[`censobr_cache()`](https://ipeagit.github.io/censobr/dev/reference/censobr_cache.md)
deliberately lists files recursively from the cache **root**, not from
the versioned subdirectory — the versioning line at `R/cache.R:162` is
commented out on purpose. This lets users see and delete files left
behind by *older* data releases. Uncommenting it would hide exactly the
files users most need to clean up.

\[LEARN:arrow\] `read_*()` returning an arrow `Dataset`
(`as_data_frame = FALSE`) is the package’s core promise, not a default
worth tuning. Never change it, and never introduce a step that silently
`collect()`s into memory — that would break the larger-than-memory
guarantee the package is built on.

\[LEARN:drift\] Year availability is hard-coded as `years <- c(...)` in
**9 separate files** with genuinely different sets per dataset. There is
no shared constant. Any change to supported years must touch every
relevant copy — the reference table is in
[CLAUDE.md](https://ipeagit.github.io/censobr/dev/CLAUDE.md).

------------------------------------------------------------------------

## Known defects (logged 2026-08-27, not yet fixed)

\[LEARN:defect\] **FIXED 2026-08-28.** `R/read_tracts.R:91-92` — the
`year == 2000` branch validates against `data_sets_2000` but its error
message reports `data_sets_2010`. A user passing an invalid `dataset`
for 2000 is told about `DomicilioRenda`/`PessoaRenda`/`Entorno` (not
available in 2000) and is *not* told about `Instrucao`/`Morador` (which
are). One-word fix: `error_missing_datasets(data_sets_2000)`.

\[LEARN:org\] **RESOLVED 2026-08-27 — `ipea` is canonical; `ipeaGIT`
redirects.** `DESCRIPTION` was already correct; the stale one was the
git remote, now `https://github.com/ipea/censobr`. All 8 `ipeaGIT/`
mentions across the repo were replaced.

\[LEARN:org\] **`r5r` has NOT migrated.** `ipea/geobr` and
`ipea/censobr` resolve, but `ipea/r5r` does **not** — only
`ipeaGIT/r5r`. A blanket `ipeaGIT/ → ipea/` replace therefore breaks the
r5r install URL (`tests/tests_rafa/test_rafa.R:66`). Verify each org
path with `git ls-remote https://github.com/<org>/<repo>` before a bulk
rename; the migration is per-repo, not org-wide.

\[LEARN:defect\] `DESCRIPTION` has no `Config/testthat/edition: 3`,
which `.claude/rules/r-package-conventions.md` requires. The suite
appears to be written in 3e style; adding the field makes it explicit
rather than incidental.

\[LEARN:defect\] **FIXED 2026-08-28** (now `assert_choice`).
`read_population(year, add_labels = "pt")` validated `add_labels` for
**any** year (`R/read_population.R:42`) but `add_labels_population()`
aborts unless `year == 2010` (`R/add_labels_population.R:9-11`). The
abort happens *after* the parquet download, so a user asking for 2000
labels waits for a large file and then gets an error. Either validate
the year/label combination up front, or widen label coverage. Same shape
is worth checking in the other `add_labels_*` helpers.

\[LEARN:pipeline\] In every `read_*()`, **column selection runs before
labelling**, and the labeller guards each recode with
`if ('VXXXX' %in% cols)` against the column list captured on entry. So a
narrow `columns =` argument silently skips labelling for the dropped
variables — no warning. Order matters if you ever refactor these steps.

------------------------------------------------------------------------

## Workflow configuration

\[LEARN:workflow\] `/commit` Steps 0 and 0b call
`scripts/quality_score.py` and `scripts/check-surface-sync.sh`, which
**do not exist here** — there is no `scripts/` directory. They came from
the Beamer/Quarto template this workflow was forked from. Skip Steps
0/0b; the real release gate is `/r-package-check`. Steps 1–7 apply
normally. Same caveat holds in flightsbr, enderecobr, and geocodebr.

\[LEARN:workflow\] Any new top-level file or directory in this repo
(`CLAUDE.md`, `MEMORY.md`, `.claude/`, `quality_reports/`, `templates/`)
**must** get an `.Rbuildignore` entry, or `R CMD check --as-cran` raises
a “Non-standard files/directories found at top level” NOTE and breaks
the 0/0/0 baseline recorded in `cran-comments.md`.

\[LEARN:workflow\] `flightsbr/.Rbuildignore` covers only three of the
five workflow patterns — it omits `^templates$` and `MEMORY.md`. If
flightsbr ever gains those files, it will pick up a CRAN NOTE. Censobr
carries the complete set; consider back-porting to the siblings.

\[LEARN:config\] When vendoring the workflow template into a package
repo, its `.claude/settings.json` brings a `hooks` block and
`defaultMode: "bypassPermissions"` that **conflict with the global
`~/.claude/settings.json`**: hook layers are additive (each hook fires
twice) and the project-level `defaultMode` overrides the global `auto`.
Strip both from the project copy and let the global settings own hooks,
permission mode, and statusline.

\[LEARN:config\] The vendored `.claude/rules/` were byte-identical to
`~/.claude/rules/` except `meta-governance.md` — copying them into a
project adds duplication, not content. What the project copy *is* good
for is pruning to the applicable subset (censobr: 7 rules / 12 skills /
4 agents) so `CLAUDE.md` can honestly document what is live.

\[LEARN:check\] Running `R CMD check --as-cran` **without network
access** halts twice unless two env vars are set:
`_R_CHECK_CRAN_INCOMING_=FALSE` (the incoming-feasibility step times out
fetching `CRAN.../PACKAGES`) and `_R_CHECK_FORCE_SUGGESTS_=FALSE`
(`geobr`, `ggplot2`, `kableExtra` are Suggests that can’t be resolved
offline). Neither indicates a package problem. Also note that piping the
check through `tail` masks its exit code — you get `tail`’s 0 even when
the check died.

\[LEARN:check\] `--no-build-vignettes` on `R CMD build` produces two
*spurious* WARNINGs on the subsequent check (“Files in the ‘vignettes’
directory but no files in ‘inst/doc’” and “Directory ‘inst/doc’ does not
exist”). They are artifacts of the reduced build, not defects. A full
vignette build downloads real census parquet files, so prefer the
reduced build for structural checks and reserve the full run for
pre-release.

\[LEARN:config\] **A path-scoped rule whose `paths:` globs match zero
files in the repo is dead weight** — it can never fire. Testing each
rule’s globs against the tree is a far better prune criterion than
judging by filename: it correctly flagged `quality-gates`,
`single-source-of-truth`, `r-code-conventions`, `replication-protocol`,
`simulation-conventions`, `knowledge-base-template`,
`exploration-folder-protocol`, and `orchestrator-research` as
unreachable here. Watch for false positives, though:
`verification-protocol` scored LIVE only via `docs/**` (gitignored
pkgdown output) while its body was entirely about rendering slides.
After the prune all 7 surviving rules are LIVE or unscoped-global.

\[LEARN:config\] Pruning `.claude/` cascades — deleting a module breaks
every cross-reference to it, including *pre-existing* broken links the
vendored copy already carried (`audit-reproducibility`,
`coauthor-brief`, `data-analysis`, `skill-template` were referenced but
never copied in). Always finish a prune with a link-resolution sweep
over `.claude/**/*.md`, not just a name grep — the grep found 23
mentions, the link check found 11 more that the grep’s pattern list
missed.

\[LEARN:check\] A stale `00LOCK-censobr` directory left by a concurrent
or interrupted R process makes `R CMD check` raise *“checking for
non-standard things in the check directory … NOTE”*. It is an
environment artifact, not a package defect - delete `censobr.Rcheck/`
and re-run before believing a new NOTE. Do not run the test suite and a
check against the same library at the same time.

\[LEARN:api\] `verbose` in the docs functions means “be quiet”, **not**
“skip the side effect”. The `@return` of
[`questionnaire()`](https://ipeagit.github.io/censobr/dev/reference/questionnaire.md)
and
[`interview_manual()`](https://ipeagit.github.io/censobr/dev/reference/interview_manual.md)
is literally “Opens a `.pdf` file on the browser”, so gating
[`browseURL()`](https://rdrr.io/r/utils/browseURL.html) on `verbose`
would make them documented no-ops.
[`data_dictionary()`](https://ipeagit.github.io/censobr/dev/reference/data_dictionary.md)
already gates (issue \#72) and is the inconsistent one. If the goal is a
quiet test suite, the correct gate is
[`interactive()`](https://rdrr.io/r/base/interactive.html) on all
three - a deliberate API decision, not a bug fix.

\[LEARN:docs\] Changing a function signature (even dropping an unusable
default) requires `devtools::document()`, because in `man/*.Rd`
hard-codes the defaults. Skipping it raises a *code/documentation
mismatch* WARNING and silently breaks the 0/0/0 baseline.

\[LEARN:api\] **Every function taking `year` must require the user to
declare it - no function may assume a year.** Enforced by
[`error_year_not_declared()`](https://ipeagit.github.io/censobr/dev/reference/error_year_not_declared.md)
(`R/utils.R`) called from a `if (missing(year) || is.null(year))` guard
in all 9 functions. Use the bare `year` signature, not `year = NULL`: a
NULL default makes advertise a default and implies NULL is meaningful,
while `missing() || is.null()` still catches both the omitted and the
explicitly-NULL call. A bare required argument alone is NOT enough -
`f(year = NULL)` sails past R’s missing-argument machinery
([`missing()`](https://rdrr.io/r/base/missing.html) is FALSE there) into
checkmate, producing a type complaint instead of a useful message.

## Session 2026-08-28 - bug fix batches 1 and 2 (committed 9110ef1, b7213eb, 10a24b9)

\[LEARN:defect\] **OPEN, and it breaks the test suite.**
`data_dictionary(2022, 'tracts')` downloads an `.xlsx` and opens it with
`open_file()` -\> `shell.exec()` (`R/data_dictionary.R:113,125`). On
Windows Excel keeps the file handle, so a later
`censobr_cache(delete_file = 'all')` in the same session fails with
`[EBUSY] Failed to remove ... 2022_dictionary_tracts.xlsx`. Observed as
2 real test failures in `test_z_censobr_cache.R` (lines 14 and 98). Not
caused by the bug fixes - it is the docs functions’ own side effect. The
fix is to gate the file-open on
[`interactive()`](https://rdrr.io/r/base/interactive.html) in all three
docs functions, so a non-interactive test run never launches Excel or a
PDF viewer. Do NOT gate on `verbose` - see the \[LEARN:api\] entry above
for why.

\[LEARN:api\] **When you make an argument required, test the *missing*
path, not just the bad-value path.** Dropping `type = NULL` from
[`questionnaire()`](https://ipeagit.github.io/censobr/dev/reference/questionnaire.md)
swapped one poor message (`Must be of type 'string', not 'NULL'`) for
another (`argument "type" is missing, with no default`) - because the
`checkmate` assert ran before the block that knew the valid options. The
fix is ordering: put an informative guard next to the option list that
already exists, then let `checkmate` run. Now handled by
`error_arg_not_declared(arg, options)` in `R/utils.R`, used by
`questionnaire(type)`, `read_tracts(dataset)` and
`data_dictionary(dataset)`;
[`read_tracts()`](https://ipeagit.github.io/censobr/dev/reference/read_tracts.md)
shows the options for the *requested year*.

\[LEARN:workflow\] The four `error_*` helpers in `R/utils.R`
(`error_arg_not_declared`, `error_year_not_declared`,
`error_missing_years`, `error_missing_datasets`) all pass
`call = rlang::caller_env()` so the error is attributed to the exported
function, not the helper. Follow that pattern for any new validation
helper.

\[LEARN:workflow\] The adversarial-review loop paid for itself twice
this session: it rejected a test that would have corrupted the suite (an
undeclared `withr` dependency plus a persistent
[`set_censobr_cache_dir()`](https://ipeagit.github.io/censobr/dev/reference/set_censobr_cache_dir.md)
config write), and it killed a proposed fix whose stated motivation I
had simply got wrong. Have the reviewer verify the *premise* of each
fix, not only its diff.

## Docs-function behaviour change (commit b9ca5ed, 2026-08-28)

\[LEARN:api\]
**[`data_dictionary()`](https://ipeagit.github.io/censobr/dev/reference/data_dictionary.md),
[`questionnaire()`](https://ipeagit.github.io/censobr/dev/reference/questionnaire.md)
and
[`interview_manual()`](https://ipeagit.github.io/censobr/dev/reference/interview_manual.md)
open the file only when `verbose = TRUE` AND
[`interactive()`](https://rdrr.io/r/base/interactive.html).** Otherwise
they return the path to the downloaded file (visibly); when the file is
opened the path is returned invisibly.
[`data_dictionary()`](https://ipeagit.github.io/censobr/dev/reference/data_dictionary.md)
previously returned `NULL` - that is an API change, filed under Major
changes in NEWS, not bug fixes. Both halves of the gate are
load-bearing: `verbose` is the user-facing rule, and
[`interactive()`](https://rdrr.io/r/base/interactive.html) is what stops
the test suite and `R CMD check` from launching viewers. Removing
[`interactive()`](https://rdrr.io/r/base/interactive.html) brings back
the EBUSY failure below.

\[LEARN:defect\] **The `[EBUSY]` cache-deletion failure had TWO
independent causes; only one is confirmed fixed.** (a)
`data_dictionary(2022,'tracts')` opened an `.xlsx` via `shell.exec()`
and Excel held the handle - fixed by the
[`interactive()`](https://rdrr.io/r/base/interactive.html) gate in
b9ca5ed, confirmed by a clean single-process suite run with zero
failures. (b) Two R sessions sharing the same global cache directory:
one downloads or reads while the other runs
`censobr_cache(delete_file='all')`, giving `EBUSY`, `ENOTEMPTY`, or a
spurious “cached file seems to be corrupted”. Cause (b) was
self-inflicted - two overlapping background suite runs - not a package
defect.

\[LEARN:workflow\] **Never run two test suites concurrently.** They
share the global cache dir (`tools::R_user_dir("censobr","cache")`), so
they corrupt each other’s downloads and fight over deletion. Symptoms
look like package bugs (`EBUSY` / `ENOTEMPTY` / “file corrupted”) but
are pure contention. Check for a running `Rscript` before launching a
suite, and never launch a second one because the first appears silent -
a 0-byte output file usually means still running, not dead.

\[LEARN:pattern\] A live
[`arrow::open_dataset()`](https://arrow.apache.org/docs/r/reference/open_dataset.html)
Dataset does **not** lock its parquet file on Windows - verified
directly. Do not blame Arrow for an `EBUSY` on a `.parquet`; look for
another process first. contention. Check for a running `Rscript` before
launching a suite, and never launch a second one because the first
appears silent - a 0-byte output file usually means still running, not
dead.

\[LEARN:pattern\] A live
[`arrow::open_dataset()`](https://arrow.apache.org/docs/r/reference/open_dataset.html)
Dataset does **not** lock its parquet file on Windows - verified
directly. Do not blame Arrow for an `EBUSY` on a `.parquet`; look for
another process first. \[LEARN:docs\] **Open item:
`vignettes/census_tracts_data.Rmd:90`** calls
`data_dictionary(year = 2022, dataset = 'tracts')` in an evaluated chunk
with `verbose` at its `TRUE` default. Knitting is non-interactive, so
the file is no longer opened and the chunk now prints a machine-specific
cache path. The surrounding prose still says the function “will open the
file”, which is now conditional. Fix with `results='hide'`, an
assignment, or reworded prose - not yet done.

\[LEARN:workflow\] **A background task that returns no completion
notification may have produced nothing.** After the b9ca5ed changes the
suite was launched in the background but its output file was 0 bytes and
no notification arrived, so that commit went in unverified. Check the
output file size before treating a background run as evidence; an absent
failure is not a pass.

\[LEARN:testing\] **The full suite from a cold cache is not a reliable
signal on this machine.** A 2026-08-28 run produced 24+ failures in
`test_read_population.R` / `test_read_tracts.R` - the computer slept
mid-run, the network dropped, downloads returned `NULL`, and one file
cached truncated. None of it was a code defect. Before treating suite
failures as real: check whether the cache was cold, whether the machine
slept, and whether more than one R session was running.

\[LEARN:defect\] **CORRECTED, then FIXED 2026-08-28.** I originally
logged this as “download_file() cannot detect a truncated download”.
That was wrong: libcurl compares Content-Length against bytes received
at the transport layer, so
[`curl::multi_download()`](https://jeroen.r-universe.dev/curl/reference/multi_download.html)
already returned `success = FALSE` on a partial transfer (verified with
a local server sending 50 of a declared 100000 bytes). The real bug was
that **the partial file stayed on disk**, and since
[`download_file()`](https://ipeagit.github.io/censobr/dev/reference/download_file.md)
returns early on `file.exists() && cache`, it was served as a valid
cache hit and then failed inside arrow as “File cached locally seems to
be corrupted”. Fixed by the httr2 port, which
[`unlink()`](https://rdrr.io/r/base/unlink.html)s the file on any
failure.

\[LEARN:pattern\] **Do not verify a download against `content-length`.**
It is redundant (libcurl already does it) and actively wrong under
compression: httr2 sends `Accept-Encoding: gzip` by default and curl
decompresses, so the header describes compressed bytes while the file on
disk is larger. Measured on r-project.org: header 2714, disk 7216 - such
a check would delete a good file. GitHub release assets are uncompressed
today, but that is a server setting censobr does not control.
\[LEARN:workflow\] **A filtered or truncated log is not evidence.** Two
false “zero failures” reports in one session: once from grepping
`^(Failure|Error)` when testthat writes `-- 4. Failure (...)`, once from
piping a run through `tail -30` and then pattern-matching the truncated
file. Always write the full log to a file and count
`^-- [0-9]+\. (Failure|Error)` blocks, and watch for testthat’s “Maximum
number of 10 failures reached” cap hiding the rest.

## httr2 port + data_dictionary cleanup (2026-08-28)

\[LEARN:api\]
**[`data_dictionary()`](https://ipeagit.github.io/censobr/dev/reference/data_dictionary.md)
file format depends on year AND dataset.** `"microdata"` opens a single
Excel file, published only for **2000 and 2010**. For the 1960, 1970,
1980 and 1991 censuses the per-dataset HTML dictionaries are still the
only ones, and `"population"` / `"households"` are valid options for
exactly those years. `"families"`, `"mortality"` and `"emigration"` were
never published for any year and are removed.

\[LEARN:process\] **I broke working functionality by testing one year
and generalising.** Told that the 2010 microdata dictionary should come
from the Excel file, I checked the per-dataset URLs for 2010 only, saw
404s, and removed all five options - which killed the 1960-1991
dictionaries that work fine. The user caught it by asking why their
example had been deleted. **Before removing an option, test the full
matrix of its parameters, not one cell.** The 404s were also perfectly
consistent with v0.6.0’s own NEWS (“Excel file … for now, available for
the years 2000 and 2010”) - the release notes said the Excel covered two
years, not all of them, and I did not read that as the constraint it
was. \[LEARN:defect\] **A poisoned cache hid the 404s for an entire
release cycle.**
[`curl::multi_download()`](https://jeroen.r-universe.dev/curl/reference/multi_download.html)
treated a 404 as a completed transfer and wrote the 9-byte error body
into the cache. The size check caught it once and returned NULL, but the
file stayed, so every later call short-circuited on
`file.exists() && cache` - no download, no message, tests green - while
users got a 9-byte HTML error page as their data dictionary. The httr2
port [`unlink()`](https://rdrr.io/r/base/unlink.html)s failed downloads,
which is what surfaced it. **Any silent cache hit deserves suspicion:
verify the cached file is what it claims to be, not merely that it
exists.**

\[LEARN:testing\] **`expect_message()` is a near-worthless assertion for
these functions.** The retired dictionary tests used it, and a 404’s own
danger message satisfies it just as well as a successful download.
Assert on the returned path, or on specific message text - never on the
mere existence of a message.

\[LEARN:pattern\] **httr2 port shape** (`R/utils.R`): `request()` -\>
optional `req_progress()` -\>
`tryCatch(req_perform(req, path = local_file))`. Connection failures
throw `httr2_failure` and are NOT suppressed by `req_error()`; HTTP
status errors throw and inherit `httr2_http`, which is how the two
failure messages are told apart. Both leave a file on disk, so
[`unlink()`](https://rdrr.io/r/base/unlink.html) on any failure is
mandatory. `req_progress()` writes 0 bytes non-interactively where
[`curl::multi_download`](https://jeroen.r-universe.dev/curl/reference/multi_download.html)
wrote 169 to stderr.

\[LEARN:cran\] **Fail-gracefully is verified, not assumed.** All 10
download sites now guard on
[`is.null()`](https://rdrr.io/r/base/NULL.html);
[`merge_household_var()`](https://ipeagit.github.io/censobr/dev/reference/merge_household_var.md)
was the only gap (it used
[`read_households()`](https://ipeagit.github.io/censobr/dev/reference/read_households.md)’s
result directly). `tests/testthat/test_graceful_failure.R` locks the
behaviour in using
[`httr2::with_mocked_responses()`](https://httr2.r-lib.org/reference/with_mocked_responses.html) -
runs fully offline, no network, no `assignInNamespace`. Mock a
connection failure by [`stop()`](https://rdrr.io/r/base/stop.html)ing a
condition of class `httr2_failure`; mock an HTTP error with
`httr2::response(status_code = 404L)`.

\[LEARN:testing\] **A graceful-failure test through an exported function
can be decorative.** My first merge test passed with the guard removed:
under a global mock,
[`read_mortality()`](https://ipeagit.github.io/censobr/dev/reference/read_mortality.md)’s
own download fails first and it returns before ever reaching the merge
block. The path had to be tested by calling
[`merge_household_var()`](https://ipeagit.github.io/censobr/dev/reference/merge_household_var.md)
directly. **Always confirm a regression test fails without the fix** -
comment the fix out, re-run, and check the count goes up. Here: 2
failures without, 0 with.

\[LEARN:cran\]
**[`arrow_open_dataset()`](https://ipeagit.github.io/censobr/dev/reference/arrow_open_dataset.md)
no longer throws.** It used
[`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html) on
a corrupt cached parquet, which violated fail-gracefully and, worse, was
unrecoverable: the corrupt file stayed in the cache so every subsequent
call failed the same way. It now
[`unlink()`](https://rdrr.io/r/base/unlink.html)s the file and returns
`NULL`, making the package self-healing - the next call re-downloads.
All 6 `read_*()` functions guard the result with
[`is.null()`](https://rdrr.io/r/base/NULL.html). Covered by two
regression tests in `test_graceful_failure.R` that write a non-parquet
file into the cache path.

\[LEARN:defect\] **Truncation detection was needed after all - my
earlier entry saying otherwise was wrong.** A partial download of the
802 MB `2010_population` parquet passed
[`download_file()`](https://ipeagit.github.io/censobr/dev/reference/download_file.md)’s
only test (`size < 5000`), was cached, and then failed in arrow as
corrupted - breaking the vignette build. libcurl catches a transfer that
*errors*, but not every way a large transfer ends short. The fix
compares bytes-on-disk to `content-length`, but **only when
`content-encoding` is absent**, because curl decompresses on the fly and
a gzip response legitimately differs (r-project.org: header 2714, disk
7216). Logic lives in
[`download_is_incomplete()`](https://ipeagit.github.io/censobr/dev/reference/download_is_incomplete.md)
(`R/utils.R`).

\[LEARN:testing\] **httr2 mocked responses do NOT write a body to
disk.** `with_mocked_responses()` plus `req_perform(path=)` leaves no
file, so any test of size/integrity logic through a mock passes or fails
for the wrong reason - mine did both. Extract such logic into a plain
internal function (`download_is_incomplete(actual, expected, encoding)`)
and unit-test it directly. Mocks remain right for testing *error
propagation* (404, connection failure), just not file contents.

\[LEARN:testing\] **Never write a corrupt file into the real cache in a
test.** A test that poisoned `2010_population_v0.6.0.parquet` relied on
[`unlink()`](https://rdrr.io/r/base/unlink.html) to clean up; when the
file was locked on Windows the unlink failed silently and the garbage
stayed, breaking the vignette build. Test
[`arrow_open_dataset()`](https://ipeagit.github.io/censobr/dev/reference/arrow_open_dataset.md)
directly in [`tempdir()`](https://rdrr.io/r/base/tempfile.html) instead.

## Session close 2026-08-29 (commits b9674f5, bc942e5, 42747c0)

\[LEARN:cran\]
**[`data_dictionary()`](https://ipeagit.github.io/censobr/dev/reference/data_dictionary.md)
error paths now guide, not just refuse.** Three shapes: an unknown
dataset lists valid options; a real-but-undocumented dataset
(`families`/`mortality`/`emigration`) says none was published and points
to the microdata dictionary; a year without the requested dictionary
points to what *does* exist for that year (1960-1991 -\>
`population`/`households`; 2022 -\> `tracts`). Non-census years fall
back to a plain message, since no suggestion would be honest.

\[LEARN:testing\] **A reduced `R CMD check` is not a check.** Most of
this session I ran `--no-examples --no-tests --no-vignettes` and
reported ‘0 errors, 0 notes’. That configuration never executes a line
of package code. Two real defects - an orphaned `@examples` call and a
truncated 802 MB download breaking the vignette - surfaced only when the
user asked for
`devtools::check(cran = FALSE, env_vars = c(NOT_CRAN = 'true'))`. **Use
the reduced form only for fast structural feedback, and never describe
its result as a passing check.** The release gate is both modes:
`cran = TRUE` + `NOT_CRAN='false'` for CRAN policy, `cran = FALSE` +
`NOT_CRAN='true'` to actually run examples, tests and vignettes.

\[LEARN:api\]
[`questionnaire()`](https://ipeagit.github.io/censobr/dev/reference/questionnaire.md)
requires both `year` and `type`; each missing argument gives its own
informative error. Reviewed and **accepted** by the user 2026-08-29 -
not an open item.

\[LEARN:testing\] **testthat edition 3 is DONE and clean (2026-08-29).**
`Config/testthat/edition: 3` is in DESCRIPTION and
[`testthat::edition_get()`](https://testthat.r-lib.org/reference/local_edition.html)
returns 3. My deferral reasoning turned out to be over-cautious on both
counts: the 10 arrow-collected `expect_equal()` comparisons in
`test_read_population.R` / `test_read_households.R` pass under waldo
unchanged, and the 17 `context()` calls and the one `expect_is()` DID
warn under 3e - my earlier claim that they did not was a grep error
(they surface in testthat’s summary reporter, not as a check WARNING).
Both were removed on 2026-08-29; the suite is now warning-free. Full
`devtools::check(cran = FALSE, NOT_CRAN = 'true')`: Status OK,
examples/tests/vignettes all executed. **Lesson: a risk that can only be
settled by running it should be run, not deferred indefinitely.**

\[LEARN:api\] **All 9 functions taking `year` use
`checkmate::assert_number(year)`, not `assert_numeric()`.**
`assert_numeric` accepts a vector, so `read_population(c(2000, 2010))`
used to reach `if (isFALSE(year %in% years))` with a length-2 condition
and die on base R’s “the condition has length \> 1”. `assert_number`
enforces length 1 and rejects NA. The `missing(year) || is.null(year)`
guard still runs first, so a missing year keeps its friendly message.

\[LEARN:api\] **`columns` accepts numeric indices as well as names** -
`read_families(2000, columns = c(1L, 2L))` returns code_muni/code_state.
Undocumented but working, so any validation must guard with
`is.character(columns)`; [`setdiff()`](https://rdrr.io/r/base/sets.html)
coerces numerics and would falsely reject them. Absent names now raise
[`error_columns_absent()`](https://ipeagit.github.io/censobr/dev/reference/error_columns_absent.md)
(`R/utils.R`) naming the columns and pointing at
[`data_dictionary()`](https://ipeagit.github.io/censobr/dev/reference/data_dictionary.md).

\[LEARN:process\] **Edit-distance suggestions are useless for coded
variable names.** I proposed
[`utils::adist`](https://rdrr.io/r/utils/adist.html) near-matches for
mistyped columns; on censobr’s real 251-column schema `"V0602"` matched
85 candidates, because census names are 5-character codes where
everything is within edit distance 2. It would also have added an
undeclared `utils` dependency. Check the suggestion quality against real
data before shipping a did-you-mean.

\[LEARN:testing\] **Graceful-failure tests are destructive to the cache
and MUST run last.** `test_zz_graceful_failure.R` calls the real
exported functions with real years under mocked download failures.
[`download_file()`](https://ipeagit.github.io/censobr/dev/reference/download_file.md)
[`unlink()`](https://rdrr.io/r/base/unlink.html)s the target on failure,
and with `cache = FALSE` that target is a real path in the user’s
cache - so the file gets deleted. Named `test_zz_` so it runs after the
`read_*` tests; when it ran as `test_graceful_failure.R` (g \< r) it
wiped the 802 MB `2010_population` parquet and the read tests failed on
the re-download. **Diagnostic tell: vignettes passed in the same run,
which requires read_population() to work - so the failure had to be
test-ordering, not code.**

\[LEARN:refactor\] **Do not route validation through a shared helper in
this package.** `checkmate::assert_*()` has no `call` argument, so an
extra frame permanently changes error attribution from
[`read_families()`](https://ipeagit.github.io/censobr/dev/reference/read_families.md)
to the internal helper - verified: 2-frame reports `inner(c(1,2))`,
3-frame reports `inner(year = year)`. That would degrade ~30 of the most
common user-facing errors, and **no test would catch it**: every
`expect_error` here matches message text, never `conditionCall`. Extract
only code with **no `cli_abort` and no `checkmate`** -
[`open_censobr_data()`](https://ipeagit.github.io/censobr/dev/reference/open_censobr_data.md)
(`R/utils.R`) is the safe shape: URL + download + open, no validation.

\[LEARN:process\] **Two of my three stated motivations for that refactor
did not survive inspection.** ‘Assert drift’ between readers was
cosmetic (`assert_logical`’s `null.ok` already defaults to FALSE, so the
variants were behaviourally identical), and both live `merge_households`
guards were already correct. Only the copy-paste URL class was real.
When justifying a refactor by citing past bugs, re-check that each cited
bug is actually attributable to the structure being changed.
