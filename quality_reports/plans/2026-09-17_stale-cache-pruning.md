# Plan — Auto-prune cache dirs from old data releases

**Status:** COMPLETED (2026-09-17)
**Date:** 2026-09-17
**Branch:** dev
**Trigger:** Bumping `censobr_env$data_release` to `v1.0.0` left `data_release_v0.6.0` (2.0 GB on the
maintainer's machine) untouched beside the new `data_release_v1.0.0`.

---

## Diagnosis (root cause, verified)

The auto-delete existed and was removed.

- `a7f726e` (2023-09-10) added it to `.onLoad()`; documented in NEWS v0.2.0:
  *"The package now automatically deletes cached data from previous data releases..."*
  It listed `dirname(censobr_env$cache_dir)` for `data_release*` entries and `unlink()`ed every
  one that did not match the pin.
- `6838f0e` (2025-06-29, "closes #55") **deleted that block**. That commit made the cache dir
  user-configurable and persistent: `censobr_env$cache_dir` (resolved once at load) was replaced by
  `get_censobr_cache_dir()` (read from the config file at call time). The pruning code depended on
  the variable that went away, and was never re-implemented at the new resolution point.
- Today `R/onLoad.R` contains only the pin. No code path in `R/` deletes a stale release dir;
  `download_file()` (`R/utils.R:52-56`) only *creates* `{cache}/data_release_{pin}`. The sole
  deletion surface left is the user-invoked `censobr_cache(delete_file=)` (`R/cache.R:181-215`).

**Immediate workaround (no code change):** `delete_file` is a `grepl()` pattern over full paths, so
`censobr_cache(delete_file = "data_release_v0.6.0")` removes the stale dir today.

## Decision

Maintainer's call (2026-09-17): **restore auto-delete, with an escape hatch.** Noted at decision
time: the pre-v0.6.0 behaviour silently unlinked GBs at `library(censobr)`, which sits badly with
CRAN policy §1.1 (no modifying the user's filespace without consent) and with the documented choice
that `censobr_cache()` lists from the cache *root* so old releases stay visible. The design below
keeps the auto-delete but moves it off `.onLoad()` and adds three guards the 2023 version lacked.

## Design

**Prune at download time, not at load.** `.onLoad()` cannot know the user's cache dir reliably
(`set_censobr_cache_dir()` may be called after load), and unlinking gigabytes during `library()` is
both slow and the CRAN-riskiest possible moment. The prune runs once per session, the first time a
versioned cache dir is resolved.

Three guards the 2023 version did not have:

1. **Anchored, exact matching.** Old code used `grepl(data_release, all_cache)` — an unanchored
   regex where `.` matches any character. New code lists only `^data_release_` *directories* and
   compares `basename(dir) != paste0("data_release_", pin)` by equality. This matters now that the
   cache dir can be an arbitrary user directory (`set_censobr_cache_dir("~/data")`), where deleting
   anything unanchored would be catastrophic.
2. **Controlled-access files are never deleted.** `import_microdata22_controlado()` writes
   `2022_*.controlado_{pin}.parquet` into the versioned dir. Those come from an IBGE zip and
   **cannot be re-downloaded**. The prune deletes every other file in an old release dir, keeps any
   `*controlado*` file, removes the dir only if it ends up empty, and tells the user which files
   were preserved and where.
3. **Escape hatch.** `options(censobr.keep_old_cache = TRUE)` skips the prune entirely — for users
   pinning an old release for reproducibility.

## Changes

| # | File | Change |
|---|---|---|
| 1 | `R/cache.R` | New internal `delete_old_cache_dirs(verbose)`: reads `get_censobr_cache_dir()`, returns early on the option / missing dir / nothing stale; `gc()` before `unlink()` (Windows arrow memory-maps parquet — same reason as `delete_file = "all"` at `R/cache.R:198`); preserves `*controlado*`; reports deleted dirs + freed size via `cli`. Placed **outside** the `# nocov` blocks so it is testable. |
| 2 | `R/cache.R` | `censobr_cache(delete_file = "old")` → calls the same helper, giving an explicit manual surface. Document in `@param delete_file`. |
| 3 | `R/onLoad.R` | `censobr_env$old_cache_checked <- FALSE` (session guard — prune at most once per session). |
| 4 | `R/utils.R` | In `download_file()`, right after `cache_dir <- get_censobr_cache_dir()` (`:52`), call the helper behind the session guard. Covers all six `read_*()` and all three docs functions. |
| 5 | `R/import_microdata22_controlado.R` | Same call after `:106`, so an import-first session also prunes. |
| 6 | `tests/testthat/` | New `test_cache_prune.R` — **offline**, uses `set_censobr_cache_dir(tempdir())` and fake files. Asserts: stale dir removed; current dir untouched; a non-`data_release_` sibling untouched; `*controlado*` preserved and its dir kept; `options(censobr.keep_old_cache = TRUE)` is respected; second call in the same session is a no-op. Real coverage for code that is otherwise `nocov`. |
| 7 | `man/` + `NAMESPACE` | `devtools::document()` (generated — never hand-edited). |
| 8 | `NEWS.md` | Under dev: the restored behaviour, the option, and the controlled-access exception. |
| 9 | `CLAUDE.md` | Update "The data-release contract" — bumping the pin now prunes old caches; note the `*controlado*` exception and that `censobr_cache()` still lists from the root. |

**Open sub-decision (default chosen, easy to flip):** the prune message is gated on `verbose`, for
consistency with `cache_message()`. Deleting 2 GB arguably deserves to speak even under
`verbose = FALSE` (as the 1960 warning does). Say the word and it becomes unconditional.

## Verification

1. `devtools::load_all()` + `devtools::test(filter = "cache_prune")` — offline, no network needed.
2. Full `devtools::test()` (network; note `test_z_censobr_cache.R` wipes the real cache).
3. `/r-package-check` — `R CMD check --as-cran`, both modes; baseline is 0/0/0.
4. **Live check on the maintainer's machine, only after explicit go-ahead** (it deletes the real
   2.0 GB `data_release_v0.6.0`): `library(censobr); read_households(1960, verbose = TRUE)` and
   confirm the prune message + that only `data_release_v1.0.0` remains.

## Risks

- **Deletes user files.** Accepted by the maintainer; mitigated by the anchored match, the
  controlled-access exception, and the option.
- **A second R session holding an open arrow Dataset on an old file** — `unlink(force = TRUE)` fails
  silently on Windows. The helper re-lists after unlinking and warns (same pattern as
  `delete_file = "all"`), rather than erroring inside a `read_*()` call.

---

## Outcome (2026-09-17)

Implemented as planned, with one deviation approved by the maintainer: the prune message is gated
on `verbose`, so a `read_*(verbose = FALSE)` call deletes files silently.

**Verification run**

| Gate | Result |
|---|---|
| `testthat::test_local(filter = "cache_prune")` — offline | 25 expectations, all pass |
| Live run on the maintainer's real cache | `Deleted 10 files (2 Gb) ... "data_release_v0.6.0"`; `read_households(1960)` still returned a `FileSystemDataset` from cache. Cache went 2.1 GB → 86 MB |
| `devtools::check(cran = TRUE, NOT_CRAN = "false")` | **0 errors, 0 warnings, 0 notes** (1m15s) — baseline held |

**Not run:** the full suite in `NOT_CRAN=true` mode. It is network-bound and
`test_z_censobr_cache.R` deletes the real cache dir, so it re-downloads everything. The new tests
`skip_on_cran()`, so the CRAN-mode check above exercised them not at all — their evidence is the
offline `test_local()` run and the live run, both above. Run the full suite before the release.

**Files:** `R/cache.R`, `R/onLoad.R`, `R/utils.R`, `R/import_microdata22_controlado.R`,
`tests/testthat/test_cache_prune.R` (new), `DESCRIPTION` (+withr), `man/` (regenerated),
`NEWS.md`, `CLAUDE.md`.

### Follow-up verification — user-set cache directory (2026-09-17)

Asked whether `set_censobr_cache_dir()` still works and whether the prune + download act on the
directory the user chose. Verified across three separate R sessions, with a path containing spaces:

| Check | Result |
|---|---|
| `set_censobr_cache_dir("…/my census cache")` → config file written | PASS |
| Setting survives into a **new** R session (`get_censobr_cache_dir()`) | PASS |
| A real download (`data_dictionary(2010, "tracts")`) lands in `{user dir}/data_release_v1.0.0/` | PASS |
| Plain old release deleted in the user's dir | PASS |
| Old release holding `*controlado*` kept, its downloadable neighbour deleted | PASS |
| The user's own sibling directory (`my own files/`) untouched | PASS |
| The **default** cache dir untouched while a custom one is in use | PASS |
| `set_censobr_cache_dir(NULL)` resets, cached data intact | PASS |

**Fixed in passing:** the success message pluralised off `size`, so two stale releases read
"a previous data release". Now uses `cli::qty(length(releases))` — "a previous data release" /
"previous data releases: … and …". Re-verified: tests 25/25, `check(cran = TRUE)` 0/0/0.
