# 1970 Label Audit — `R/add_labels_population.R` + `R/add_labels_households.R` (38 variables reconciled)

Sources of authority used:

- **Dictionary A — "published"** (what a user actually gets today): `data_dictionary(1970, "population")` →
  `1970_dictionary_microdata_population.html`, and `data_dictionary(1970, "households")` →
  `1970_dictionary_microdata_households.html`, both from the fixed `censo_docs` release
  (`R/data_dictionary.R:117-124`). Downloaded during this audit; text dumps
  `scratchpad/d1970pop.txt` (276 rows) / `d1970hh.txt`.
- **Dictionary B — "corrected"**: the repo-root working files `1970_dictionary_microdata.xlsx`
  (sheets `population`/`households`) and `1970_dictionary_microdata_formatted.xlsx` (sheets
  `PESS`/`DOMI`); dumps `dict1970_PESS.txt` / `dict1970_DOMI.txt`. **The two xlsx are
  code-for-code identical to each other**, and both are untracked in git.
  **A and B are NOT the same document** — see MAJOR-1.
- **Questionnaire** — `1970_questionnaire_long.pdf` (**CD 1.01 — Boletim da Amostra**, 4 pp., the
  form the 25% sample microdata comes from) and `1970_questionnaire_short.pdf`
  (**CD 1.02 — Boletim da Não-Amostra**, 2 pp.). Both are scans with no text layer; every citation
  below was read off a rendered crop (`scratchpad/docs1970/*.png`).

Scope audited: `R/add_labels_population.R:2653-3195` (+ guard `:1-30`) and
`R/add_labels_households.R:1131-1292`. `grep` over `R/add_labels_*.R` confirms **no other file has a
`# YEAR 1970` block** — `families` (2000/2022), `mortality` (2010/2022) and `emigration` (2010) do
not cover 1970.

---

## Verdict

**REVISE** (CRITICAL = 0, MAJOR = 2, MINOR = 7) - *both MAJORs are confirmed by the data and both
are **dictionary / pipeline-side**: no label in `R/` is wrong. See the section at the end.*

---

## Scorecard

- Variables labelled in R (population): **38** (33 via `if ('X' %in% cols)`, 5 via the `across()` block at `:3179-3193`)
- Variables labelled in R (households): **14** (9 via `if`, 5 via the `across()` at `:1276-1290`)
- Distinct variables reconciled: **38**
- Code→label pairs reconciled: **236** (population 182 + households 54), all by script, accent- and case-insensitive
- Variables whose full code→label map reconciles exactly against **Dictionary B + questionnaire**: **38 / 38**
- Variables carrying ≥ 1 finding of any severity: **13**
- CRITICAL / MAJOR / MINOR: **0 / 1 / 7 raised, 2 open** *(MAJOR-1 resolved on the dictionary side; see "Fixes applied" at the end)* *(post-verification: both MAJORs confirmed and
  both upstream - 0 label-side MAJORs. Closed since: V029 word order and V004 Urbana/Suburbana fixed)*
- Documented categoricals unlabelled: **1** (`V006`, households only)
- Labels in R with no documented code: **0** (7 inferred `0 = Sem declaração` arms are backed by `CATEG` arithmetic — see struck finding 2)
- Findings struck in self-check: **9**

### The structural key for 1970 (validates every code value)

**In 1970 the microdata code is the number printed inside the questionnaire box**, restarting at each
question (unlike 1960, where it was the *last digit* of a running box number — that key does **not**
apply here; I tested it and it fails immediately, e.g. item 4 runs 1…9 not 30…38).
Verified box-for-box on CD 1.01: item 2 sexo (0,1) · item 3 presença (0,1,2) · item 4 parentesco
(1-9) · item 7 religião (1-5) · item 8 nacionalidade (0,1,2) · items 11/12 tempo de residência (1-8) ·
item 14 situação anterior (1,2) · items 15/16 (1,2) · item 17 série (1-9,0) and grau (1-5) ·
item 19 estado conjugal (1-9) · item 22 situação de emprego (0-7) · item 25 posição (1-6) ·
item 26 (1-5) · item 27 (1-9) · item 28 (1-3) · and the whole *CARACTERÍSTICAS DO DOMICÍLIO* strip
(família 0-4, espécie 0/1, tipo 0/1/2, ocupação 1-5, aluguel 1-9, tempo 1-6, água 1-5, sanitárias 1-5,
luz/rádio/geladeira/TV/automóvel 1/2, fogão 1-6) and the SITUAÇÃO box (0/1/2).
Code `0 = Sem declaração` never has a printed box — it is an editing code, exactly as the dictionary
implies. **Every code→label binding in the R block reproduces this key. There is no swapped pair and
no off-by-one anywhere in the 1970 block** — including the nine variables where the *published*
dictionary disagrees (MAJOR-1), all nine of which R resolves in the questionnaire's favour.

---

## Findings

### [MAJOR-1] The dictionary censobr actually ships for 1970 contradicts these labels for **9 population variables + 1 household variable** — including one where all 10 codes are shifted

- **Code:** `R/add_labels_population.R:2655-2656` — the block NOTE states labels are *"transcribed from
  the 1970 population dictionary, `data_dictionary(1970, "population")`"*. For these variables they are
  not; they are transcribed from an unpublished corrected dictionary.
- **Dictionary A (published, `1970_dictionary_microdata_population.html`, what `data_dictionary()`
  opens):**

  | VAR | published dictionary says | R label (`R/add_labels_population.R`) | questionnaire (CD 1.01) |
  |---|---|---|---|
  | `V031` | `0- MENOS DE 1 ANO` … `7- DE 11 ANOS E MAIS`, `8- FRENTE DE SECA`, `9- NÃO APLICÁVEL` | `:2918-2927` `1 ~ 'Menos de 1 ano'` … `8 ~ 'De 11 anos e mais'`, `9 ~ 'Frente de seca'`, `0 ~ 'Não aplicável'` | item 11 boxes numbered **1-8** |
  | `V035` | `0- SIM`, `1- NÃO`, `2- SEM DECLARAÇÃO` | `:2974-2976` `1 ~ 'Sim'`, `2 ~ 'Não'`, `0 ~ 'Sem declaração'` | item 15 boxes **1 Sim / 2 Não** |
  | `V036` | `0- SIM`, `1- NÃO`, `2- SEM DECLARAÇÃO` | `:2987-2989` same shape as V035 | item 16 boxes **1 Sim / 2 Não** |
  | `V040` | `1- CASAMENTO NO CIVIL` | `:3035` `'Casamento civil e religioso'` | item 19 box **1 "Casamento civil e religioso"** |
  | `V034` | `2- POVOADO RURAL 1`, `8- POVOADO RURAL 2`, `9- POVOADO RURAL 3` | `:2960-2962` `'Povoado ou zona rural'` ×3 | item 14 box **2 "Povoado ou Zona Rural"** (only 2 options) |
  | `V025` | `8- EMRPEGADO DOMÉSTICO`, `9- MEMBRO GRUPO-CONVIDADO` | `:2861-2862` `'Empregado doméstico'`, `'Individual (em domicílio coletivo)'` | item 4 box **9 "Individual (Em domicílio coletivo)"** |
  | `V037` | `1- 1ª SERIE DO ELEMENTAR` | `:2999` `'Cursa a 1ª série do elementar (nenhuma série concluída)'` | item 17 box **1 "Cursa 1.º elementar"**, box 2 "1.ª série" |
  | `V038` | `3- GINASIAL/MEDIO 2º CICLO` | `:3021` `'Médio 2º ciclo'` | item 17 Grau box **3 "Médio 2.º ciclo"** |
  | `V010` | header `(SALÁRIO MÍNIMO VIGENTE NA ÉPOCA: CR$36.161,60)`; `1- ATÉ 15 SALÁRIOS MÍNIMOS` … `8- DE 961 SALÁRIOS MÍNIMOS E MAIS` | `:2737-2744` `'Até 15'` … `'De 961 e mais'` | household strip item 5 header **"Aluguel mensal (NCr$)"**, brackets "Até 15", "De 16 a 30", … |
  | `V010` (households) | same as above, `1970_dictionary_microdata_households.html` | `R/add_labels_households.R:1198-1205` | idem |

- **Dictionary B (corrected, repo-root xlsx):** agrees with the R labels in **all ten** rows above.
  A scripted diff of published vs. corrected finds differences in **exactly these 9 + 1 variables and
  nowhere else** — the other 44 population variables and 27 household variables are identical.
- **Assessment:** the R labels are **right** and Dictionary A is **wrong**. The questionnaire settles
  every case: box numbering is the 1970 code (see the structural key above); `V031`/`V032` ask the
  identical question at UF and município level with identically numbered boxes, yet Dictionary A codes
  `V032` 1-8,0 and `V031` 0-9 — self-contradictory; Dictionary A gives `V040` codes 1 and 2 the same
  meaning ("casamento no civil" / "casamento só no civil"); `V037` code 1 in Dictionary A duplicates
  code 2; and a 1970 rent of "up to 15 minimum wages" is not a category anyone would print.
- **Why it matters:** a user who opens `data_dictionary(1970, "population")` — which the block NOTE
  itself tells them to do — gets a code map that is incompatible with what
  `read_population(1970, add_labels = "pt")` returns. For `V031` **every one of the 10 codes** differs;
  for `V035`/`V036` "Sim" and "Não" are one code apart, so a user cross-tabulating raw codes against
  labelled output will silently mis-read literacy and school attendance. This is the single most
  damaging 1970 issue and it is *not* in `R/`.
- **Fix (outside `R/`, in `ipea/censobr_prep_data`):** publish the corrected dictionary —
  re-render `1970_dictionary_microdata_population.html` / `_households.html` from the repo-root
  `1970_dictionary_microdata.xlsx` and re-upload to the `censo_docs` release tag.
  **Fix (inside `R/`, until that is done):** amend the NOTE at `:2655-2656` to read
  *"…transcribed from the corrected 1970 dictionary. The dictionary currently served by
  `data_dictionary(1970, "population")` still carries IBGE's original transcription errors in V010,
  V025, V031, V034, V035, V036, V037, V038 and V040; where it disagrees, the questionnaire (CD 1.01)
  was followed — see the comment on each variable."*

### [MAJOR-2] `V006` (condição da família) is documented for the households file but not labelled there

- **Code:** `R/add_labels_households.R:1131-1292` — no `if ('V006' %in% cols)` guard exists.
  The block NOTE `:1137-1140` explains: *"V006 (condicao da familia) is not labelled: in the
  households file it is a per-dwelling average of the person-level codes and takes ~260 distinct
  values. V004 also carries a few dozen fractional averages, which become NA."*
- **Dictionary:** both `1970_dictionary_microdata_households.html` (published) and
  `dict1970_DOMI.txt` VAR `V006` document it as a 5-category variable —
  `0- PESSOA SÓ`, `1- ÚNICA`, `2- PRINCIPAL`, `3- SECUNDÁRIO PARENTE`, `4- SECUNDÁRIO NÃO PARENTE`
  (`CATEG=5` on the PESS sheet). It is the **only** documented categorical in the `DOMI` sheet that R
  leaves untouched; the population block labels it at `:2680-2691`.
- **Questionnaire:** CD 1.01, *CARACTERÍSTICAS DO DOMICÍLIO*, item 1 "Família" — boxes
  `1 Única`, `0 Individual`, and under the brace *Convivente*: `2 Principal`, `3 Parente`, `4 Não parente`.
  So the census collected it **once per dwelling**, not per person.
- **Why it matters:** either branch is a user-facing defect. If the comment is right, censobr ships a
  households dictionary that describes a 5-category variable while the file stores a dwelling-level
  mean — and nothing but an R comment says so. If the comment is stale, a documented categorical
  silently comes back as bare integers.
- **Needs data verification** — the 1970 parquet was not downloaded for this audit, per instructions.
  Settle it with: `read_households(1970) |> dplyr::count(V006) |> dplyr::collect()`
- **Fix (if the comment is right):** the aggregation is the bug, not the label — recompute `V006` in
  `censobr_prep_data` as the dwelling's own code (the questionnaire shows one box per dwelling), then
  add the same guard the population block uses. Failing that, document the departure where users will
  see it (roxygen `@details` / the `documentation` vignette), not only in a code comment.
  **Fix (if `V006` is in fact integral 0-4):** copy `R/add_labels_population.R:2680-2691` verbatim into
  the households block.

---

### [MINOR-1] `V024` code 2 — `'Não morador'` drops the questionnaire's `presente`

- **Code:** `R/add_labels_population.R:2842` — `V024 == 2 ~ 'Não morador'`
- **Dictionary:** `dict1970_PESS.txt` VAR `V024` — `2- NÃO MORADOR` (published dictionary identical)
- **Questionnaire:** CD 1.01 **item 3, "Condição de presença"**, box 2 is captioned over two lines:
  *"Não morador **presente**"* (boxes 0 "Presente" and 1 "Ausente" sit under a second caption
  *"Morador"*). **CD 1.02 item 3 prints the same three captions.**
- **Why it matters:** "não morador" alone reads as *excluded from the household*; the actual category
  is a visitor **present on census night** — that is what distinguishes code 2 from code 1
  (*morador ausente*). The 1960 block has the identical defect (`V202` codes 5/6), flagged in the 1960
  audit, so fixing both keeps the two blocks consistent.
- **Fix:** `V024 == 2 ~ 'Não morador presente'`

### [MINOR-2] `V029` code 1 — word order differs from both questionnaires

- **Code:** `R/add_labels_population.R:2903` — `V029 == 1 ~ 'Brasileiro naturalizado'`
- **Dictionary:** VAR `V029` — `1- BRASILEIRO NATURALIZADO` (published identical)
- **Questionnaire:** CD 1.01 **item 8, "Nacionalidade"**, box 1 — *"Naturalizado brasileiro"*
  (CD 1.02 item 7 is identical). Boxes 0 and 2 read "Brasileiro nato" / "Estrangeiro", which R
  transcribes exactly.
- **Why it matters:** the questionnaire is the authority on a category's substantive wording, and both
  1970 forms print the two words the other way round. This is the **same finding the 1960 audit raised
  for `V208`** — the two blocks should be fixed together or neither.
- **Fix:** `V029 == 1 ~ 'Naturalizado brasileiro'` — *and* decide it jointly with 1960 `V208`
  (see Open Questions).

### [MINOR-3] `V006` codes 3 and 4 — `Secundária` where every source says `SECUNDÁRIO`

- **Code:** `R/add_labels_population.R:2687-2688` —
  `V006 == 3 ~ 'Secundária parente'`, `V006 == 4 ~ 'Secundária não parente'`
- **Dictionary:** `dict1970_PESS.txt` / `dict1970_DOMI.txt` and both published HTMLs —
  `3- SECUNDÁRIO PARENTE`, `4- SECUNDÁRIO NÃO PARENTE`
- **Questionnaire:** CD 1.01 household strip item 1 "Família" — boxes 3 and 4 are captioned
  *"Parente"* / *"Não parente"* under the brace *Convivente*; the word "secundári-" appears on neither form.
- **Why it matters:** these are the only two labels in the entire 1970 block whose wording is not
  attested in any source (a scripted comparison of all 236 code→label pairs flags exactly these two,
  plus the deliberate `esgosto→esgoto` typo repair). The declared house style is "normalised to
  sentence case"; a gender change is not case normalisation.
- **Fix:** `V006 == 3 ~ 'Secundário parente'`, `V006 == 4 ~ 'Secundário não parente'`

### [MINOR-4] `V004` — `Urbano/Suburbano` contradicts the questionnaire and breaks with every other year block

- **Code:** `R/add_labels_population.R:2672-2673` and `R/add_labels_households.R:1147-1148` —
  `V004 == 0 ~ 'Urbano'`, `V004 == 1 ~ 'Suburbano'`, `V004 == 2 ~ 'Rural'`
- **Dictionary:** VAR `V004` — `0- URBANO`, `1- SUBURBANO`, `2- RURAL` (R transcribes it faithfully;
  the code binding is correct)
- **Questionnaire:** the **SITUAÇÃO** box in the header of *both* forms (CD 1.01 and CD 1.02) prints
  `Urbana [ ]0`, `Suburbana [ ]1`, `Rural [ ]2` — feminine, agreeing with *situação*.
- **Sibling blocks:** `R/add_labels_population.R:26-27` (2010 `V1006`) `'Urbana'/'Rural'`;
  `:79-80` (2022 `P0140`) `'Urbana'/'Rural'`; `:2354-2356` (1960 `V118`)
  `'Urbana'/'Suburbana'/'Rural'`; `R/add_labels_families.R:59-60`, `R/add_labels_mortality.R:62-63`
  likewise feminine. Only 1970 (`:2672`) and 1980 (`:3438`) use the masculine.
- **Why it matters:** a user stacking census years on this variable gets `'Urbana'` for 1960/2000/2010/2022
  and `'Urbano'` for 1970 — two distinct strings for one category. Note this pulls **against** the 1960
  audit's recommendation (which proposed `'Suburbana' -> 'Suburbano'` to match the 1960 dictionary);
  the two years cannot both be "fixed" toward their own dictionaries and also be consistent.
- **Fix:** a maintainer's editorial call — see Open Questions. Either
  `V004 == 0 ~ 'Urbana', V004 == 1 ~ 'Suburbana'` in both files (questionnaire + house style), or keep
  the masculine and drop the 1960 audit's `V118` recommendation.

### [MINOR-5] `V037` code 1 is the one repair of the published dictionary that carries **no** comment

- **Code:** `R/add_labels_population.R:2999` —
  `V037 == 1 ~ 'Cursa a 1ª série do elementar (nenhuma série concluída)'`,
  with **no comment** above the `if ('V037' %in% cols)` guard at `:2995`.
- **Dictionary A (published):** `1- 1ª SERIE DO ELEMENTAR` — i.e. *completed* the first grade, which
  duplicates code 2 (`2- 1ª SERIE`). **Dictionary B (corrected):** `1- CURSA A 1ª SÉRIE DO ELEMENTAR
  (NENHUMA SÉRIE CONCLUÍDA)`.
- **Questionnaire:** CD 1.01 item 17, row *Série* — box 1 reads *"Cursa 1.º elementar"*, box 2 reads
  *"1.ª série"*. The questionnaire decisively supports R.
- **Why it matters:** the block NOTE at `:2657-2659` promises *"where the two disagree the comment on
  the variable says which was used"*. Eight of the nine repairs listed in MAJOR-1 keep that promise
  (`:2731`, `:2847`, `:2909`, `:2950`, `:2967`, `:2981`, `:3013`, `:3029`); `V037` is the only one that
  does not — and it is a *meaning reversal* (attending vs. completed), not a spelling fix.
- **Fix:** add a two-line comment above `:2995` stating that code 1 is "Cursa 1.o elementar" in
  questionnaire item 17 (no series completed), and that the dictionary as first published printed
  "1a serie do elementar", duplicating code 2.

### [MINOR-6] `V010` — the labels drop the currency unit, and the only dictionary a user can open names the wrong one

- **Code:** `R/add_labels_population.R:2737-2744` / `R/add_labels_households.R:1198-1205` —
  `'Até 15'`, `'De 16 a 30'`, … `'De 961 e mais'`
- **Dictionary A (published, both sheets):** `ALUGUEL OU PRESTAÇÃO MENSAL (SALÁRIO MÍNIMO VIGENTE NA
  ÉPOCA: CR$36.161,60)`, `1- ATÉ 15 SALÁRIOS MÍNIMOS`, … — **Dictionary B:** `(EM NCr$)`, `1- ATÉ 15`.
- **Questionnaire:** CD 1.01 household strip, **item 5 — "Aluguel mensal (NCr$)"**, brackets
  `1 Até 15`, `2 De 16 a 30`, … `8 De 961 e mais`, `9 Não paga aluguel`. The unit is on the question
  header, not on the individual boxes.
- **Why it matters:** a bare `'Até 15'` is uninterpretable on its own, and the document censobr ships
  today tells the user it means *15 minimum wages*. Until MAJOR-1 is fixed, the labels and the
  dictionary are read together and produce a wildly wrong magnitude.
- **Fix:** put the unit in the label (e.g. `V010 == 1 ~ 'Até 15 NCr$'`, … `8 ~ 'De 961 NCr$ e mais'`),
  or at minimum state it in the roxygen `@details`.
- **Also:** the two comments describing the same fact disagree in tense —
  `R/add_labels_population.R:2732` says *"the dictionary **as first published** called them 'salarios
  minimos'"* while `R/add_labels_households.R:1193` says *"the dictionary header **calls** them
  'salarios minimos'"*. As of today the households phrasing is the accurate one (MAJOR-1); align them.

### [MINOR-7] `V025` code 4 — `Pais e sogros` where the questionnaire prints `Pais ou Sogros`

- **Code:** `R/add_labels_population.R:2857` — `V025 == 4 ~ 'Pais e sogros'`
- **Dictionary:** VAR `V025` — `4- PAIS E SOGROS` (published identical); R transcribes it faithfully.
- **Questionnaire:** CD 1.01 item 4, box 4 — *"Pais ou Sogros"* (CD 1.02 identical).
- **Why it matters:** lowest-stakes finding in this report — the conjunction is the only difference and
  the extension of the category is unchanged. Recorded only because the block NOTE undertakes to flag
  dictionary-questionnaire divergences, and this one is unflagged.
- **Fix:** leave the label (dictionary governs) and, if any comment is added for `V025`'s other
  divergences, mention it there. Do not patch silently.

---

## Reconciliation table

`Q` = corroborated box-for-box against CD 1.01. `A` = published dictionary, `B` = corrected repo-root
xlsx. Dictionary codes shown in dictionary order. All 236 pairs were also compared by script
(accent- and case-insensitive); the script's only flags are the two `V006` strings, the deliberate
`esgosto -> esgoto` repair, and the seven inferred `0 = Sem declaração` arms.

### `R/add_labels_population.R:2653-3195` — PESS sheet (38 variables)

| VAR | R lines | codes in R | codes in dict | verdict |
|---|---|---|---|---|
| `V004` | 2668-2677 | 0,1,2 | 0,1,2 (A=B) | **MINOR-4** (`Urbano` vs Q "Urbana"); codes exact |
| `V006` | 2680-2691 | 0,1,2,3,4 | 0,1,2,3,4 (A=B) | **MINOR-3** (`Secundária`); Q item 1 confirms codes |
| `V007` | 2694-2702 | 0,1 | 0,1 + unnumbered `NÃO APLICAVEL` (A=B, `CATEG=2`) | **MATCH** — the unnumbered line is the NA state and is correctly unlabelled `Q` |
| `V008` | 2705-2714 | 0,1,2 | 0,1,2 (A=B) | **MATCH** `Q` |
| `V009` | 2717-2729 | 1,2,3,4,5,0 | same (A=B) | **MATCH** `Q` (item 4: Próprio -> Já pago / Em aquisição) |
| `V010` | 2733-2749 | 1-9,0 | A: `… SALÁRIOS MÍNIMOS`; B: bare brackets | **MAJOR-1 + MINOR-6**; codes exact `Q` |
| `V011` | 2752-2765 | 1-6,0 | 0,1-6 (A=B; order only) | **MATCH** `Q` (item 6) |
| `V012` | 2768-2780 | 1,2,3,4,5,**0** | 1-5 + unnumbered `SEM DECLARAÇÃO` (A=B, `CATEG=6`) | **MATCH** — code 0 inferred, arithmetic-backed (struck finding 2). Q item 7 prints code 2 as "Com canalização **externa**"; the dictionary's "sem canalização interna" is the same category |
| `V013` | 2783-2795 | 1,2,3,4,5,0 | same (A=B) | **MATCH** — R repairs the dictionary typo `ESGOSTO`->`esgoto`; Q item 8 "Rêde geral" |
| `V014` | 3179-3193 (`across`) | 1,2,**0** | 1,2 + unnumbered (A=B, `CATEG=3`) | **MATCH** (inferred 0) `Q` |
| `V015` | 2798-2811 | 1-6,**0** | 1-6 + unnumbered (A=B, `CATEG=7`) | **MATCH** (inferred 0) `Q` item 10 |
| `V016` `V017` `V018` `V019` | 3179-3193 (`across`) | 1,2,**0** | 1,2 + unnumbered (A=B, `CATEG=3`) | **MATCH** (inferred 0) `Q` items 11-14 |
| `V022` | 2814-2822 | 0,1 | 0,1 (A=B) | **MATCH** (no questionnaire box; editing code) |
| `V023` | 2825-2833 | 0,1 | 0,1 (A=B) | **MATCH** `Q` item 2 (0 Homem / 1 Mulher — confirmed on both forms) |
| `V024` | 2836-2845 | 0,1,2 | 0,1,2 (A=B) | **MINOR-1** (`presente` dropped); codes exact `Q` |
| `V025` | 2850-2866 | 1-9,0 | A: `8- EMRPEGADO`, `9- MEMBRO GRUPO-CONVIDADO`; B = R | **MAJOR-1 + MINOR-7**; codes exact `Q` item 4 |
| `V026` | 2869-2880 | 0,1,2,3,4 | same (A=B) | **MATCH** (derived from items 5/6; no boxes) |
| `V028` | 2883-2895 | 1-5,0 | same (A=B) | **MATCH** `Q` item 7 |
| `V029` | 2898-2907 | 0,1,2 | 0,1,2 (A=B) | **MINOR-2** (word order vs Q item 8); codes exact |
| `V031` | 2914-2930 | 1-8,9,0 | A: **shifted 0-9**; B = R | **MAJOR-1**; R's coding confirmed by Q item 11 and by `V032` |
| `V032` | 2933-2948 | 1-8,0 | same (A=B) | **MATCH** `Q` item 12 |
| `V034` | 2954-2965 | 0,1,2,8,9 | A: `POVOADO RURAL 1/2/3`; B = R | **MAJOR-1**; Q item 14 has exactly two options, codes 1 and 2 |
| `V035` | 2970-2979 | 1,2,0 | A: **shifted** (0=Sim); B = R | **MAJOR-1**; Q item 15 boxes 1 Sim / 2 Não |
| `V036` | 2983-2992 | 1,2,0 | A: **shifted**; B = R | **MAJOR-1**; Q item 16 boxes 1 Sim / 2 Não |
| `V037` | 2995-3011 | 1-9,0 | A: code 1 differs; B = R | **MAJOR-1 + MINOR-5**; Q item 17 (Série) boxes 1-9,0 |
| `V038` | 3015-3027 | 1-5,0 | A: code 3 `GINASIAL/MEDIO 2º CICLO`; B = R | **MAJOR-1**; Q item 17 (Grau) boxes 1-5 |
| `V040` | 3031-3047 | 1-9,0 | A: code 1 `CASAMENTO NO CIVIL`; B = R | **MAJOR-1**; Q item 19 boxes 1-4 (vive com cônjuge) + 5-9 |
| `V042` | 3050-3061 | 1,2,3,4,0 | same (A=B) | **MATCH** (code 0 is an editing code; R transcribes the dictionary's "…, mas trabalha e estuda" verbatim) |
| `V043` | 3064-3078 | 0-7 | same (A=B) | **MATCH** `Q` item 22 (codes 0-7; Q prints code 7 as "Trabalha ou Procura trabalho", the dictionary adds "e sem declaração") |
| `V046` | 3081-3094 | 1-6,0 | same (A=B) | **MATCH** `Q` item 25 |
| `V047` | 3097-3109 | 1-5,0 | same (A=B) | **MATCH** `Q` item 26 (box 5 "Procurando trabalho pela 1.ª vez") |
| `V048` | 3113-3129 | 1-9,0 | same (A=B) | **MATCH** `Q` item 27 — the two sub-rows (months for agropecuária, hours otherwise) explain the mixed units; R's comment says so |
| `V049` | 3132-3142 | 1,2,3,0 | same (A=B) | **MATCH** `Q` item 28 |
| `V051` | 3145-3161 | 0-9 | same (A=B) | **MATCH** `Q` item 30 (box "0 Não teve"); code 9 = Ignorado, and R's comment says so |
| `V052` | 3164-3175 | 0,1,2,3,9 | same (A=B) | **MATCH** `Q` item 31 |

### `R/add_labels_households.R:1131-1292` — DOMI sheet (14 variables)

The block's own claim — *"identical to the household variables of the 1970 block in
`add_labels_population()`"* (`:1133-1136`) — was **verified literally**: extracting every
`if ('X' %in% cols)` guard and every `X == n ~ 'label'` pair for the 14 shared variables from both
files yields **72 lines each, `diff`-identical**. Only the prose differs (MINOR-6, last bullet).

| VAR | R lines | verdict |
|---|---|---|
| `V004` `V007` `V008` `V009` `V010` `V011` `V012` `V013` `V015` | 1143-1272 | **identical to population block** — inherits its verdicts (`V004` MINOR-4, `V010` MAJOR-1 + MINOR-6, rest MATCH) |
| `V014` `V016` `V017` `V018` `V019` | 1276-1290 (`across`) | **identical to population block** — MATCH (inferred 0) |
| `V006` | *absent* | **MAJOR-2** |

---

## Unlabelled documented categoricals

| VAR | dict sheet | codes | why it probably matters |
|---|---|---|---|
| `V006` | `DOMI` (households) | `0- PESSOA SÓ`, `1- ÚNICA`, `2- PRINCIPAL`, `3- SECUNDÁRIO PARENTE`, `4- SECUNDÁRIO NÃO PARENTE` | The only documented categorical in either sheet with no mapping. See **MAJOR-2** — the code comment says the households file stores a per-dwelling mean, which the dictionary does not mention anywhere a user can see. |

Both directions close otherwise:

| sheet | documented categoricals (>=1 numbered code) | labelled in R | gap |
|---|---|---|---|
| `PESS` (population) | 38 | 38 | **0** |
| `DOMI` (households) | 15 | 14 | **1** |

There is **no variable labelled in R that the dictionary does not document**, and **no `Valor`
variable labelled as categorical**. The block NOTE at `:2660-2665` enumerating the deliberate
omissions is **complete** (unlike its 1960 counterpart): the 7 auxiliary-file variables it names
(`V027` idade, `V030` naturalidade, `V033` UF anterior, `V039` curso, `V044` ocupação, `V045`
atividade, `V050` filhos nascidos vivos) and the 6 numeric ones (`V005`, `V020`, `V021`, `V041`,
`V053`, `V054`) plus the geography codes `V001`-`V003` account for **all 16** non-categorical PESS
variables, with nothing left over. The `DOMI` sheet's 13 non-categorical variables
(`V001`-`V003`, `V020`, `V021`, `weight_household`, `numb_dwellers`, `numb_dwellers_hhincome`,
`hh_income`, `hh_income_per_cap`, `code_muni1970`, `code_muni`, `household_id`) are likewise all
correctly left alone. **1970 has no `censobr_*` derived variables** — neither dictionary sheet
documents any, and the R block labels none. The `abbrev_state` column that
`tests/testthat/test_read_population.R:103` selects for 1970 is present in the data but documented in
neither sheet; it already carries names, and the block NOTE says so.

---

## Open questions for the maintainer

1. **MAJOR-1 is a `censobr_prep_data` action, not an `R/` edit.** Is the repo-root
   `1970_dictionary_microdata.xlsx` (untracked, corrected) the intended replacement for the
   `censo_docs` HTML? If so it needs uploading; until then `data_dictionary(1970, …)` and
   `add_labels` contradict each other for 10 variables, and the `V031` / `V035` / `V036` shifts are
   the kind of thing that ends up in someone's published table. A NEWS bullet would also be warranted.

2. **MAJOR-2 / `V006` in the households file.** Does `count(V006)` return 5 integral values or ~260?
   The answer picks the fix (label it, fix the aggregation upstream, or document it publicly).
   The same question applies, less urgently, to the "few dozen fractional averages" the comment
   attributes to households `V004`, which *are* labelled.

3. **`Urbana` vs `Urbano` across years (MINOR-4) — a genuine conflict between two audits.** The 1970
   questionnaire prints the feminine, the 1970 dictionary the masculine; 1960/2000/2010/2022 all use
   the feminine while 1970/1980 use the masculine. The 1960 audit proposed moving 1960 *toward* the
   masculine to match its dictionary. One policy has to win: dictionary-faithful per year, or one
   string per concept across years. This is an editorial call, not an auditor's.

4. **`Naturalizado brasileiro` (MINOR-2) recurs in 1960 (`V208`).** Both dictionaries invert the
   questionnaire's word order; both R blocks follow the dictionary. Fix both or neither.

5. **The questionnaire's skip patterns have no "Não aplicável" code.** CD 1.01 gates items 15-17 with
   *"SÒMENTE PARA AS PESSOAS DE 5 ANOS E MAIS"*, items 18-28 with *"…DE 10 ANOS E MAIS"* and
   items 29-32 with *"SÒMENTE PARA AS MULHERES DE 15 ANOS E MAIS"*, yet the dictionary offers no
   not-applicable category for `V035`-`V049`, `V051`, `V052` — only `0- SEM DECLARAÇÃO`. If IBGE
   coded the skipped population as `0`, then `'Sem declaração'` is being shown to millions of
   under-5s and under-10s who were never asked. (`V031`/`V032`/`V034` *do* have an explicit
   `0- NÃO APLICÁVEL`, matching their own skip on item 10 — so the omission elsewhere is asymmetric.)
   A cross-tab of `V026`/`V027` against `V035` would settle it; if confirmed, those variables' code 0
   should read `'Não aplicável ou sem declaração'`.

6. **`V012` code 2 wording.** CD 1.01 item 7 prints *"Rêde geral — Com canalização **externa**"*;
   both dictionary versions say *"REDE GERAL SEM CANALIZAÇÃO INTERNA"*. Same category, opposite
   phrasing. R follows the dictionary (and matches 1960's `V105`), which I judge correct — flagged
   only so the divergence is on record.

---

## Self-check — findings struck before reporting (9)

1. **"Nine `# … the dictionary as first published …` comments state a disagreement the shipped
   dictionary does not exhibit — stale comments."** Struck, and it inverted into MAJOR-1: I had only
   compared against the two repo-root xlsx. Downloading the actual published
   `1970_dictionary_microdata_population.html` from the `censo_docs` release showed **every one of
   those claims is true** (`0- MENOS DE 1 ANO` for `V031`, `MEMBRO GRUPO-CONVIDADO` for `V025`,
   `SALÁRIOS MÍNIMOS` for `V010`, `POVOADO RURAL 1/2/3` for `V034`, `0- SIM` for `V035`/`V036`,
   `GINASIAL/MEDIO 2º CICLO` for `V038`, `CASAMENTO NO CIVIL` for `V040`). The comments are accurate;
   the *published document* is the problem.
2. **"`V012`, `V014`-`V019` label a code `0 = Sem declaração` that the dictionary never numbers."**
   Struck: `CATEG` counts it. `V012` has 5 numbered codes and `CATEG=6`; `V014`/`V016`-`V019` have 2
   and `CATEG=3`; `V015` has 6 and `CATEG=7`. Where the unnumbered line is *not* a real category the
   count excludes it — `V007` (2 numbered, `CATEG=2`, trailing `NÃO APLICAVEL`) and `V010`
   (10 numbered, `CATEG=10`, trailing duplicate `SEM DECLARAÇÃO 2`) — and R correctly leaves **those**
   unlabelled. Every 1970 variable that spells the code out uses `0` for *sem declaração* (V009, V011,
   V013, V028, V037, V038, V040, V042, V046, V047, V048, V049), and `TAM=1` leaves no other slot.
   R's inference is right in all seven cases and its restraint in the other two is right too.
3. **"Type mismatch: the block compares integers (`V023 == 1`) — if the parquet stores strings the
   whole year nulls out."** Struck: `grep "== '"` over `:2653-3195` and `:1131-1292` returns only the
   `lang == 'pt'` guard, so both blocks are 100% numeric and internally consistent; and
   `tests/testthat/test_read_population.R:102-108` asserts `'Sim'` (V035) and
   `'Casamento civil e religioso'` (V040), `tests/testthat/test_read_households.R:93-98` asserts
   `'Próprio já pago'` (V009) and `'Não tem'` (V019) — all read back from the **real 1970 parquet**.
   The "codes are stored as doubles" claim in both NOTEs is verified against data.
4. **"`V013 == 1 ~ 'Rede geral de esgoto'` contradicts the dictionary's `REDE GERAL DE ESGOSTO`."**
   Struck: `ESGOSTO` is a typo present in both dictionary versions; CD 1.01 item 8 prints
   *"Rêde geral"*. The repair is correct and is the only silent typo fix in the block.
5. **"No `.default` / `TRUE ~` arm, so undocumented codes are silently dropped to `NA`."** Struck:
   no year block anywhere in `R/add_labels_*.R` uses a default arm — house convention, correctly
   followed; and `V034`'s comment explicitly says codes 3-7 occur in the data and are intentionally
   left `NA`.
6. **"`V031` code 0 is labelled `Não aplicável` but the dictionary says `MENOS DE 1 ANO` — CRITICAL,
   all 10 codes shifted."** Struck *as a finding against `R/`*: the questionnaire's item 11 boxes are
   numbered 1-8 (the 1970 code = box number), `V032` asks the identical question with identical boxes
   and is coded 1-8,0 even in the published dictionary, and the corrected xlsx agrees with R.
   Re-filed as MAJOR-1, against the published document. Same treatment for `V035`, `V036`, `V040`,
   `V034`, `V025`, `V037`, `V038`, `V010`.
7. **"`V048` code 4 `De 9 a 12 meses` contradicts CD 1.01 item 27, which prints `9 meses e mais`."**
   Struck: within a 12-month reference period the two are the same set; codes 1-9 match box-for-box.
8. **"The population NOTE under-enumerates the variables deliberately left unlabelled (as the 1960
   NOTE did)."** Struck: scripted check — the NOTE's three lists cover all 16 non-categorical PESS
   variables exactly, with no omissions and no spurious entries.
9. **"`V042` code 0 `'Sem declaração, mas trabalha e estuda'` should read `ou estuda`."** Struck:
   both dictionary versions print `E`, R transcribes faithfully, and code 0 has no questionnaire box
   (it is an editing code), so there is no source to override the dictionary with.

---

**Bookend.** Goal: a complete, evidence-backed reconciliation of every 1970 code→label pair in
`add_labels_population()` and `add_labels_households()` against the IBGE dictionary and questionnaire,
in both directions, with no file under `R/` edited. Met: 38/38 documented PESS categoricals and 14/15
DOMI categoricals reconciled both ways (236 code→label pairs, script-verified), the 1970 structural
key (code = questionnaire box number) established and used to validate every code value, 0 CRITICALs,
2 MAJORs (a published dictionary that contradicts the labels for 10 variables; one unlabelled
documented categorical) and 7 MINORs, each with both sides quoted; 9 candidate findings struck as
unsupported — one of which inverted into the report's principal finding. No file under `R/` was
modified.

---

## Data verification - run 2026-09-13 against data release **v0.7.0**

Every open question that needed the file was settled by reading the parquets through the
package's own `read_population()` / `read_households()` (dev source via `pkgload::load_all()`).
Script and full log: `scratchpad/verify_labels.R`, `scratchpad/verify_labels.log`.

### MAJOR-1 - **CONFIRMED. The labels are right; the served dictionary is wrong.**

The observed distributions decide it, and not marginally:

| VAR | observed | under the labels in `R/` | under the **served** dictionary |
|---|---|---|---|
| `V035` alfabetizacao | `1` = 12,944,644 / `2` = 8,159,423 / `0` = 17,688 | 61 % literate, 0.08 % sem declaracao - matches the 1970 census | **17,688 literate people in Brazil**, and 8.2 M "sem declaracao" |
| `V036` frequenta escola | `1` = 5,253,816 / `2` = 15,850,741 / `0` = 17,198 | 25 % attending school | 17,198 attending school |
| `V031` tempo de residencia na UF | `8` = 5,424,528 / `9` = 55,421 / `0` = 5,562 | `8` = '11 anos e mais' (largest band), `9` = 'Frente de seca' (small) | `8` = 'Frente de seca' - 5.4 M people on drought relief |
| `V040` estado conjugal | `1` = 5,251,521 (largest union type) | 'Casamento civil e religioso' | 'Casamento no civil' only |
| `V010` aluguel | `9` = 19,535,351 | 'Nao paga aluguel' (owner-occupied majority) | same binding, but priced in *minimum wages* |

`V034` also shows codes 3-7 present with ~5 k records each, exactly as its in-code comment says
(intentionally left `NA`). **The fix is entirely upstream** - re-render
`1970_dictionary_microdata_{population,households}.html` from the corrected xlsx and re-upload to
the `censo_docs` tag. **Action taken in `R/`:** the 1970 block NOTE now carries a CAVEAT naming the
nine miscoded variables and citing the `V035` counts, so no future reader "restores" the served
dictionary's coding.

### MAJOR-2 `V006` in the households file - **the in-code comment is exactly right**

`count(V006)` on `1970_households_v0.7.0.parquet`: **259 distinct values**, and they are
dwelling-level *means*, not codes - `1.000000` (4,503,619), `1.400000`, `1.500000`, `1.571429`,
`2.086957`, `2.095238`, ... `V004` behaves the same way (21 distinct values: `0` = 2,596,121,
`1` = 107,603, plus fractions such as `0.3636364` and `0.9230769`).

So the code is right to leave `V006` unlabelled, and right about *why*. The defect is that censobr
**ships a households dictionary documenting `V006` as a 5-category variable that the households
file does not contain** - a data-prep/documentation mismatch, fixable only upstream. Copying the
population block's labels here, as the finding's second branch proposed, would have labelled
averages as categories.

---

## Fixes applied — 2026-09-13 (plan: `quality_reports/plans/synthetic-dancing-hippo.md`)

Both sides were corrected together, ahead of retiring the served HTML dictionaries in favour
of `[year]_dictionary_microdata_formatted.xlsx`. Every edit is traceable to this year's
questionnaire; where the questionnaire is silent the dictionary governed and the labels
followed it. Verified: workbook structure unchanged (dimensions, merged ranges, fonts, cell
counts, per-cell line counts), both R files parse, the new strings come back from the v0.7.0
parquets, and every touched label now matches its dictionary line.

### Dictionary — `1970_dictionary_microdata_formatted.xlsx` (9 line edits)

| Sheet/cell | Was | Now | Authority |
|---|---|---|---|
| DOMI B6, PESS B6 · `V004` | `0- URBANO` / `1- SUBURBANO` | `0- URBANA` / `1- SUBURBANA` | SITUAÇÃO box, both forms |
| DOMI B14, PESS B15 · `V013` | `1-REDE GERAL DE ESGOSTO` | `1-REDE GERAL DE ESGOTO` | item 8; plain typo |
| PESS B26 · `V024` | `2- NÃO MORADOR` | `2- NÃO MORADOR PRESENTE` | item 3 box 2 |
| PESS B27 · `V025` | `4- PAIS E SOGROS` | `4- PAIS OU SOGROS` | item 4 box 4 |
| PESS B31 · `V029` | `1- BRASILEIRO NATURALIZADO` | `1- NATURALIZADO BRASILEIRO` | item 8 box 1 |

**MAJOR-1 is resolved by this file becoming the published dictionary.** The nine miscoded variables
(`V010`, `V025`, `V031`, `V034`, `V035`, `V036`, `V037`, `V038`, `V040`) are miscoded only in the
retired HTML; this xlsx agrees with the labels and with the observed distributions. What remains is
the upstream release step (re-upload / retire the HTML), not a code or content defect.

### Labels

- `V006` codes 3/4 → `'Secundário (não) parente'` (the dictionary says SECUNDÁRIO; the questionnaire
  prints neither word, so the dictionary governs)
- `V024` code 2 → `'Não morador presente'`
- `V025` code 4 → `'Pais ou sogros'`
- `V010` codes 1-8 now carry the unit — `'Até 15 NCr$'` … `'De 961 NCr$ e mais'` — in **both** files;
  the dictionary header reads `(EM NCr$)` and the form `Aluguel mensal (NCr$)`, and a bare `'Até 15'`
  was uninterpretable
- `V037` gained the comment the block NOTE promises, naming the retired HTML's duplicate coding
- `V029`, `V004` were fixed earlier under the maintainer's cross-year policy

### Still open (2)

1. **MAJOR-2 `V006` in the households file** — the dictionary documents 5 categories; the parquet
   holds **259 dwelling-level means**. Needs a data-prep decision upstream (fix the aggregation, or
   footnote the variable in the dictionary). Not a text fix, so untouched here.
2. `V025` code 5 / general: nothing else outstanding; the remaining MINORs were all applied.
