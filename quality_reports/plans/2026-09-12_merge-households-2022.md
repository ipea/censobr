# Plan — `merge_households = TRUE` for the 2022 microdata

**Status:** COMPLETED (pending full `devtools::check` result)
**Date:** 2026-09-12
**Request:** "edit the merge_household_var() so it can work with 2022 microdata"

---

## Phase 0 — is there a usable key? (verified on the cached v0.7.0 public files)

The merge design (`quality_reports/plans/2026-08-30_merge-households-read-population.md`)
admits a year only when the household key is documented, present in both tables,
unique on the household side, and adds variables. For 2022:

| Check | Result |
|---|---|
| Key in household records | `D0100` (int32) |
| Key in person / death / family records | `P0100` / `M0100` / `F0100` (int32) -- same id, table-prefixed name |
| Unique on the household side | 7,689,914 distinct values in 7,689,914 rows; no NA; no value appears in >1 state |
| Match rate main -> household | population 100 %, mortality 100 %, families 100 % |
| Needs geography to qualify the join | No -- unique nationally |
| Common (non-key) columns | only `code_region`, `name_region`, `code_state`, `abbrev_state`, `name_state` (already dropped from the household side by the existing logic) |

The blocker was structural, not statistical: the existing join is
`USING (key_vars)`, which needs identical column names on both sides, and in
2022 the names differ (`P0100` vs `D0100`).

## Changes

1. **`R/availability.R`** -- new registry key `merge_households = c(1970, 2000, 2010, 2022)`,
   so the year list lives in one place instead of two literals.
2. **`R/merge_household.R`**
   - keys split into `key_geo` (identically named qualifiers, empty for 2022),
     `key_main` and `key_hou` (the identifier on each side);
   - 2022 branch picks `key_main` by `grep('^[PMF]0100$', names(df))`, `key_hou = 'D0100'`;
   - join clause is `USING (...)` when the key names agree, `ON main.x = df_household.y`
     otherwise; the main subquery is aliased `AS main`; identifiers are quoted via
     `dbQuoteIdentifier()`;
   - the household pre-filter and both column push-downs use the side-specific key;
   - when the main table is the 2022 **public** release, the duplicate
     "public version" warning that `read_households()` would raise for the household
     table is muffled -- the caller already warned once, correctly attributed.
3. **`R/read_population.R`** -- year guard reads the registry; `@details` lists 2022.
4. **Tests** -- `test_read_population.R` merge loop adds 2022 (probe via `code_state`,
   since the public 2022 file has no `code_muni`) plus an explicit `P0100 == D0100`
   row-level check; `test_read_mortality.R` adds 2022 with row-count and `M0100 == D0100`
   checks; `test_availability.R` registers the new key.
5. **`NEWS.md`** -- bullet under the dev `merge_households` entry.
6. `devtools::document()` -- `man/read_population.Rd` regenerated.

## Verification

- [x] `read_population(2022, columns = c('code_state','P0100','D0100','D0120','D0130'), merge_households = TRUE)`:
      21,538,508 rows, `P0100 == D0100` on every row, 0 NA in `D0120`; 1.8 s warm
      (3 min on the first cold read of the 639 MB file)
- [x] household-only `columns = 'D0120'` returns exactly that column
- [x] `add_labels = 'pt'` labels both `P0120` and `D0120`
- [x] `read_mortality(2022, merge_households = TRUE)`: 430,961 rows in and out,
      `M0100 == D0100` on every row, 0 NA in `D0120`
- [x] exactly one "public version" warning per call
- [x] 1970 / 2010 population and 2010 mortality merges unchanged (USING path)
- [ ] `devtools::check(cran = FALSE, NOT_CRAN = "true")` -- running

## Out of scope / follow-ups

- `read_families()` still has its merge block commented out; `F0100` matches
  `D0100` 100 %, so enabling it is a small follow-up.
- `read_emigration()` is 2010-only; nothing to do.
