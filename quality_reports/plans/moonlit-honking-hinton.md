# Speed up CI: binary `arrow`/`duckdb` via r2u on Ubuntu jobs

**Status:** DRAFT

## Context

CI (`R-CMD-check.yaml`, `R-CMD-check-CRAN.yaml`, `test-coverage.yaml`) is slow because `arrow` and
`duckdb` — both `Imports` in `DESCRIPTION` (`arrow (>= 15.0.1)`, `duckdb`) — have no CRAN binary for
every matrix cell, so `pak` (used internally by `r-lib/actions/setup-r-dependencies`) falls back to
building libarrow's C++ core and DuckDB's bundled amalgamation from source on every cold cache.
`duckdb` in particular has no "download a prebuilt binary" fallback the way `arrow`'s configure
script does, so it always compiles fully from source — this is the single biggest CI time sink.

**Chosen fix:** [r2u](https://github.com/eddelbuettel/r2u) (Dirk Eddelbuettel's binary-APT layer for
CRAN packages) ships real `.deb` binaries for `arrow` and `duckdb` on Ubuntu, installable via `apt`
in seconds. The user confirmed: use the **action-based setup** (`eddelbuettel/github-actions/r2u-setup@master`
or the equivalent apt script), **not** the `rocker/r2u` container image — the jobs keep using
`r-lib/actions/setup-r` to install R.

## Key compatibility finding (verified via research, not memory)

`r-lib/actions/setup-r-dependencies@v2` installs packages via **pak**, and pak has its own
installer pipeline — it does **not** call base R's `install.packages()`. r2u's `bspm` layer works by
patching `install.packages()`, so pak does not automatically pick up r2u binaries just because the
apt repo is present.

**The reliable integration pattern (used here) sidesteps that entirely**: install `arrow` and
`duckdb` as system binaries via `apt-get` **before** `setup-r-dependencies` runs. Both pak and base
`install.packages()` check already-installed package versions against `DESCRIPTION` constraints and
skip a package that's already satisfied — no bspm/pak interception needed. This works because
`r-lib/actions/setup-r` on Linux installs R from the **same CRAN Ubuntu apt repository** that r2u
layers onto (matching `/usr/lib/R/site-library` paths and R ABI) — confirmed this is exactly the
combination r2u is designed for.

**Caveat on the `r: devel` matrix cell** (`R-CMD-check.yaml`): r2u tracks the current R **release**
ABI. Installing its `r-cran-arrow`/`r-cran-duckdb` `.deb`s under R-devel *should* still work (Ubuntu
R binary packages are ABI-stable across minor R versions in the common case), but this is the one
cell where a fast-path failure is plausible. Steps are added unconditionally for all `ubuntu-24.04`
matrix cells; if the devel cell fails to load the apt-installed binaries, `pak` still falls through
to its normal source-build behavior for that package — it does not hard-fail the job, so worst case
that cell just doesn't get the speedup.

## Changes

Add two steps, identical across all three workflow files, right after `r-lib/actions/setup-r` (and
after `setup-pandoc` where present) and before `r-lib/actions/setup-r-dependencies`, gated to Linux
runners only (`R-CMD-check.yaml` also has Windows/macOS matrix cells):

```yaml
      - name: Setup r2u (binary CRAN packages for Ubuntu)
        if: runner.os == 'Linux'
        uses: eddelbuettel/github-actions/r2u-setup@master

      - name: Install arrow and duckdb as apt binaries
        if: runner.os == 'Linux'
        run: sudo apt-get install -y --no-install-recommends r-cran-arrow r-cran-duckdb
```

**Files to modify:**
- `.github/workflows/R-CMD-check.yaml` — insert after the `setup-pandoc` step (before
  `setup-r-dependencies`); the `if: runner.os == 'Linux'` guard makes this a no-op on the
  `windows-latest`/`macOS-latest` matrix cells.
- `.github/workflows/R-CMD-check-CRAN.yaml` — same insertion point (single ubuntu-24.04 job, guard
  is harmless but kept for consistency).
- `.github/workflows/test-coverage.yaml` — insert after `setup-r`, before `setup-r-dependencies`
  (this workflow has no `setup-pandoc` step).

No changes to `R/`, `DESCRIPTION`, or the data-release pin — this is CI-only.

## Verification

- Cannot be verified locally (GitHub-Actions-only). After pushing:
  1. Open the Actions run for each of the three workflows and confirm the new "Setup r2u" /
     "Install arrow and duckdb" steps succeed on the `ubuntu-24.04` cells.
  2. In the following `setup-r-dependencies` step's log, confirm `arrow` and `duckdb` are reported
     as already satisfied (not compiled) — this is the actual proof the fast path worked.
  3. Compare total job wall-clock time to the current baseline for `R-CMD-check-CRAN` (single
     ubuntu-24.04/release job — the cleanest before/after comparison).
  4. Confirm `R-CMD-check --as-cran` gate still passes (0/0/0) — this change must not alter build
     output, only install mechanics.
- If the `r: devel` cell shows a load failure for the apt binaries (rather than a clean pak
  fallback), report back — that cell may need to be excluded from the apt pre-install step.
