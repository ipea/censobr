## R CMD check results

Checked in both modes (see CLAUDE.md -- both are required):

── R CMD check results ─────────────────────────────────────────────── censobr 0.6.0.901 ────
`devtools::check(cran = TRUE, env_vars = c(NOT_CRAN = "false"))`
0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── R CMD check results ─────────────────────────────────────────────── censobr 0.6.0.901 ────
`devtools::check(cran = FALSE, env_vars = c(NOT_CRAN = "true"))` -- runs examples, tests
(network-dependent), and rebuilds vignettes.
0 errors ✔ | 0 warnings ✔ | 0 notes ✔

Checked 2026-08-30 after adding `merge_households` to `read_population()`, and re-checked
twice more the same day: once after restricting `columns` to a character vector under
`merge_households = TRUE`, and again after extending that restriction to `columns`
package-wide (all five microdata readers) -- numeric column indices are no longer
supported anywhere, matching the documented type.
