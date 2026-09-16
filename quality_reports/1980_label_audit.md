# 1980 Label Audit — `R/add_labels_population.R` + `R/add_labels_households.R` (58 variables reconciled)

Sources of authority used:

- **Dictionary** — `1980_dictionary_microdata_formatted.xlsx`, sheets `DOMI` and `PESS`; dumps `dict1980_DOMI.txt` (405 lines) / `dict1980_PESS.txt` (560 lines). The unformatted sibling `R:\Dropbox\git\censobr\1980_dictionary_microdata.xlsx` (sheets `population` / `households` — this is what `data_dictionary(1980, …)` serves users) was consulted to settle two in-code comments; its VAR list is **row-for-row identical** to the formatted file's (`households` = `DOMI`, 43 VAR rows; `population` = `PESS`, 53 VAR rows).
- **Questionnaire** — `1980_questionnaire_long.pdf` (**CD 1.01 — Boletim da Amostra**, 2 pp.) and `1980_questionnaire_short.pdf` (**CD 1.02 — Boletim da Não-Amostra**, 2 pp.). Both are scans with no text layer; every citation was read off a rendered page image (200 dpi) and, where the digit mattered, off a 3–4× crop. Crops left in `…\scratchpad\docs1980\*.png`.

Scope audited: `R/add_labels_population.R:3196-4178` (+ guard `:1-30`) and `R/add_labels_households.R:1293-1540`. `grep "YEAR 1980\|year == 1980" R/add_labels_*.R` returns hits in **only these two files** — `families`, `mortality` and `emigration` do not cover 1980.

---

## How the 1980 VAR numbers were mapped

1. **Bare VAR numbers → `V`-prefixed columns.** `=== VAR: 201` → `V201`, `=== VAR: 2` → `V2`. Verified against the R guards and against `data_prep/R/add_geography_cols.R:50` (`year == 1980 ~ 'V2'` for `code_state`).
2. **`DOMI` and `PESS` are not "household" and "person" files — they are the first and second halves of one 212-byte record.** `DOMI` runs `DESDE` 1→76 (ending `512`, `TAM=2`); `PESS` starts at `DESDE=77` (`513`). Perfectly contiguous. This is why `DOMI` carries person variables (`598`, `501`, `503`–`505`, `605`, `606`, `508`–`512`), and it corroborates the R NOTE at `:3203` — *"The 1980 population file also carries the household record"*.
3. **`CATEG` is an exact arithmetic check.** Across all 96 VAR rows, **`CATEG` = (number of numbered codes) + 1 if an unnumbered `- não aplicável` line is present.** `V201` CATEG=4 → 4 codes, no NA line; `V203` CATEG=8 → 7 codes + NA line; `V516` CATEG=11 → 10 + NA; `V550` CATEG=18 → 0–15, 98, 99. **The arithmetic closes for all 58 labelled variables.**
4. **Duplicated VAR rows are text continuations, not second entries.**
   - `DOMI` `209` (`dict1980_DOMI.txt:156` and `:163`): the code list is split across two printed rows — row 1 gives `1`,`3`; row 2 gives `5`,`6`,`7`,`0`,`9`, `- não aplicável`. Union = 7 codes; `CATEG=8` on both rows confirms one variable.
   - `PESS` `528` (`dict1980_PESS.txt:216` and `:221`): the *NOME* is split — `"Trabalhou nos últimos 12 meses (01/09/1979"` + `"a 31/08/1980): 1- sim / 3- não / 5- frente da seca"`. Union = 3 codes; `CATEG=3` on both rows.

   Both unions are labelled in full by R.

## The 1980 structural key (the analogue of the 1960 "last digit" key)

**1960's key does not carry over. 1980 has a different one: the *variable number* is the *questionnaire item number*, and the *codes* are printed literally in the boxes.**

- Household record: quesito **1** ESPÉCIE → `V201`; **2** TIPO → `V202`; **3** PAREDES → `V203`; **4** PISO → `V204`; **5** COBERTURA → `V205`; **6** ÁGUA → `V206`; **7** ESCOADOURO → `V207`; **8** USO → `V208`; **9** CONDIÇÃO DE OCUPAÇÃO → `V209`; **11** TEMPO DE RESIDÊNCIA → `V211`; **12** TOTAL DE CÔMODOS → `V212`; **13** CÔMODOS/DORMITÓRIO → `V213`; **14** PARA COZINHAR USA → `V214`; **15** COMBUSTÍVEL → `V215`; **16** TELEFONE → `V216`; **17** ILUMINAÇÃO ELÉTRICA → `V217`; **18** RÁDIO → `V218`; **19** GELADEIRA → `V219`; **20** TELEVISÃO → `V220`; **21** AUTOMÓVEL → `V221`. (Only quesito 10, *Aluguel*, breaks it — it is `V602`, not `V210`.)
- Person record: quesito **1** Sexo → `V501`; **3**/**4** Parentesco → `V503`/`V504`; **5** Família → `V505`; **8** Religião → `V508`; **9** Cor → `V509`; **10** Tem mãe viva → `V510`; **11** Nacionalidade → `V511`; **12** UF de nascimento → `V512`; **13**–**18** → `V513`–`V518`; **19**–**24** → `V519`–`V524`; **25**–**30**, **32**–**36**, **40**–**42**, **44**, **45** → the same `V5nn`; **50**–**57** → `V550`–`V557`.

This key **independently validates the `across()` block at `:4162-4177`**, which the dictionary alone could not: `V218`/`V219` carry only the names *"Rádio"*/*"Geladeira"* with `RENO=216`, and questionnaire quesitos **18 RÁDIO** / **19 GELADEIRA** confirm the assignment and the 1/8/9 codes. It also validates the `V550`↔`V551` (filhos↔filhas) ordering — exactly the kind of adjacent pair that gets swapped — because the questionnaire prints `50 homens / 51 mulheres`, `52 homens / 53 mulheres`, `54 homens / 55 mulheres`, matching R's `V550`/`V551`/`V552`/`V553`/`V554`/`V555` **exactly**.

**There is no swapped pair and no off-by-one anywhere in the 1980 block.** All 456 code→label pairs in the population block and all 94 in the households block bind the label the dictionary binds.

---

## Verdict

**PASS** (CRITICAL = 0, MAJOR = 0, MINOR = 5) - *revised after data verification: the MAJOR was
falsified. See the section at the end.* ~~REVISE (CRITICAL = 0, MAJOR = 1, MINOR = 5)~~

---

## Scorecard

- Variables labelled in R (population): **58** (55 via `if ('X' %in% cols)`, 3 via the `across()` at `:4163`)
- Variables labelled in R (households): **18** (15 via `if`, 3 via the `across()` at `:1525`)
- Distinct variables reconciled: **58**
- Code→label pairs reconciled: **456** (population) / **94** (households)
- Variables reconciled **MATCH** (no finding): **53**
- Variables with a finding: **5** (`V516`, `V517`, `V524`, `V536`, `V541` — all MINOR; `V524`/`V536` are stale *comments* only, their labels MATCH)
- CRITICAL / MAJOR / MINOR: **0 / 0 / 5 raised, 0 open** *(all fixed — see "Fixes applied" at the end)* *(post-verification; was 0 / 1 / 5 - the MAJOR was falsified)*
- Labels in R with no documented code: **0**
- Documented codes missing from R: **0**
- Documented categoricals unlabelled: **10** (9 correctly so; **1 is the MAJOR**)
- Findings struck in self-check: **11**

---

## Findings

### [MAJOR] `V2` (UF) — the note's justification for leaving the UF unlabelled fails for code `20`, Fernando de Noronha

- **Code:** `R/add_labels_population.R:3211` — `# and the geography codes V2-V6, which censobr already provides as names.` (same claim at `R/add_labels_households.R:1302`). `V2` is labelled in neither block.
- **Dictionary:** `dict1980_PESS.txt:4-34` / `dict1980_DOMI.txt:4-34` — `=== VAR: 2`, `META: DESDE=1 TAM=2 F=N CATEG=27`, *"UF do Questionário"*, with **27 numbered codes** including `dict1980_PESS.txt:14` — **`20- Fernando de Noronha`**.
- **The substitute:** `data_prep/R/add_geography_cols.R:50` maps `year == 1980 ~ 'V2'` into `code_state`, then `:57-85` builds `name_state` and `:88-117` `abbrev_state`. Both lists jump **`16 ~ 'Amapá'` (`:63`) → `17 ~ 'Tocantins'` (`:64`) → `21 ~ 'Maranhão'` (`:65`)** — there is **no `code_state == 20` arm** — and both close with `.default = NA` (`:85`, `:117`). So the one 1980 UF that no longer exists as a separate unit returns `name_state = NA`, `abbrev_state = NA`, and because `V2` is deliberately left raw the user has no labelled fallback.
- **Also wrong in the other direction:** `17 ~ 'Tocantins'` is in the 1980 list although Tocantins was created in 1988 — harmless, but it shows the list is the modern UF set, not the 1980 territorial division the dictionary documents. This is the 1980 analogue of the 1960 `Roraima`/`Rio Branco` finding, except here a category is actually **lost**, not merely renamed.
- **Why it matters:** the NOTE tells the next maintainer `V2` needs no labelling because censobr already renders it. For 26 of 27 codes that is true; for `20` the user gets `NA` from `name_state` *and* a bare `"20"` from `V2`.
- **Caveat on the evidence:** `data_prep/` is legacy and `.Rbuildignore`d (CLAUDE.md); the live pipeline is `ipea/censobr_prep_data`. The finding is grounded in the only pipeline code present in this repo. **Verify first:** `read_population(1980, columns = c('V2','name_state','abbrev_state')) |> dplyr::count(V2, name_state) |> dplyr::collect()`
- **Fix (either):** (a) add `code_state == 20 ~ 'Fernando de Noronha'` / `~ 'FN'` to `add_geography_cols()` in `ipea/censobr_prep_data`; or (b) label `V2` in the 1980 block from the dictionary's 27-code list and soften the NOTE to `# and the geography codes V3-V6, which censobr already provides as names.`

---

### [MINOR] `V516` / `V517` code `6` — `'De 6 a 9 anos'` adds a word neither source has

- **Code:** `R/add_labels_population.R:3614` — `V516 == '6' ~ 'De 6 a 9 anos',` and `:3634` — `V517 == 6 ~ 'De 6 a 9 anos',`
- **Dictionary:** `dict1980_PESS.txt:94` — `6- 6 a 9 anos` (`VAR 516`); `VAR 517` is `RENO=516`, the same list.
- **Questionnaire:** long form, quesito **16** (crop `q16b.png`) — `0 Menos de 1 ano · 1 1 ano · 2 2 anos · 3 3 anos · 4 4 anos · 5 5 anos · 6 **6 a 9 anos** · 7 10 anos ou mais · 8 Nasceu`. Quesito **17** identical.
- **Why it matters:** every other bracket in the same `case_when()` is transcribed verbatim (`'Menos de 1 ano'`, `'10 anos ou mais'`, `'Nasceu'`), so the added `De ` is not sentence-case normalisation — it is the only editorial addition in the block, against a NOTE (`:3200`) that claims *"transcribed … normalised to sentence case"*.
- **Fix:** `V516 == '6' ~ '6 a 9 anos',` and `V517 == 6 ~ '6 a 9 anos',`

### [MINOR] `V541` — the comment claims questionnaire wording; codes 1, 2 and 5 are paraphrases

- **Code:** `R/add_labels_population.R:3884` — `# NA ULTIMA SEMANA (25 A 31/08/1980) ESTAVA (wording from questionnaire item 41)`, then `:3889` `'Só exercendo a ocupação habitual'`, `:3890` `'Exercendo a ocupação habitual e outra(s)'`, `:3893` `'Tinha-se aposentado e não trabalhava'`.
- **Questionnaire:** long form, quesito **41** (crop `q41b.png`), verbatim: `1X Só exercendo a ocupação do Quesito 30` · `2X Exercendo a ocupação do Quesito 30 e outra(s) ocupação(ões)` · `3 Só exercendo ocupação diferente da habitual` · `4X Desempregado procurando trabalho` · `5X Tinha-se aposentado e não **trabalhou**` · `6X Não tinha trabalho nem estava procurando`. Codes 3, 4, 6 in R are exact; 1, 2, 5 are not.
- **Dictionary:** `dict1980_PESS.txt:337-346` — `1- só em um trabalho`, `2- vários trabalhos`, `3- trabalhando diferenciado`, `4- procurando trabalho`, `5- aposentou-se`, `6- não trabalhava nem procurava` (terse; R correctly preferred the questionnaire).
- **Assessment:** the *bindings* are right and the "ocupação do Quesito 30" → "ocupação habitual" paraphrase is substantively correct (quesito 30 is *"a ocupação … que exerceu habitualmente nos últimos 12 meses"*). Only the verbatim claim, and the tense of code 5, are wrong.
- **Fix:** `V541 == 5 ~ 'Tinha-se aposentado e não trabalhou',` and amend the comment to `# ... (wording adapted from questionnaire item 41; "a ocupação do Quesito 30" rendered as "a ocupação habitual")`.

### [MINOR] `V524` — stale comment: neither 1980 dictionary in this repo points `V524` at `V521`

- **Code:** `R/add_labels_population.R:3731-3733` — *"The dictionary as first published pointed to the categories of V521, but the questionnaire (item 24) and the observed distribution use a different coding, which is what is used here."*
- **Dictionary:** `dict1980_PESS.txt:175-187` — `=== VAR: 524`, `META: … CATEG=9` (**no `RENO`**), *"Grau da última série concluída com aprovação:"* followed by its **own** 9-code list: `0- nenhum / 1- curso de alfabetização de adultos / 2- primário ou elementar / 3- ginasial ou médio 1º ciclo / 4- 1º grau / 5- 2º grau / 6- colegial ou médio 2º ciclo / 7- superior / 8- mestrado ou doutorado`. Re-read cell-by-cell from the **unformatted** file (sheet `population`, row 109) — identical, `RENO = NA`. This matches `R:3738-3746` exactly, and matches questionnaire quesito **24** (`0 Nenhum · 1 Curso de Alfabetização de adultos · 2 Primário ou Elementar · 3 Ginasial ou Médio 1.º ciclo · 4 1.º Grau · 5 2.º Grau · 6 Colegial ou Médio 2.º ciclo · 7 Superior · 8 Mestrado ou Doutorado`).
- **Why it matters:** the comment tells a reviewer the code deliberately diverges from `data_dictionary(1980, "population")`. It does not — they agree. A maintainer "restoring" the dictionary's coding would be chasing a contradiction that no longer exists.
- **Fix:** `# GRAU DA ULTIMA SERIE CONCLUIDA COM APROVACAO (dictionary VAR 524, CATEG=9; agrees with questionnaire item 24)`.

### [MINOR] `V536` — same stale comment: neither dictionary points `V536` at `V533`

- **Code:** `R/add_labels_population.R:3849-3853` — *"The dictionary as first published pointed to the categories of V533 (posicao), which is wrong; the questionnaire (item 36) codes the brackets 4, 5, 6, 7 and 0 …"*
- **Dictionary:** `dict1980_PESS.txt:353-362` — `=== VAR: 536`, `META: … CATEG=6` (**no `RENO`**), *"Horas trabalhadas em todas as ocupações:"* `4- menos de 15 horas / 5- de 15 a 29 horas / 6- de 30 a 39 horas / 7- de 40 a 48 horas / 0- de 49 horas e mais / 9- sem declaração`. Unformatted file, sheet `population`, row 211 — identical, `RENO = NA`.
- **Questionnaire:** quesito **36** (crop `q33_36.png`) — `4 Menos de 15 horas · 5 15 a 29 horas · 6 30 a 39 horas · 7 40 a 48 horas · **0** 49 horas ou mais`. The second half of the comment is **correct and worth keeping** — the unusual `…7, 0` bracket is exactly what the box prints, and it is the one place a reader would suspect a typo.
- **Fix:** keep the questionnaire sentence, drop the first clause: `# ... the questionnaire (item 36) and the dictionary (VAR 536, CATEG=6) both code the brackets 4, 5, 6, 7 and 0. Stored as a number in this release.`

### [MINOR] The block NOTE mis-files `V518`/`V527` and `V605`

- **Code:** `R/add_labels_population.R:3206-3210` — *"Variables whose categories live in the dictionary's auxiliary files (V211 …, V512 …, **V518/V527 UF e municipio**, V525 …, V530/V542 …, V532/V544 …, V606 idade) are left as codes, as are the numeric variables (V212, V213, V602-V613, **V605 idade em meses**, V557, V570, ids)"*.
- **Dictionary:** `V518` (`dict1980_PESS.txt:105-108`, `TAM=6`) and `V527` (`:211-214`, `TAM=6`) carry **no `CATEG` at all** and no *"Ver pasta de Variáveis Auxiliares"* line — they are 6-digit UF+município identifiers, not auxiliary-file category lists (contrast `V512`, `dict1980_DOMI.txt:400-404`: `CATEG=98` + *"Ver pasta de Variáveis Auxiliares"*). `V605` (`dict1980_DOMI.txt:335-350`) is `CATEG=12` with an **explicit inline 12-code list** (`0- 0 meses` … `11- 11 meses`) — a documented categorical, not a `Valor` field; and `data_prep/R/microdata_sample_1980.R:171-173` does **not** include `V605` in `num_vars`, so it is a string in the file, not a number.
- **Why it matters:** unlike the 1960 note, this one *is* exhaustive — cross-checked against the dictionary, **every** unlabelled variable in the 1980 population block (`V2`–`V6`, `V601`, `V602`, `V211`–`V213`, `V603`–`V613`, `V512`, `V518`, `V525`, `V527`, `V530`, `V532`, `V542`, `V544`, `V557`, `V570`) is accounted for. That accuracy is worth preserving; two entries are filed under the wrong heading.
- **Fix:** *"… are left as codes, as are the 6-digit UF+município identifiers V518/V527, the numeric variables (V212, V213, V602-V604, V606-V613, V557, V570, ids), and V605 (idade em meses, whose 12 categories are just the month count)."*

---

## Reconciliation table

`Q` = corroborated against a rendered questionnaire crop. `dict` = the `=== VAR:` line in the dump. `n` = number of numbered codes. `CATEG ✓` = `CATEG` equals `n` + (1 if the block ends in an unnumbered `- não aplicável` line).

### `R/add_labels_population.R:3196-4178`

| VAR | R lines | codes in R | n in dict | dict | CATEG | verdict |
|---|---|---|---|---|---|---|
| `V198` | 3214-3224 | 1,3,5,7 | 4 | DOMI:271 | 4 ✓ | **MATCH** (Q p.1 *SITUAÇÃO*) |
| `V201` | 3227-3237 | 1,3,5,7 | 4 | DOMI:61 | 4 ✓ | **MATCH** (Q quesito 1) |
| `V202` | 3240-3248 | 1,3 | 2 | DOMI:70 | 2 ✓ | **MATCH** (Q quesito 2) |
| `V203` | 3251-3264 | 2,4,6,7,8,0,9 | 7 | DOMI:77 | 8 ✓ | **MATCH** (Q quesito 3, crop `h345`) |
| `V204` | 3267-3281 | 1,3,4,6,7,8,0,9 | 8 | DOMI:90 | 9 ✓ | **MATCH** (Q quesito 4 — the irregular 1,3,4,6,7,8,0 set is exactly what the boxes print) |
| `V205` | 3284-3299 | 1,2,3,4,5,6,7,0,9 | 9 | DOMI:104 | 10 ✓ | **MATCH** (Q quesito 5) |
| `V206` | 3302-3315 | 1,3,5,6,7,0,9 | 7 | DOMI:119 | 8 ✓ | **MATCH** — R's `'outra forma'` is the **questionnaire's** word (quesito 6, crop `h69`); the dict's `outro` is the abbreviation |
| `V207` | 3318-3330 | 2,4,6,0,8,9 | 6 | DOMI:134 | 7 ✓ | **MATCH** (Q quesito 7) |
| `V208` | 3333-3343 | 1,3,8,9 | 4 | DOMI:146 | 5 ✓ | **MATCH** (Q quesito 8) |
| `V209` | 3346-3359 | 1,3,5,6,7,0,9 | 7 (2 rows) | DOMI:156+163 | 8 ✓ | **MATCH** — both duplicated rows reconciled; `'Cedido por empregador'` = Q's bracket header *"Cedido por"* + box *"Empregador"* |
| `V214` | 3362-3373 | 1,3,5,8,9 | 5 | DOMI:195 | 6 ✓ | **MATCH** (Q quesito 14, crop `h1415`) |
| `V215` | 3376-3391 | 1,2,3,4,5,6,7,8,9 | 9 | DOMI:206 | 10 ✓ | **MATCH** (Q quesito 15) |
| `V216` | 4163-4177 (`across`) | 1,8,9 | 3 | DOMI:221 | 4 ✓ | **MATCH** (Q quesito 16 TELEFONE) |
| `V217` | 3394-3404 | 2,4,8,9 | 4 | DOMI:230 | 5 ✓ | **MATCH** (Q quesito 17) |
| `V218` | 4163-4177 (`across`) | 1,8,9 | 3 (RENO 216) | DOMI:240 | 4 ✓ | **MATCH** (Q quesito 18 RÁDIO) |
| `V219` | 4163-4177 (`across`) | 1,8,9 | 3 (RENO 216) | DOMI:245 | 4 ✓ | **MATCH** (Q quesito 19 GELADEIRA) |
| `V220` | 3407-3418 | 1,3,5,8,9 | 5 | DOMI:250 | 6 ✓ | **MATCH** (Q quesito 20) |
| `V221` | 3421-3431 | 1,3,8,9 | 4 | DOMI:261 | 5 ✓ | **MATCH** (Q quesito 21) |
| `V598` | 3434-3442 | 0,1 | 2 | DOMI:290 | 2 ✓ | **MATCH** (derived recode; no questionnaire item) |
| `V501` | 3445-3453 | 1,3 | 2 | DOMI:297 | 2 ✓ | **MATCH** (Q quesito 1) |
| `V503` | 3456-3472 | 0-9 | 10 | DOMI:304 | 10 ✓ | **MATCH** — code 5 `'Genro, nora ou outro parente'` corroborated by the short form (crop `sq3`), where **four** boxes share code 5: *Genro ou nora / Neto / Irmão ou cunhado / Outro parente* |
| `V504` | 3475-3491 | 0-9 | 10 (RENO 503) | DOMI:319 | 10 ✓ | **MATCH** (Q quesito 4) |
| `V505` | 3494-3506 | 0-5 | 6 | DOMI:324 | 6 ✓ | **MATCH** (Q quesito 5) |
| `V508` | 3509-3525 | 0-9 | 10 | DOMI:358 | 10 ✓ | **MATCH** (Q quesito 8 is a *Código* box; dict governs) |
| `V509` | 3528-3539 | 2,4,6,8,9 | 5 | DOMI:373 | 5 ✓ | **MATCH** (Q quesito 9: 2 Branca · 4 Preta · 6 Amarela · 8 Parda) |
| `V510` | 3542-3552 | 1,3,5,9 | 4 | DOMI:383 | 4 ✓ | **MATCH** (Q quesito 10) |
| `V511` | 3555-3564 | 2,4,6 | 3 | DOMI:392 | 3 ✓ | **MATCH** on codes; see Open Question 2 on the word order of code 4 |
| `V513` | 3567-3575 | 1,8 | 2 | PESS:56 | 3 ✓ | **MATCH** (Q quesito 13) |
| `V514` | 3578-3588 | 2,4,6,9 | 4 | PESS:64 | 5 ✓ | **MATCH** (Q quesito 14: *"Só na Zona Urbana"* — R follows the questionnaire, dict abbreviates) |
| `V515` | 3591-3601 | 1,3,8,9 | 4 | PESS:74 | 5 ✓ | **MATCH** (Q quesito 15) |
| `V516` | 3604-3620 | 0-9 | 10 | PESS:84 | 11 ✓ | **MINOR** — code 6 `'De 6 a 9 anos'` |
| `V517` | 3624-3640 | 0-9 (**numeric**) | 10 (RENO 516) | PESS:100 | 11 ✓ | **MINOR** — same; numeric comparison verified correct (struck finding 5) |
| `V519` | 3643-3653 | 2,4,6,9 | 4 | PESS:110 | 5 ✓ | **MATCH** (Q quesito 19) |
| `V520` | 3656-3672 | 0-9 | 10 | PESS:120 | 11 ✓ | **MATCH** (Q quesito 20) |
| `V521` | 3675-3691 | 0-9 | 10 | PESS:136 | 11 ✓ | **MATCH** (Q quesito 21, incl. the *Supletivo* 6/7 pair) |
| `V522` | 3694-3710 | 0-9 | 10 | PESS:152 | 11 ✓ | **MATCH** (Q quesito 22 — R correctly rejoins the dict's line-wrapped `5-`/`6-` labels) |
| `V523` | 3713-3729 | 0-9 | 10 (RENO 520) | PESS:170 | 11 ✓ | **MATCH** (Q quesito 23) |
| `V524` | 3734-3749 | 0-8 | 9 | PESS:175 | 9 ✓ | **MATCH** on labels; **MINOR** on the comment at `:3731-3733` |
| `V526` | 3752-3768 | 0-9 | 10 | PESS:195 | 11 ✓ | **MATCH** (Q quesito 26 splits at "vive / não vive em companhia de cônjuge" exactly at codes 4/5) |
| `V528` | 3771-3780 | 1,3,5 | 3 (2 rows) | PESS:216+221 | 3 ✓ | **MATCH** — code 5 *"frente da seca"* is microdata-only (Q quesito 28 prints only 1 Sim / 3 Não); dictionary governs |
| `V529` | 3783-3799 | 0-9 | 10 | PESS:229 | 10 ✓ | **MATCH** (Q quesito 29, crop `q29b`) |
| `V533` | 3802-3818 | 0-9 | 10 | PESS:274 | 10 ✓ | **MATCH** (Q quesito 33, incl. the *volante* 1/2 and *parceiro/meeiro* 3/4/5 brackets) |
| `V534` | 3821-3832 | 2,4,6,8,9 | 5 | PESS:289 | 5 ✓ | **MATCH** (Q quesito 34 — crop `q33_36` confirms the last box is **8** *Não é*, not 0) |
| `V535` | 3835-3847 | 1,2,3,4,5,9 | 6 | PESS:299 | 6 ✓ | **MATCH** (Q quesito 35) |
| `V536` | 3854-3866 | 4,5,6,7,0,9 (**numeric**) | 6 | PESS:353 | 6 ✓ | **MATCH** on labels (Q quesito 36 prints 4,5,6,7,**0**); **MINOR** on the comment at `:3849-3853` |
| `V540` | 3869-3882 | 0,2,3,4,5,6,9 | 7 | PESS:325 | 7 ✓ | **MATCH** — the gap at code 1 is real (Q quesito 40: 2 "12" · 3 "13" · 4 "14" · 5 "15" · 6 "16 e mais" · 0 "Não é Empregado") |
| `V541` | 3885-3897 | 1-6 | 6 | PESS:337 | 6 ✓ | **MINOR** — codes 1, 2, 5 paraphrased, comment claims verbatim |
| `V545` | 3900-3916 | 0-9 | 10 (RENO 533) | PESS:379 | — | **MATCH** (Q quesito 45 repeats quesito 33's layout box-for-box) |
| `V550` | 3919-3943 | 0-15,98,99 | 18 | PESS:404 | 18 ✓ | **MATCH** (Q quesitos 50/51 = homens/mulheres) |
| `V551` | 3946-3970 | 0-15,98,99 | 18 | PESS:427 | 18 ✓ | **MATCH** |
| `V552` | 3973-3991 | 0-9,98,99 | 12 | PESS:450 | 12 ✓ | **MATCH** (Q quesitos 52/53) |
| `V553` | 3994-4012 | 0-9,98,99 | 12 | PESS:467 | 12 ✓ | **MATCH** |
| `V554` | 4015-4039 | 0-15,98,99 | 18 | PESS:484 | 18 ✓ | **MATCH** (Q quesitos 54/55) |
| `V555` | 4042-4066 | 0-15,98,99 | 18 | PESS:507 | 18 ✓ | **MATCH** (code 0 fixes the dict typo *"sem filha vivas"*) |
| `V556` | 4069-4091 | 0-12,20,98,99 | 16 | PESS:530 | 16 ✓ | **MATCH** (incl. `20 ~ 'Presumida'`, `99 ~ 'Ignorada'` — feminine, as the dict has it) |
| `V680` | 4094-4114 | 0-12,99 | 14 (RENO 681) | PESS:310 | — | **MATCH** |
| `V681` | 4117-4137 | 0-12,99 | 14 | PESS:244 | 14 ✓ | **MATCH** |
| `V682` | 4140-4160 | 0-12,99 | 14 (RENO 681) | PESS:348 | — | **MATCH** |

### `R/add_labels_households.R:1293-1540`

The block's claim — *"Identical to the household variables of the 1980 block in add_labels_population()"* (`:1298-1299`) — was **verified literally**. Extracting `R/add_labels_population.R:3213-3432` + `:4162-4177` and `R/add_labels_households.R:1304-1539`, stripping leading whitespace, yields **236 lines each, `diff`-identical** (including the `across()` helper `tem_vars_1980`). Unlike 1960, where `censobr_diag_households` was implemented differently, here there is **zero divergence**.

| VAR | R lines | verdict |
|---|---|---|
| `V198`, `V201`–`V209`, `V214`, `V215`, `V217`, `V220`, `V221` | 1305-1522 | **identical to the population block** — inherits **MATCH** on all 15 |
| `V216`, `V218`, `V219` | 1525-1539 (`across`) | **identical** — **MATCH** |

---

## Unlabelled documented categoricals

| VAR | dict | `CATEG` | codes | why it probably matters |
|---|---|---|---|---|
| `V2` UF do Questionário | DOMI:4 / PESS:4 | 27 | 11…53, incl. **20 Fernando de Noronha** | **THE MAJOR.** Left to `name_state`/`abbrev_state`, whose only visible implementation drops code 20 |
| `V211` Tempo de Residência | DOMI:179 | 115 | *"Ver pasta Variáveis Auxiliares"* | correctly left: a 115-entry printed lookup, and cast to numeric by the pipeline |
| `V512` UF/País de nascimento | DOMI:400 | 98 | *"Ver pasta de Variáveis Auxiliares"* | correctly left (Q quesito 12 is a *Código* box) |
| `V605` Idade em meses | DOMI:335 | 12 | `0- 0 meses` … `11- 11 meses` | correctly left in substance — the labels are the month count itself — but the NOTE files it as "numeric", which the pipeline contradicts (MINOR above) |
| `V606` Idade em anos | DOMI:352 | 132 | *"Ver pastas de Variáveis Auxiliares"* | correctly left; cast to numeric by the pipeline |
| `V525` Tipo do último curso | PESS:189 | 97 | *"Ver pasta de Variáveis Auxiliares"* | correctly left (Q quesito 25 *Código*) |
| `V530` Ocupação (habitual) | PESS:263 | 366 | occupational classification | correctly left (Q quesito 30 *Código*) |
| `V532` Ramo do negócio | PESS:268 | 166 | *"Ver pasta de Variáveis Auxiliares"* | correctly left (Q quesito 32 *Código*) |
| `V542` Ocupação não habitual | PESS:369 | — (RENO 530) | as `V530` | correctly left (Q quesito 42 *Código*) |
| `V544` Ramo não habitual | PESS:374 | — (RENO 532) | as `V532` | correctly left (Q quesito 44 *Código*) |

**Both directions otherwise close exactly.** There is no variable labelled in R that the dictionary does not document, no documented numbered code missing from R, and no `Valor`/`Texto` variable labelled as categorical. The 1980 dictionary documents **no `censobr_*` variables at all** (96 VAR rows across both sheets, none prefixed `censobr_`) and the 1980 blocks label none — unlike 1960, there is nothing in that family to reconcile.

---

## Open questions for the maintainer

1. **Do the two-digit code fields carry leading zeros in the parquet?** `V550`–`V556`, `V680`, `V681`, `V682` are all `TAM=2` and are matched as **unpadded strings** (`V681 == '0'` … `'9'`, then `'10'`, `'11'`, `'12'`, `'99'`). If the file stores the raw 2-character fields (`'00'`…`'09'`), every single-digit arm silently becomes `NA` — which for `V681` would null the bottom ten of thirteen income brackets. This cannot be settled from the documentation, and the 1980 tests only pin `TAM=1` variables (`tests/testthat/test_read_population.R:112,116-117` → `V509`, `V536`; `tests/testthat/test_read_households.R:102,105-106` → `V203`, `V220`), so the case is untested. Note the sibling comment at `test_read_population.R:119` explicitly records *"1991 labels: codes are strings **without leading zeros**"* while the 1980 comment at `:110` says only *"codes are strings"*. Settle with `read_population(1980, columns = 'V681') |> dplyr::count(V681) |> dplyr::collect()` — and pin the result as a test assertion either way.

2. **`V511` code 4: `'Brasileiro naturalizado'` (dictionary) or `'Naturalizado brasileiro'` (questionnaire)?** Genuine source conflict, same shape as the 1960 `V208` MINOR. `dict1980_DOMI.txt:397` reads `4- brasileiro naturalizado`; questionnaire quesito 11 (crop `q11b.png`) prints **`Naturalizado brasileiro`**. Unlike 1960, the 1980 dictionary entry is **not** corrupt, and the string R uses is the house rendering across three census years (`R/add_labels_population.R:2459` 1960 `V208`, `:2903` 1970 `V029`, `:3560` 1980 `V511`). Recommendation: **leave as is** for cross-year consistency — but it is an editorial call, so it is recorded here rather than filed as a finding.

3. **Does the 1980 *households* parquet carry the person columns that the dictionary's `households` sheet documents?** Because `DOMI`/`households` is the first 76 bytes of the person record, it documents `V598`, `V501`, `V503`, `V504`, `V505`, `V605`, `V606`, `V508`–`V512` at positions 60–76. `add_labels_households()` labels none of them, and its NOTE (`:1300-1302`) enumerates only `V211`, `V212`, `V213`, `V602`, `V603`, `V601` and `V2`–`V6` as deliberately unlabelled. If those columns are absent from the file (which `data_prep/R/microdata_sample_1980.R:83` suggests — the households branch casts only `V602`, `V211`, `V212`, `V213`, `V603`, with no `V604`/`V605`/`V606`) then both the code and the NOTE are complete. If they are present, `read_households(1980)` returns raw codes for nine categoricals that `read_population(1980)` labels. Settle with `names(read_households(1980))`.

---

## Self-check — candidate findings struck before reporting (11)

1. **"`V206` codes 5 and 0 say `'outra forma'` where the dictionary says `outro`."** Struck: the questionnaire (quesito 6, crop `h69.png`) prints **`Outra forma`** under both box 5 and box 0. R follows the questionnaire; `dict1980_DOMI.txt:126,130` abbreviates.
2. **"`V209` code 6 `'Cedido por empregador'` adds a word to the dictionary's `cedido empregador`."** Struck: quesito 9 prints the bracket header **`Cedido por`** spanning boxes `6 Empregador` and `7 Particular`.
3. **"`V503` code 5 `'Genro, nora ou outro parente'` adds `parente` to the dictionary's `genro, nora ou outro`."** Struck: the short form's quesito 3 (crop `sq3.png`) shows four boxes all coded **5** — *Genro ou nora*, *Neto*, *Irmão ou cunhado*, **`Outro parente`**.
4. **"`V534` code 8 is bound to the wrong integer — the questionnaire's `Não é` box looks like `0`."** Struck: a 2.5× crop of quesito 34 (`q33_36.png`) resolves the glyph as **8**, matching `dict1980_PESS.txt:296`.
5. **"Type mismatch: `V517` and `V536` are compared as integers while the other 56 variables are compared as strings — one of them must be nulling the whole column."** Struck, with two independent proofs: `tests/testthat/test_read_population.R:117` asserts `'De 49 horas e mais' %in% test1980$V536` **against the real parquet** (that label is reachable only via the numeric arm `V536 == 0`); and `data_prep/R/microdata_sample_1980.R:171-173` casts exactly `V602, V211, V212, V213, V603, V604, V606, V517, V607, V608, V536, V609-V613, V557, V570` with `as.numeric()` — i.e. the **only two labelled variables in the numeric list are `V517` and `V536`**, precisely as `R:3205-3206` claims. `grep "== [0-9]"` over `:3196-4178` returns arms for those two variables and nothing else.
6. **"No `.default` / `TRUE ~` arm, so the `- não aplicável` category documented on 19 variables is silently dropped."** Struck: the `- não aplicável` line is **unnumbered** in every case (it *is* the NA state), and the questionnaire's skip rule on page 1 — *"(Os Quesitos seguintes só para domicílios particulares permanentes)"* — explains exactly why `V203`–`V221` carry it and `V198`/`V201`/`V202` do not. No year block anywhere in `R/add_labels_*.R` uses a default arm.
7. **"`all_of()` and `case_when()` are unqualified at `:4169-4170` / `:1531-1532` while the rest of the block uses `dplyr::`."** Struck: `NAMESPACE:16-22` imports `across, all_of, case_when, mutate, select` from dplyr.
8. **"`V680`/`V681`/`V682` pluralise the dictionary's `Salário Mínimo`."** Struck: the dictionary's singular is ungrammatical (`6- mais de 1 a 2 Salário Mínimo`), the numeric brackets are transcribed exactly, and the normalisation is applied identically across all three variables.
9. **"`V555` code 0 `'Sem filha viva'` contradicts the dictionary's `sem filha vivas`."** Struck: dictionary typo (`dict1980_PESS.txt:511`); `V550`/`V551`/`V554` all use the grammatical singular.
10. **"`V216`, `V218`, `V219` are documented categoricals the block never labels."** Struck: they are labelled in the `across()` at `:4162-4177` (and `:1524-1539`), which an `if ('X' %in% cols)` inventory misses. The Rádio/Geladeira assignment is corroborated by the questionnaire's quesito numbering.
11. **"The duplicated `209` and `528` dictionary rows are two distinct entries and R reconciles only the first."** Struck: both are printed-text continuations of a single variable (NOME split for `528`, code list split for `209`), `CATEG` is identical on both rows of each pair, and R labels the full union (7 and 3 codes).

---

**Bookend.** Goal: a complete, evidence-backed, two-directional reconciliation of every 1980 code→label pair in `add_labels_population()` and `add_labels_households()` against the IBGE data dictionary and the CD 1.01 / CD 1.02 questionnaires, with no file under `R/` edited. Met: 58/58 labelled variables reconciled, 456 + 94 code→label pairs checked against both sources with the `CATEG` arithmetic closing on every one; 0 codes in R the dictionary does not document and 0 documented codes missing from R; 10 unlabelled documented categoricals enumerated (9 correctly left alone, 1 raised as the MAJOR); the households block's duplication claim verified by `diff`; 0 CRITICAL, 1 MAJOR, 5 MINOR, each with both sides quoted; 11 candidate findings struck as unsupported; 3 questions left open. No file under `R/` was modified.

---

## Data verification - run 2026-09-13 against data release **v0.7.0**

Every open question that needed the file was settled by reading the parquets through the
package's own `read_population()` / `read_households()` (dev source via `pkgload::load_all()`).
Script and full log: `scratchpad/verify_labels.R`, `scratchpad/verify_labels.log`.

### The MAJOR (`V2` / Fernando de Noronha) - **FALSIFIED. No defect.**

`count(V2, name_state, abbrev_state)` on `1980_population_v0.7.0.parquet` returns 27 rows, and row
seven is:

```
 V2          name_state abbrev_state     n
 20 Fernando de Noronha           FN   298
```

The live pipeline (`ipea/censobr_prep_data`, v0.7.0) **does** carry code 20, so the block NOTE's
justification for leaving `V2` unlabelled - *"censobr already provides [the geography codes] as
names"* - holds for all 27 codes. The finding rested on `data_prep/R/add_geography_cols.R`, which
has no `code_state == 20` arm; that copy is **legacy and `.Rbuildignore`d**, and is simply stale.
The audit flagged this caveat itself and asked for the check before acting - correctly.

The secondary observation dissolves too: `17 Tocantins` does **not** appear in the 1980 data, so
the anachronistic arm in the legacy list is unreachable rather than wrong in effect. **No change
to `R/`.**

### Open question 1 (leading zeros on `TAM=2` fields) - **CLOSED: codes are unpadded**

`V681`: `0` (10,094,128), `1`, `2`, ... `9`, `10`, `11`, `12`, `99`, `NA` - single-digit codes are
stored as one character. `V550` likewise (`0`, `1`, ... `15`, `99`). The block's assumption is
verified, and the untested case is now pinned: `tests/testthat/test_read_population.R` asserts
`'Sem renda' %in% test1980$V681`, reachable only through `V681 == '0'`.

### Open question 3 (does the households file carry the person columns?) - **CLOSED: it does not**

`names(read_households(1980))` returns 38 columns: the 9 geography columns, `V198`, `V2`-`V6`,
`V201`-`V209`, `V211`-`V221`, `V601`-`V603`. **No `V5xx` person variable is present**, so both the
households block and its NOTE are complete as they stand.

---

## Fixes applied — 2026-09-13 (plan: `quality_reports/plans/synthetic-dancing-hippo.md`)

Both sides were corrected together, ahead of retiring the served HTML dictionaries in favour
of `[year]_dictionary_microdata_formatted.xlsx`. Every edit is traceable to this year's
questionnaire; where the questionnaire is silent the dictionary governed and the labels
followed it. Verified: workbook structure unchanged (dimensions, merged ranges, fonts, cell
counts, per-cell line counts), both R files parse, the new strings come back from the v0.7.0
parquets, and every touched label now matches its dictionary line.

### Dictionary — `1980_dictionary_microdata_formatted.xlsx` (11 line edits)

| Sheet/cell | Was | Now | Authority |
|---|---|---|---|
| DOMI B14 · `V206` | codes 5 and 0 end `outro` | `outra forma` | quesito 6 prints "Outra forma" |
| DOMI B44 · `V511` | `4- brasileiro naturalizado` | `4- naturalizado brasileiro` | quesito 11 |
| PESS B26 · `V681` | codes 6-12 `… Salário Mínimo` | `… Salários Mínimos` | grammar: the brackets are plural |
| PESS B52 · `V555` | `0- sem filha vivas` | `0- sem filha viva` | grammar; siblings use the singular |

### Labels

- `V516` / `V517` code 6 → `'6 a 9 anos'` (both sources read exactly that; `De ` was the block's only
  editorial addition)
- `V541` code 5 → `'Tinha-se aposentado e não trabalhou'` (quesito 41 box 5), and its comment now
  discloses that codes 1/2 render the form's "a ocupação do Quesito 30" as "a ocupação habitual"
- `V524` and `V536` comments: the stale "the dictionary as first published pointed to V521 / V533"
  claims are gone — neither xlsx does, so a maintainer would have been chasing a contradiction that
  does not exist. `V536`'s useful half (the unusual `4,5,6,7,0` bracket really is what the box prints)
  is kept
- block NOTE: `V518`/`V527` re-filed as 6-digit UF+município identifiers and `V605` as a documented
  categorical stored as a string
- `V511` was fixed earlier under the cross-year policy

### Nothing open

The MAJOR was falsified by the data (the live pipeline does return `Fernando de Noronha` for
`V2 == 20`), and both remaining open questions were closed by the data verification.
