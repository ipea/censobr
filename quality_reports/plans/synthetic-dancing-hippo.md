# Plan — Apply the label-audit fixes to the formatted dictionaries and `add_labels_*()`

**Status:** COMPLETED (all Phase A + B edits applied and verified) · **Date:** 2026-09-13 · **Branch:** dev

## Context

Four meticulous audits (1960, 1970, 1980, 1991 — `quality_reports/*_label_audit.md`) reconciled every
code→label pair in `add_labels_population()` / `add_labels_households()` against the IBGE data
dictionary and each census questionnaire, then verified the data-dependent findings against the
v0.7.0 parquets. Result: **no label is bound to the wrong code in any year**, but ~20 variables carry
wording defects, and a further ~14 defects live in the dictionary itself.

Two decisions make this the right moment to fix both sides together:

1. **The plan is to retire the served `*_dictionary_microdata_{population,households}.html` files and
   publish `[year]_dictionary_microdata_formatted.xlsx` instead.** Those xlsx files are exactly what
   the audits compared the code against, so whatever is wrong in them becomes wrong *in public*. The
   labels currently repair several dictionary typos silently; after the swap the typos would ship.
2. The maintainer has settled the two standing style questions: **`Urbana`/`Suburbana` feminine**, and
   **`Naturalizado brasileiro`** (already applied to `R/`), which several dictionary cells contradict.

**Intended outcome:** the questionnaire, the published dictionary, and the labels agree — so the swap
ships clean and a future re-audit finds nothing to re-litigate.

**Governing rule for every edit below:** the change must be traceable to that year's questionnaire.
Where the questionnaire is silent, the dictionary governs and the labels follow it. Two approved
exceptions (from AskUserQuestion): abbreviated dictionary entries are expanded to the questionnaire's
fuller wording ("both tiers"), and 1991 `V0310`'s proper-noun/grammar slips are fixed in the
dictionary rather than propagated into the labels.

## Approach

- **xlsx:** edit **in place with `openpyxl` 3.1.5** (verified available). Each variable's whole code
  list lives in a single merged column-B cell, so every fix is one in-cell string replacement —
  no row/column restructuring. Styling (Times New Roman, wrap, 1 merged range per row, no images or
  conditional formatting) round-trips safely.
- **R:** string edits via a small Python script (files are `\u00XX`-escaped; ASCII-safe patterns
  matched exactly, one occurrence asserted per edit — the method already used twice this session).
- **Back up all four workbooks to the scratchpad before the first write.**

---

## A. Dictionary fixes — 23 lines across 4 workbooks (8 sheets)

Each row cites the questionnaire box that authorises it. `A14` = the VAR's row in that sheet.

### `1960_dictionary_microdata_formatted.xlsx`

| Sheet/cell | Current | → | Questionnaire evidence |
|---|---|---|---|
| DOMI A14, PESS A16 · `V104` | `0- Ate 500` | `0- Até 500` | missing accent |
| DOMI A14, PESS A16 · `V104` | `1- de 500 a 1000` | `1- de 501 a 1000` | item D: box 10 "Até 500", box 11 "501 a 1 000" — the labels already say 501 |
| DOMI A28, PESS A30 · `V118` | `3- Suburbano` | `3- Suburbana` | SITUAÇÃO box prints "Suburbana"; matches the feminine policy |
| PESS A34 · `V202` | `5- Homem não Morador` / `6- Mulher não Morador` | `… não Morador Presente` (both) | row B heading over boxes 5/6: "Não morador **presente**" |
| PESS A41 · `V208` | `0- Brasil Naturalizado` | `0- Naturalizado Brasileiro` | row H box 30 "Naturalizado brasileiro" (current text is also truncated) |
| PESS A49 · `V215` | `7- Somente Casamento` / `8- Somente Casamento` | `7- Somente Casamento Civil` / `8- Somente Casamento Religioso` | row P boxes 57/58 — **resolves a duplicate that makes two codes indistinguishable** |
| PESS A58 · `V224` | `0- Membro da Família` | `0- Membro de Família ou Instituição` | row Z box 90 |

### `1970_dictionary_microdata_formatted.xlsx`

| Sheet/cell | Current | → | Questionnaire evidence |
|---|---|---|---|
| DOMI A6, PESS A6 · `V004` | `0- URBANO` / `1- SUBURBANO` | `0- URBANA` / `1- SUBURBANA` | SITUAÇÃO box on both forms prints "Urbana"/"Suburbana" |
| DOMI A14, PESS A15 · `V013` | `1-REDE GERAL DE ESGOSTO` | `1-REDE GERAL DE ESGOTO` | item 8; plain typo the labels already repair |
| PESS A26 · `V024` | `2- NÃO MORADOR` | `2- NÃO MORADOR PRESENTE` | item 3 box 2 |
| PESS A27 · `V025` | `4- PAIS E SOGROS` | `4- PAIS OU SOGROS` | item 4 box 4 "Pais **ou** Sogros" |
| PESS A31 · `V029` | `1- BRASILEIRO NATURALIZADO` | `1- NATURALIZADO BRASILEIRO` | item 8 box 1 |

### `1980_dictionary_microdata_formatted.xlsx`

| Sheet/cell | Current | → | Questionnaire evidence |
|---|---|---|---|
| DOMI A14 · `V206` | `5- … – outro`, `0- … - outro` | `… outra forma` (both) | quesito 6 prints "Outra forma"; labels already say it |
| DOMI A44 · `V511` | `4- brasileiro naturalizado` | `4- naturalizado brasileiro` | quesito 11 |
| PESS A26 · `V681` | codes 6–12 `… Salário Mínimo` | `… Salários Mínimos` (7 lines) | grammar: the brackets are plural ("mais de 1 a 2") |
| PESS A52 · `V555` | `0- sem filha vivas` | `0- sem filha viva` | grammar; `V550`/`V551`/`V554` use the singular |

### `1991_dictionary_microdata_formatted.xlsx`

| Sheet/cell | Current | → | Questionnaire evidence |
|---|---|---|---|
| DOMI A37 · `V0214` | `6 Jogado em rio, lago, lagoa ou mar` | `6 Jogado em rio, lago ou mar` | quesito 14 box 6 reads "Rio, lago ou mar" — **no "lagoa" on the form** |
| PESS A48 · `V0329` | `18- Outro -1º grau - Industrial` | `18- Outro - 1º grau - Industrial` | spacing; codes 15/20/23 use the spaced form |
| PESS A53 · `V0333` | `6- Desquitado(a) ou separado judicialmente` | `6- Desquitado(a) ou separado(a) judicialmente` | quesito 33 — labels already follow the form |
| PESS A102 · `V0310` | `77- Oriental Seicho No-Ie` | `77- Oriental Seicho-No-Ie` | write-in question; approved as a dictionary typo fix |
| PESS A102 · `V0310` | `85/86/89- … ou mal definidas` | `… ou mal definida` (3 lines) | grammar agreement with "determinada"; labels already singular |

## B. Label fixes — `R/add_labels_population.R`, `R/add_labels_households.R`

| Year | Site | Change | Why |
|---|---|---|---|
| 1960 | `population.R:2381-2382` | `'Homem/Mulher não morador'` → `… não morador presente` | questionnaire row B (mirrors the `V202` xlsx fix) |
| 1960 | `:2628` | `'Membro da família'` → `'Membro de família ou instituição'` | row Z box 90 |
| 1960 | `population.R:~2649`, `households.R:~1124` | `censobr_diag_*` code 2: restore `(valores inválidos, não listados no dicionário, marcados como missing)` | censobr's own dictionary prose; abridgement drops the operational definition |
| 1970 | `:2852` | `'Não morador'` → `'Não morador presente'` | item 3 box 2 |
| 1970 | `:2697-2698` | `'Secundária (não) parente'` → `'Secundário (não) parente'` | dictionary says SECUNDÁRIO; questionnaire prints neither, so the dictionary governs |
| 1970 | `:2867` | `'Pais e sogros'` → `'Pais ou sogros'` | item 4 box 4 |
| 1970 | `:2747-2754` | append the unit: `'Até 15 NCr$'` … `'De 961 NCr$ e mais'` | a bare `'Até 15'` is uninterpretable; the dictionary header and the form both say NCr$ **(judgment call — say the word and I'll instead put the unit only in the comment)** |
| 1970 | `:3007` | add the missing 2-line comment for the `V037` code-1 repair | the block NOTE promises a comment wherever sources disagree; this is the one gap, and it is a meaning reversal |
| 1980 | `:3629`, `:3649` | `'De 6 a 9 anos'` → `'6 a 9 anos'` (`V516`, `V517`) | both sources read "6 a 9 anos"; the added "De " is the block's only editorial addition |
| 1980 | `V541` code 5 + comment `:3884` | `'…não trabalhava'` → `'…não trabalhou'`; comment discloses the Quesito-30 paraphrase for codes 1/2 | quesito 41 box 5 prints "trabalhou" |
| 1980 | `V524` comment, `V536` comment `:3865`, NOTE `:3220-3222` | drop the two stale "as first published" claims (neither xlsx points `V524`→`V521` or `V536`→`V533`); re-file `V518`/`V527` as 6-digit identifiers and `V605` as a documented categorical | comments contradict both dictionaries |
| 1991 | `:5439-5446` | `V3471` codes 4, 7, 8, 9, 10, 11: restore the dictionary's parentheticals | `'Social'` alone is not a sector name; `V0329` shortens *and discloses*, this one didn't |
| 1991 | `population.R:4442`, `households.R:1786` | `V0214` code 6 → `'Jogado em rio, lago ou mar'` | follows the questionnaire and the corrected dictionary |
| 1991 | NOTE `population.R:~4199`, `households.R:~1551` | add `V0317`, `V0318`, `V3152` (pop) and `V0098`/`V0099` (hh) to the unlabelled inventory | both NOTEs read as exhaustive and are not |
| 1960 | NOTE `:2140-2142` | add `V001`–`V004`, `V200`, `V201`, `censobr_estrato/upa/usa`, `censobr_diag_*_vars` | same defect |
| 1960 | `V215` comment `:2551-2554` | rewrite: after the xlsx fix the dictionary and questionnaire agree for codes 7/8, so the comment no longer needs to claim a repair | keeps comment and sources in sync |

**Bonus effect:** once `V0214` and `V0333` are corrected in the 1991 xlsx, the 1991 NOTE's claim that
the questionnaire *"agrees with the dictionary throughout"* becomes **true**, so it needs no edit.

## C. Deliberately NOT changed (no questionnaire support)

- **1960 `uf` code 3 `'Roraima'`** — the questionnaire's `22 – Rio Branco` belongs to *Código 1*
  (naturalidade, `V207`/`V210`), **not** to `uf`, so the form cannot arbitrate this code. Left as the
  dictionary has it.
- **1960 `V299` code 0 wording** — the data proved the code exists (10,447,853 rows) and equals
  `V209 == 2`, but no questionnaire box corresponds to it; wording stays as transcribed.
- **1980 `V541` codes 1/2** — the form's literal text is "a ocupação do Quesito 30", unusable as a
  user-facing label. Paraphrase kept, now disclosed in the comment.
- **1970 `V006`** (households stores 259 dwelling-level means for a 5-category variable) — needs a
  data-prep decision in `ipea/censobr_prep_data`, not a text edit.

## Verification

1. **Pre-flight:** copy the 4 workbooks to the scratchpad; dump all 8 sheets to text (reuse the
   existing dump recipe that produced `scratchpad/dict*_{PESS,DOMI}.txt`).
2. **Post-edit dictionary diff:** re-dump and `diff` against the pre-edit dumps — assert **only the
   23 intended lines differ** and no cell, row, or variable was lost.
3. **Workbook integrity:** reload each file with `openpyxl` *and* `readxl::read_excel()`; compare
   sheet names, `dim()`, merged-range count, and a probe cell's font/wrap against the pre-edit values.
4. **R integrity:** `parse()` both files; re-dump the corrected dictionaries and re-reconcile the
   code→label pairs for the ~20 touched variables, asserting each label now matches its dictionary
   line exactly (the check the audits ran by hand).
5. **Behaviour:** the parquets for all four years are already cached, so re-run the label paths for
   the touched variables and confirm the new strings come back (e.g. 1960 `V202` → `'Homem não
   morador presente'`, 1991 `V3471` → `'Social (comunitárias, médicas, odontológicas e ensino)'`).
6. **Test suite:** `devtools::check(pkg = ".", cran = FALSE, env_vars = c(NOT_CRAN = "true"))` per the
   project convention (~12 min, network-bound). No existing assertion pins a string being changed —
   verified by grep — but this confirms it.
7. **Reports:** mark the fixed rows in the four `quality_reports/*_label_audit.md` files and update
   their scorecards.

## Out of scope

No commit. No `NEWS.md` entry yet (these are user-visible label changes and deserve one, but the
wording depends on whether the xlsx swap ships in the same release). The upstream actions —
re-rendering/retiring the HTML dictionaries, re-uploading the corrected xlsx to the `censo_docs` tag,
and the 1970 `V006` aggregation question — remain for `ipea/censobr_prep_data`.
