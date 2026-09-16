# 1960 Label Audit — `R/add_labels_population.R` + `R/add_labels_households.R` (33 variables reconciled)

Sources of authority used:
- **Dictionary** — `1960_dictionary_microdata_formatted.xlsx`, sheets `PESS` (person record) and
  `DOMI` (household record); dumps `dict1960_PESS.txt` / `dict1960_DOMI.txt`.
- **Questionnaire** — `1960_questionnaire_long.pdf` (CD‑2, *Boletim de Amostra*) and
  `1960_questionnaire_short.pdf` (CD‑1, *Boletim Geral*). Both are scans with no text layer; every
  citation below was read off a rendered crop of the page image.

Scope audited: `R/add_labels_population.R:2131-2652` (+ guard `:1-30`) and
`R/add_labels_households.R:880-1130`. `grep` over `R/add_labels_*.R` confirms **no other file has a
`# YEAR 1960` block** — `families` (2000/2022), `mortality` (2010/2022) and `emigration` (2010) do
not cover 1960.

---

## Verdict

**PASS** (CRITICAL = 0, MAJOR = 0, MINOR = 10) - *revised after data verification; see the
section at the end.* ~~REVISE (CRITICAL = 0, MAJOR = 1)~~

---

## Scorecard

- Variables labelled in R (population): **33** (31 via `if ('X' %in% cols)`, 2 via the `across()` block)
- Variables labelled in R (households): **16**
- Distinct variables reconciled: **33**
- Variables reconciled **MATCH** (no finding): **24**
- CRITICAL / MAJOR / MINOR: **0 / 0 / 10 raised, 2 open** *(8 fixed — see "Fixes applied" at the end)* *(post-verification; was 0 / 1 / 9 - the MAJOR
  became a wording MINOR. Closed since: V208 word order fixed, V118 'Suburbana' dismissed by the
  maintainer's feminine-form policy)*
- Documented categoricals unlabelled: **0** (both sheets)
- Labels in R with no documented code: **1** (`V299 == 0`)
- Findings struck in self-check: **7**

**A structural key discovered while auditing, which validates almost every code value.** The 1960
microdata codes are the **last digit of the questionnaire's box number**. Item E (religion) runs
boxes 15…23 and the dictionary codes are 5,6,7,8,9,0,1,2,3; item T (income) runs 65…73 → 5,6,7,8,9,0,1,2,3;
item Z (position in occupation) runs 85…90 → 5,6,7,8,9,0. This holds for **every** categorical
variable checked (V101–V111, V202–V206, V208, V209, V299, V211–V213, V215, V219, V220, V223, V224),
and every one of those code→label bindings in R reproduces it exactly. There is **no swapped pair and
no off-by-one anywhere in the 1960 block.**

---

## Findings

### [MAJOR] V299 — code `0` is labelled but appears nowhere in the dictionary or the questionnaire

- **Code:** `R/add_labels_population.R:2493` — `V299 == 0 ~ 'Não se aplica (pessoas naturais do município)'`
- **Dictionary:** `dict1960_PESS.txt` VAR `V299` lists codes `2,3,4,5,6,7,8,9,1` only. Its final line,
  *"Não se aplica (Pessoas naturais do município) ou Informação Faltante (Registro Corrompido)"*, is
  **unnumbered**. Across this whole dictionary an unnumbered trailing line denotes the **NA / blank**
  state, never an integer code — cf. `V001` (*"Informação faltante - Amostra de 1,27%"*), `V102`
  (*"Não Aplicável (Domicílios Coletivos)…"*), `V211` (*"Não aplicável (4 anos de idade ou menos)…"*).
- **Questionnaire:** long form, row **I** (`rI` crop, page ≈ y 438–500). The row is gated by the side
  label *"SÒMENTE PARA AS PESSOAS QUE NÃO NASCERAM NESTE MUNICÍPIO"*. Its "Número de anos em que
  reside neste Município" boxes are **32–39** → last digits **2–9**. There is no box yielding a `0`
  for this question; the only `0` box in row I belongs to the *other* question on the same row
  (*"Se anteriormente residia em zona rural marque também [ ]0"*), which is **V209 code 0**.
- **Also:** the in-code justification (`:2478-2479`, "its count equals that of `V209 == 2`") does not
  support the label as written. `V209 == 2` is documented as *"pessoas nascidas na UF onde residem
  **ou marcados como não morador presente**"* — a strictly different population from *"pessoas
  naturais do município"*.
- **Why it matters:** if `0` is not in the file the arm is dead weight; if it *is* in the file and
  means something else (e.g. corrupted record), users are handed a confidently wrong category on a
  migration variable.
- **Needs data verification** — the 1960 parquet was not downloaded for this audit, per instructions.
  Settle it with:
  `read_population(1960) |> dplyr::count(V209, V299) |> dplyr::collect()`
- **Fix (if `0` is absent from the file, or if the cross-tab does not confirm the meaning):** delete
  line 2493 and the two-line comment at `:2478-2479`, letting `0` fall through to `NA` exactly as
  every other undocumented/NA state does in this block. **Fix (if confirmed):** keep the arm but
  correct the comment to cite the verified cross-tab, and align the wording with the dictionary's own
  text — `V299 == 0 ~ 'Não se aplica (pessoas naturais do município)'` is then right as written.

---

### [MINOR] V118 — `Suburbana` where both dictionary and questionnaire say `Suburbano`

- **Code:** `R/add_labels_population.R:2355` and `R/add_labels_households.R:1101` — `V118 == 3 ~ 'Suburbana'`
- **Dictionary:** `dict1960_PESS.txt` / `dict1960_DOMI.txt` VAR `V118` — `3- Suburbano`
- **Why it matters:** the declared house style for this block is "normalised to sentence case"; a
  gender change is not case normalisation, and it is the one label in the block altered without a
  source backing it. (`uf == 50 'Serra dos Aimorés'` looks like the same kind of change but *is*
  attested — see struck findings.)
- **Fix:** `V118 == 3 ~ 'Suburbano',` in both files.

### [MINOR] V208 — word order differs from the questionnaire

- **Code:** `R/add_labels_population.R:2459` — `V208 == 0 ~ 'Brasileiro naturalizado'`
- **Dictionary:** VAR `V208` — `0- Brasil Naturalizado` (evidently truncated)
- **Questionnaire:** long form row **H**, box **30** — *"Naturalizado brasileiro"* (identical in the
  short form).
- **Why it matters:** the questionnaire is the authority on a category's substantive wording and it
  reads the two words the other way round; the dictionary's version is corrupt, so R had to choose
  and chose neither source's wording.
- **Fix:** `V208 == 0 ~ 'Naturalizado brasileiro',`

### [MINOR] V202 — `não morador` drops the questionnaire's `presente`

- **Code:** `R/add_labels_population.R:2381-2382` — `'Homem não morador'` / `'Mulher não morador'`
- **Dictionary:** VAR `V202` — `5- Homem não Morador`, `6- Mulher não Morador`
- **Questionnaire:** long form row **B**, column heading over boxes 5/6 — *"Não morador **presente**"*
  (identical in the short form). The dictionary itself uses the full phrase when describing `V209`
  code 2: *"marcados como não morador **presente**"*.
- **Why it matters:** "não morador" alone reads as *excluded from the household*; the actual category
  is a visitor **present on census night** — the distinction that makes codes 5/6 different from
  codes 3/4 (*morador ausente*).
- **Fix:** `V202 == 5 ~ 'Homem não morador presente',` / `V202 == 6 ~ 'Mulher não morador presente'`

### [MINOR] V224 — `Membro da família` drops the questionnaire's `ou instituição`

- **Code:** `R/add_labels_population.R:2624` — `V224 == 0 ~ 'Membro da família'`
- **Dictionary:** VAR `V224` — `0- Membro da Família`
- **Questionnaire:** long form row **Z**, box **90** — *"Membro de família ou instituição"*
- **Why it matters:** the category covers unpaid workers in a family business *and* members of an
  institution; the shortened label silently narrows it.
- **Fix:** `V224 == 0 ~ 'Membro de família ou instituição',` (or keep the dictionary text and add
  the omission to the block comment).

### [MINOR] `uf` code 3 — `Roraima` is the post-1962 name of a territory called `Rio Branco` in 1960

- **Code:** `R/add_labels_population.R:2320` and `R/add_labels_households.R:1066` — `uf == 3 ~ 'Roraima'`
- **Dictionary:** VAR `uf` — `3- Roraima` (R transcribes it faithfully; the code binding is correct)
- **Questionnaire:** short form, *Código 1 — UNIDADES DA FEDERAÇÃO* (`short_uf` crop) lists
  `22 – Rio Branco`; `Roraima` does not appear anywhere in either questionnaire. The same list also
  carries `13 – Guaporé` and `13 – Rondônia` as aliases of one code, showing IBGE was still printing
  the pre-rename names in 1960.
- **Why it matters:** the block comment at `:2306` advertises this as "the 1960 territorial division",
  and every other entry in the list *is* a 1960 name. This is the only anachronism.
- **Fix:** either leave it (dictionary governs) and amend the comment, or
  `uf == 3 ~ 'Rio Branco (atual Roraima)',`. **Flag for the maintainer rather than patch silently** —
  see Open Questions.

### [MINOR] `censobr_diag_households` / `censobr_diag_persons` — code 2 label is abridged

- **Code:** `R/add_labels_population.R:2645` (inside the `across()` at `:2637-2651`) and
  `R/add_labels_households.R:1124` — `'Problema não corrigido, mas ignorável (valores inválidos marcados como missing)'`
- **Dictionary:** `dict1960_PESS.txt` VAR `censobr_diag_persons` — *"Problema não corrigido, mas
  ignorável: uma ou algumas variáveis apresentavam valores inválidos **(não listados no dicionário)**.
  Esses valores foram marcados como missing"*
- **Why it matters:** the abridgement drops the operational definition of "inválido" (= not listed in
  the dictionary), which is the only thing that tells a user what triggered the flag. This is a
  censobr-authored variable, so the dictionary text is censobr's own and a verbatim transcription was
  clearly intended.
- **Fix:** `~ 'Problema não corrigido, mas ignorável (valores inválidos, não listados no dicionário, marcados como missing)'`
  in both files.

### [MINOR] V215 — the block comment says code 9 uses the questionnaire wording; it does not

- **Code:** `R/add_labels_population.R:2546-2549` — *"the questionnaire (item P, codes 56-59) reads
  'Casamento civil e religioso / Somente casamento civil / Somente casamento religioso / **Outra**',
  which is what is used here."* But `:2557` is `V215 == 9 ~ 'Vivendo maritalmente'`.
- **Questionnaire:** long form row **P** (`rP` crop) — boxes `56 Casamento civil e religioso`,
  `57 Sòmente casamento civil`, `58 Sòmente casamento religioso`, `59 Outra`, under the stem *"Se vive
  em companhia de cônjuge — espôsa(o), companheira(o), consorte, etc. — indique a natureza da união"*.
- **Dictionary:** VAR `V215` — `6- Casamento Civil`, `7- Somente Casamento`, `8- Somente Casamento`,
  `9- Vivendo Maritalmente`.
- **Assessment:** the *labels* are right. The questionnaire cleanly resolves the dictionary's
  duplicated `Somente Casamento` for 7/8, and since box 59 sits under "vive em companhia de cônjuge",
  "Outra natureza da união" **is** a consensual union — the dictionary's `Vivendo Maritalmente` is the
  better substantive wording. Only the comment is wrong: 3 of the 4 questionnaire strings were used,
  not 4.
- **Fix:** replace the last clause with *"…/ Outra'. Codes 6–8 follow the questionnaire; code 9 keeps
  the dictionary's 'Vivendo maritalmente', which is what questionnaire box 59 ('Outra', asked only of
  people living with a partner) substantively means."*

### [MINOR] House style — `Não se aplica (…)` breaks the `Não aplicável…` convention used elsewhere in the same file

- **Code:** `R/add_labels_population.R:2493` — `'Não se aplica (pessoas naturais do município)'`
- **Siblings:** `:399` `'Não aplicável - Pessoa com menos de 2 anos de idade'`; `:662`
  `'Não aplicável - Pessoa com menos de 6 anos ou maior que 24 anos de idade'`; `:2927`, `:2945`,
  `:2958` `'Não aplicável'`. Every other block uses *Não aplicável* + a dash; the 1960 block is the
  only one using *Não se aplica* + parentheses.
- **Note:** the 1960 dictionary itself writes "Não se aplica (Pessoas naturais do município)", so this
  is a transcription, not an invention. Resolve together with the V299 MAJOR — if that arm is deleted,
  this finding disappears with it.

### [MINOR] Both `# NOTE:` blocks under-enumerate the variables deliberately left unlabelled

- **Code:** `R/add_labels_population.R:2140-2142` — *"the numeric variables (V100, V112, V113, V204b,
  V217, V218, the censobr_* ids, weights and counts)"*; `R/add_labels_households.R:886-887` —
  *"(V100, V112, V113, weights, ids and counts)"*.
- **Dictionary:** the `Valor` variables *not* named in either note are `V001`, `V002`, `V003`, `V004`
  (record identification), `V200`, `V201` (person number / check digit, PESS only), and
  `censobr_estrato`, `censobr_upa`, `censobr_usa` (sample-design variables) — plus the two `Texto`
  variables `censobr_diag_households_vars` / `censobr_diag_persons_vars`.
- **Why it matters:** the note reads as an exhaustive inventory and is used as one when the block is
  re-audited. All of these are correctly left unlabelled in the code — only the comment is short.
- **Fix:** append *"…, the record-identification and sample-design variables (V001–V004, V200, V201,
  censobr_estrato/upa/usa) and the two `censobr_diag_*_vars` text columns."*

---

## Reconciliation table

`Q` = corroborated against the questionnaire. Dictionary codes shown in dictionary order.

### `R/add_labels_population.R:2131-2652` — PESS sheet

| VAR | R lines | codes in R | codes in dict | verdict |
|---|---|---|---|---|
| `censobr_source` | 2145-2155 | 1,2 | 1,2 | **MATCH** |
| `V101` | 2156-2170 | 1,2,3,4,5,9 | 1,2,3,4,5,9 | **MATCH** (Q: item A has only 3 boxes; 4/5/9 are microdata refinements — dictionary governs) |
| `V102` | 2171-2183 | 4,5,6,7 | 4,5,6,7 | **MATCH** (Q item B: 4,5,6) |
| `V103` | 2184-2197 | 7,8,9,0 | 7,8,9,0 | **MATCH** (Q item C: 7,8,9) |
| `V104` | 2198-2216 | 0-9 | 0-9 | **MATCH** (Q item D boxes 10-18 = *Até 500 / 501 a 1 000 / …*; R's `De 501 a 1000` is **correct** and the dictionary's `de 500 a 1000` is the typo) |
| `V105` | 2217-2231 | 9,0,1,2,3,4 | 9,0,1,2,3,4 | **MATCH** (Q item E boxes 19-23; R fixes dict typo "Cananalização") |
| `V106` | 2232-2246 | 4,5,6,7,8,9 | 4,5,6,7,8,9 | **MATCH** (Q item F boxes 24-28) |
| `V107` | 2247-2262 | 9,0,1,2,3,4,5 | 9,0,1,2,3,4,5 | **MATCH** (Q item G boxes 29-34) |
| `V108` | 2263-2274 | 5,6,7 | 5,6,7 | **MATCH** (Q item H boxes 35-36) |
| `V109` | 2275-2286 | 7,8,9 | 7,8,9 | **MATCH** (Q item I boxes 37-38) |
| `V110` | 2287-2298 | 9,0,1 | 9,0,1 | **MATCH** (Q item J boxes 39-40) |
| `V111` | 2299-2312 | 1,2,3 | 1,2,3 | **MATCH** (Q item L boxes 41-42) |
| `uf` | 2313-2349 | 28 codes, 0-97 | same 28 codes | **MINOR** (code 3 `Roraima` = 1960 *Rio Branco*); all 28 code↔name bindings otherwise exact |
| `V118` | 2350-2361 | 1,3,5 | 1,3,5 | **MINOR** (`Suburbana` vs `Suburbano`) |
| `censobr_urban` | 2362-2372 | 0,1 | 0,1 | **MATCH** |
| `V202` | 2373-2387 | 1,2,3,4,5,6 | 1,2,3,4,5,6 | **MINOR** (Q row B: "Não morador **presente**") |
| `V203` | 2388-2406 | 7,8,9,0,1,2,3,4,5,6 | same | **MATCH** (Q row C boxes 7-14) |
| `V204` | 2407-2419 | 0,1,5,9 | 0,1,5,9 | **MATCH** (dict's parenthetical notes about V204b dropped — not category names) |
| `V205` | 2420-2438 | 5,6,7,8,9,0,1,2,3,4 | same | **MATCH** (Q row E boxes 15-23) |
| `V206` | 2439-2453 | 4,5,6,7,8,9 | 4,5,6,7,8,9 | **MATCH** (Q row F boxes 24-28: Branca/Preta/Amarela/Parda/Índia) |
| `V208` | 2454-2465 | 9,0,1 | 9,0,1 | **MINOR** (word order vs Q row H box 30) |
| `V209` | 2466-2479 | 0,1,2,3 | 0,1,2,3 | **MATCH** (Q row I: the standalone `[ ]0` box = *"residia em zona rural"*; R condenses dict's explanatory clauses faithfully) |
| `V299` | 2480-2498 | 2,3,4,5,6,7,8,9,1,**0** | 2,3,4,5,6,7,8,9,1 | **MAJOR** — code `0` undocumented |
| `V211` | 2499-2512 | 0,1,2,3,4 | 0,1,2,3,4 | **MATCH** (Q row L boxes 40-43 cross frequenta×sabe ler exactly as coded) |
| `V212` | 2513-2530 | 4,5,6,7,8,9,0,1,2 | same | **MATCH** (Q row M boxes 44-51) |
| `V213` | 2531-2549 | 2,3,4,5,6,1,0 | same | **MATCH** (Q row N boxes 52-55) |
| `V215` | 2550-2568 (comment 2546-2549) | 6,7,8,9,0,1,2,3,4,5 | same | **MATCH** on labels (Q row P boxes 56-64 resolve the dict's duplicated `Somente Casamento`); **MINOR** on the comment |
| `V219` | 2569-2587 | 5,6,7,8,9,0,1,2,3,4 | same | **MATCH** (Q row T boxes 65-73, bracket-for-bracket) |
| `V220` | 2588-2606 | 4,5,6,7,8,9,0,1,2,3 | same | **MATCH** (Q row U boxes 74-81) |
| `V223` | 2607-2619 | 2,3,4,5 | 2,3,4,5 | **MATCH** (Q row W boxes 82-84) |
| `V224` | 2620-2636 | 0,1,5,6,7,8,9 | same | **MINOR** (code 0 vs Q row Z box 90 *"Membro de família ou instituição"*) |
| `censobr_diag_households` | 2637-2651 (`across`) | 2,3 | 2,3 | **MINOR** (code 2 abridged) |
| `censobr_diag_persons` | 2637-2651 (`across`) | 2,3 | 2,3 | **MINOR** (code 2 abridged) |

### `R/add_labels_households.R:880-1130` — DOMI sheet

The block's own claim — *"identical to the household variables of the 1960 block in
`add_labels_population()`"* (`:882-885`) — was **verified literally**: extracting every
`if ('X' %in% cols)` guard and every `X == n ~ 'label'` pair for the 15 shared variables
(`censobr_source`, `V101`–`V111`, `uf`, `V118`, `censobr_urban`) from both files yields **105 lines
each, `diff`-identical**. `censobr_diag_households` is implemented differently (a scalar `if` at
`:1120-1129` vs the population block's two-variable `across()`) but carries **the same two label
strings**.

| VAR | R lines | verdict |
|---|---|---|
| `censobr_source`, `V101`–`V111`, `uf`, `V118`, `censobr_urban` | 891-1119 | **identical to population block** — inherits its verdicts (`uf` MINOR, `V118` MINOR, rest MATCH) |
| `censobr_diag_households` | 1120-1129 | **MINOR** (code 2 abridged; same string as population) |

---

## Unlabelled documented categoricals

**None — in either sheet.** Both directions of the reconciliation close exactly:

| sheet | documented categoricals (≥1 numbered code) | labelled in R | gap |
|---|---|---|---|
| `PESS` | 33 | 33 | **0** |
| `DOMI` | 16 | 16 | **0** |

There is likewise **no variable labelled in R that the dictionary does not document**, and no
`Valor`/`Texto` variable labelled as categorical. The six "Ver aba" lookup variables (`V207`
naturalidade, `V210` residência anterior, `V214` curso completo, `V216` ano do casamento, `V221`
ocupação habitual, `V223b` ramo de atividade) are correctly left as raw codes — the questionnaire
confirms these are the *Código 1 / 2 / 3 / 4* long lookup lists printed in its left-hand legend
(hundreds of entries each), not inline category sets.

---

## Open questions for the maintainer

1. **`V299 == 0` (the MAJOR).** Does code `0` actually occur in the 1960 parquet, and does its
   cross-tab against `V209` support "pessoas naturais do município"? This cannot be settled from the
   documentation: the dictionary's "Não se aplica" line is unnumbered, and the questionnaire's row I
   has no box yielding a `0` for the *tempo de imigração* question. A `count(V209, V299)` decides it.

2. **`uf == 3`: keep the dictionary's `Roraima`, or the 1960 name `Rio Branco`?** Genuine source
   conflict. The dictionary — authority on the microdata variable — says `Roraima`; both
   questionnaires say `Rio Branco` and the block comment claims to render "the 1960 territorial
   division". Whichever way it goes, it is a maintainer's editorial call, not an auditor's.

3. **`V215` codes 6/7/8: the dictionary is internally broken** (`7- Somente Casamento` and
   `8- Somente Casamento` are the same string) and R silently repairs it from the questionnaire.
   The repair is right, but it means `add_labels_population(1960)` no longer matches
   `data_dictionary(1960, "population")` for three codes. Worth a line in the roxygen or NEWS so a
   user comparing the two does not read it as a bug.

---

## Self-check — findings struck before reporting (7)

1. **"`all_of` / `case_when` / `across` are unqualified at `R/add_labels_population.R:2638-2641`, unlike
   the `dplyr::`-prefixed calls elsewhere — runtime error."** Struck: `NAMESPACE` has
   `importFrom(dplyr, across, all_of, case_when, mutate, select)`, and the same bare style appears
   throughout `add_labels_households.R` and `add_labels_families.R`.
2. **"Type mismatch: the block compares integers (`V101 == 1`) while 2000/2010 blocks use strings
   (`== '1'`) — would null the whole variable."** Struck: `grep "== '"` over both 1960 blocks returns
   only the `lang == 'pt'` guard, so the block is internally consistent; and
   `tests/testthat/test_read_population.R:88-99` / `test_read_households.R:80-90` assert real labelled
   values (`'Parda'`, `'Somente casamento religioso'`, `'Rústico'`,
   `'Rede geral com canalização interna'`) come back from the actual 1960 parquet. The integer
   assumption is verified against data.
3. **"The NOTE cites `data_dictionary(1960, "population")` / `(1960, "households")`, which are not
   valid `dataset` values."** Struck: `R/data_dictionary.R:58` accepts
   `c("microdata","tracts","population","households")` and `R/availability.R:20-21` registers 1960
   for both.
4. **"The `uf` codes contradict the questionnaire's UF list (1 = Acre, 2 = Alagoas, …)."** Struck:
   that alphabetical list is *Código 1*, declared in the legend as applying to *"QUESITOS G — Lugar
   de nascimento e J — Lugar do domicílio anterior"* — i.e. `V207`/`V210`, not `uf`. The `uf`
   variable uses the geographic-order code set the dictionary prints, which R transcribes exactly.
5. **"`V104 == 1 ~ 'De 501 a 1000'` contradicts the dictionary's `de 500 a 1000`."** Struck: the
   questionnaire (item D, box 11) reads *"501 a 1 000"* — R is right and the dictionary has an
   off-by-one typo, exactly as the in-code comment claims.
6. **"`uf == 50 ~ 'Serra dos Aimorés'` adds a word the dictionary (`Serra Aimores`) does not have."**
   Struck: *"Serra dos Aimorés"* is attested verbatim in both questionnaires' *Código 1* legend
   (short form, entry 28).
7. **"No `.default` / `TRUE ~` arm, so 'Informação Faltante' and 'Não Aplicável' records are silently
   dropped to `NA`."** Struck: those states are unnumbered in the dictionary (i.e. they *are* the NA
   state in the file), and no year block anywhere in `R/add_labels_*.R` uses a default arm — this is
   the house convention, correctly followed.

---

**Bookend.** Goal: a complete, evidence-backed reconciliation of every 1960 code→label pair in
`add_labels_population()` and `add_labels_households()` against the IBGE dictionary and questionnaire,
in both directions, with no file under `R/` edited. Met: 33/33 documented categoricals reconciled both
ways, 0 coverage gaps, 0 CRITICALs, 1 MAJOR (an undocumented code that needs the data to settle) and
9 MINORs, each with both sides quoted; 7 candidate findings struck as unsupported. No file under `R/`
was modified.

---

## Data verification - run 2026-09-13 against data release **v0.7.0**

Every open question that needed the file was settled by reading the parquets through the
package's own `read_population()` / `read_households()` (dev source via `pkgload::load_all()`).
Script and full log: `scratchpad/verify_labels.R`, `scratchpad/verify_labels.log`.

### `V299 == 0` - the MAJOR: **RESOLVED. The arm is correct and load-bearing.**

`count(V209, V299)` on `1960_population_v0.7.0.parquet`:

- Code `0` **does occur - 10,447,853 records** (~69 % of the file). Deleting the arm, as the
  finding's first branch proposed, would have blanked the largest category of the variable.
- It coincides **exactly** with `V209 == 2`: `V299 == 0` pairs with no other `V209` value and
  `V209 == 2` pairs with no other `V299` value. The in-code claim *"its count equals that of
  V209 == 2"* is **true as stated** - the audit was wrong to doubt it.
- `V299 == 1` ('Ausencia de informacao') occurs only with `V209` in {0, 3} (33,078 records).

**Action taken:** the arm is kept; the comment in `R/add_labels_population.R` was rewritten to
record the verified cross-tab instead of asserting what `V209 == 2` means.

**Residual MINOR (new, replaces the MAJOR):** the label reads *'Nao se aplica (pessoas naturais
do municipio)'*, which is the dictionary's own unnumbered line, but `V209 == 2` is defined as
*"procedencia desconhecida - nascidos na UF onde residem ou nao moradores presentes"*. Someone
born elsewhere in the same UF **is** an intra-state migrant, so for part of this group
"nao se aplica" may overstate. Existence is settled; the *wording* is a source question the data
cannot decide, so the label is left transcribing the only source that names this state.

---

## Fixes applied — 2026-09-13 (plan: `quality_reports/plans/synthetic-dancing-hippo.md`)

Both sides were corrected together, ahead of retiring the served HTML dictionaries in favour
of `[year]_dictionary_microdata_formatted.xlsx`. Every edit is traceable to this year's
questionnaire; where the questionnaire is silent the dictionary governed and the labels
followed it. Verified: workbook structure unchanged (dimensions, merged ranges, fonts, cell
counts, per-cell line counts), both R files parse, the new strings come back from the v0.7.0
parquets, and every touched label now matches its dictionary line.

### Dictionary — `1960_dictionary_microdata_formatted.xlsx` (12 line edits)

| Sheet/cell | Was | Now | Authority |
|---|---|---|---|
| DOMI B14, PESS B16 · `V104` | `0- Ate 500` / `1- de 500 a 1000` | `0- Até 500` / `1- de 501 a 1000` | item D boxes 10/11 ("Até 500", "501 a 1 000") |
| DOMI B28, PESS B30 · `V118` | `3- Suburbano` | `3- Suburbana` | SITUAÇÃO box |
| PESS B34 · `V202` | `5-/6- … não Morador` | `… não Morador Presente` | row B heading "Não morador presente" |
| PESS B41 · `V208` | `0- Brasil Naturalizado` | `0- Naturalizado Brasileiro` | row H box 30 |
| PESS B49 · `V215` | `7-` and `8-` **both** `Somente Casamento` | `Somente Casamento Civil` / `Somente Casamento Religioso` | row P boxes 57/58 |
| PESS B58 · `V224` | `0- Membro da Família` | `0- Membro de Família ou Instituição` | row Z box 90 |

The `V215` repair is the most consequential: two codes were indistinguishable in the document users
are about to be given.

### Labels — `add_labels_population.R` / `add_labels_households.R`

- `V202` codes 5/6 → `'Homem/Mulher não morador presente'`
- `V224` code 0 → `'Membro de família ou instituição'`
- `V208` code 0 → `'Naturalizado brasileiro'` (applied earlier, with the maintainer's cross-year policy)
- `censobr_diag_households` / `censobr_diag_persons` code 2 → restores
  `(valores inválidos, não listados no dicionário, marcados como missing)`
- `V215` comment rewritten: it claimed all four questionnaire strings were used (three were), and the
  dictionary duplicate it worked around is now fixed
- both block NOTEs now list the record-identification and sample-design variables (`V001`-`V004`,
  `V200`, `V201`, `censobr_estrato/upa/usa`) and the `censobr_diag_*_vars` text columns
- `V118` needed no change: already `'Suburbana'`, and the dictionary now agrees

### Still open (2)

1. `V299` code 0 wording — `'Não se aplica (pessoas naturais do município)'` transcribes the
   dictionary, but the code maps onto `V209 == 2` (*nascidos na UF onde residem ou não moradores
   presentes*), so it may overstate for intra-UF migrants. No questionnaire box corresponds to it.
2. `uf` code 3 `'Roraima'` — the questionnaire's `Rio Branco` belongs to *Código 1* (naturalidade,
   `V207`/`V210`), **not** to `uf`, so the form cannot arbitrate this code. Left as the dictionary has it.
