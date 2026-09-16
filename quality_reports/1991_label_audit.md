# 1991 Label Audit — `R/add_labels_population.R` + `R/add_labels_households.R` (80 variables reconciled)

Sources of authority used:
- **Dictionary** — `1991_dictionary_microdata_formatted.xlsx`, sheets `PESS` (person record) and `DOMI`
  (household record); dumps `dict1991_PESS.txt` / `dict1991_DOMI.txt`. Columns are `VAR | NOME` only —
  no `SEÇÃO`, no `CATEG`/`TAM`, so the inline code list in `NOME` is the sole source for a variable's
  category set. Four entries (`V0302`, `V0303`, `V0310`, `V3471`) were re-read cell-verbatim with
  `readxl`, and `V0303` was also checked against the unformatted sibling
  `1991_dictionary_microdata.xlsx` (stated where it mattered).
- **Questionnaire** — `1991_questionnaire_long.pdf` (**CD 1.02, Questionário da Amostra**, 2 pages:
  p.1 household, p.2 person) and `1991_questionnaire_short.pdf` (CD 1.01, Questionário Básico). Both
  are scans with **no text layer**; every citation below was read off a rendered page/crop image
  (`scratchpad/q1991/*.png`, rendered with PyMuPDF at 100–350 dpi). The censobr 1991 file is the 10 %
  sample, i.e. **CD 1.02**, so the long form is the governing instrument.

Scope audited: `R/add_labels_population.R:4180-5713` (+ guard `:1-30`) and
`R/add_labels_households.R:1542-1925`. `grep -rn "1991" R/add_labels_*.R` confirms **no other file has
a 1991 block** — `families`, `mortality` and `emigration` do not cover 1991.

---

## Verdict

**PASS** (CRITICAL = 0, MAJOR = 0, MINOR = 4 open) - *revised after data verification: the MAJOR
was confirmed and **fixed**, and the test-coverage MINOR was closed. See the section at the end.*
~~REVISE (CRITICAL = 0, MAJOR = 1)~~

---

## Scorecard

- Variables labelled in R (population): **80** (74 via `if ('X' %in% cols)`, 6 via the `across()` over `tem_vars_1991`)
- Variables labelled in R (households): **29** (23 gated + the same 6 in `across()`)
- Distinct variables reconciled: **80** (the household set is a strict subset — see below)
- Variables reconciled **MATCH** (no finding): **76**
- CRITICAL / MAJOR / MINOR: **0 / 0 / 5 raised, 0 open** *(all fixed — see "Fixes applied" at the end)* *(post-verification; was 0 / 1 / 5 - the MAJOR and the test MINOR are fixed)*
- Documented categoricals unlabelled: **5** — all deliberate, all justified (0 unjustified gaps)
- Labels in R with no documented code: **1** (`V0303 == '16'`)
- **Code→dictionary bindings wrong: 0.** All 74 gated variables were compared code-by-code and
  string-by-string against the dictionary by script: 65 exact, 9 flagged, and **every one of the 9 is a
  wording issue or the one extra code — not a single label is bound to the wrong integer, and no pair
  is swapped.**
- Findings struck in self-check: **11**

### The households block's duplication claim — verified literally

`R/add_labels_households.R:1548` claims the block is *"Identical to the household variables of the 1991
block in add_labels_population()"*. Extracted and diffed:
`sed -n '4197,4550p' R/add_labels_population.R` vs `sed -n '1554,1907p' R/add_labels_households.R`
→ **354 lines each, `diff`-identical**; and `5697,5712` vs `1909,1924` (the `across()` block) →
**16 lines each, `diff`-identical**. The claim holds byte-for-byte. Every household verdict below is
therefore shared by both files.

### Type discipline — the string-vs-integer question

- The 1991 block is **100 % string comparisons**: 836 of 836 `== '…' ~` arms in the population block
  and every arm in the households block; `awk 'NR>=4180 && NR<=5716 && /== *[0-9]/'` returns only the
  `year == 1991` guard itself. **Internally consistent — no mixed-type variable.**
- String-vs-integer is a **per-year** property of the stored parquet, not a house style: 2022 (345),
  1960 (207) and 1970 (200) compare integers; 2000 (189), 2010 (159) and 1991 (836) compare strings;
  1980 is deliberately mixed (434 string + 16 integer, the `V536` exception the tests note).
  1991 is not the odd one out.
- Against the file: `tests/testthat/test_read_households.R:113-114` and
  `test_read_population.R:125-126` assert real labelled values (`'Vala negra'`,
  `'Mais de 20 a 30 salários mínimos'`, `'Cunhado(a)'`, `'Empregador'`) come back from the actual 1991
  parquet, so the string comparisons do resolve. **Zero-padding is only partly settled — see
  [MINOR] #5 and Open Question 2.**

---

## Findings

### [MAJOR] V0303 — an arm for code `16`, which the dictionary does not document and the code's own comment says does not occur

- **Code:** `R/add_labels_population.R:4609` — `V0303 == '16' ~ 'Parente do(a) empregado(a) doméstico(a)',`
  directly under `R/add_labels_population.R:4589` — `# CONDICAO NA FAMILIA (code 16 does not occur; see the dictionary)`
- **Dictionary:** `dict1991_PESS.txt` VAR `V0303` *Condição na Família* lists
  `01 Chefe … 14 Pensionista / 15 Empregado(a) Doméstico(a) / 20 Individual` — **17 numbered codes for
  V0302, 16 for V0303; there is no `16`.** Re-read cell-verbatim from
  `1991_dictionary_microdata_formatted.xlsx` (sheet `PESS`, row 10) *and* from the unformatted
  `1991_dictionary_microdata.xlsx`: both end `15 Empregado(a) Doméstico(a)` → `20 Individual`. The list
  is demonstrably not truncated — it prints the out-of-sequence `20` after `15`. The neighbouring
  `V0302` *Condição no Domicílio* (row 9) **does** carry `16 Parente do(a) Empregado(a) Doméstico(a)`;
  the R arm is that entry copy-pasted one variable too far.
- **Questionnaire:** long form p.2, quesitos **02** and **03** (crop `p2_q0203.png`) print only the two
  endpoints — `01 Chefe` and `20 Individual` — for both items; the intermediate codes are written in by
  the enumerator from the interview manual. The questionnaire therefore **cannot** settle whether 16 is
  reachable in quesito 03, and the dictionary is the only authority. It says no.
- **Why it matters:** the comment asserts the arm never fires, which by the severity table is a MAJOR in
  its own right (a branch that never fires), and the file and its own documentation now contradict each
  other — the next maintainer cannot tell which is authoritative. If the dictionary is instead
  incomplete and `16` *does* occur, the block is silently publishing a category IBGE never documented
  for this variable.
- **Needs data verification** — the 1991 parquet was not downloaded, per instructions. Settle with:
  `read_population(1991) |> dplyr::count(V0302, V0303) |> dplyr::collect()`
- **Fix (if `16` is absent, i.e. the comment is right):** delete line 4609 and let `16` fall through to
  `NA` like every other undocumented state in this block; keep the comment.
  **Fix (if `16` is present):** keep the arm and replace the comment with the verified cross-tab, e.g.
  `# CONDICAO NA FAMILIA (code 16 is undocumented in the dictionary but occurs in the file; labelled as in V0302)`.
  Either way the two must be made to agree, and the edit applies nowhere else — `V0303` is labelled
  only in `add_labels_population.R`.

---

### [MINOR] V3471 — six labels silently abridged, with no comment disclosing it (unlike V0329, which does)

- **Code:** `R/add_labels_population.R:5427-5437`, guard `:5423`. Six of the eleven arms drop the
  dictionary's defining parenthetical:
  - `:5430` `'Outras atividades industriais'`
  - `:5433` `'Serviços auxiliares da atividade econômica'`
  - `:5434` `'Prestação de serviços'`
  - `:5435` `'Social'`
  - `:5436` `'Administração pública'`
  - `:5437` `'Outras atividades'`
- **Dictionary:** `dict1991_PESS.txt` VAR `V3471` (re-read verbatim from the xlsx, sheet `PESS`, row 60) —
  `4- Outras atividades industriais (extração mineral e serviços industriais de utilidade pública)`;
  `7- Serviços auxiliares da atividade econômica (técnico-profissionais e auxiliares das atividades econômicas)`;
  `8- Prestação de serviços (alojamento e alimentação, reparação e conservação, pessoais, domiciliares e diversões)`;
  `9- Social(comunitárias, médicas, odontológicas e ensino)`;
  `10- Administração Pública (Administração Pública, Defesa Nacional e Segurança Pública)`;
  `11- Outras atividades (instituições de crédito, seguros e capitalização, … atividades mal definidas ou não declaradas)`.
- **Why it matters:** `'Social'` on its own is not a sector name a user can interpret — the parenthetical
  *is* the definition (community, medical, dental, education services). `'Outras atividades'` and
  `'Outras atividades industriais'` become indistinguishable in meaning. The block does this correctly
  elsewhere: `V0329` carries an explicit disclosure at `:5207` — `# CURSO CONCLUIDO (long labels
  shortened to the course name)` — and that shortening is systematic and defensible (19 `(inclui: …)`
  lists dropped). `V3471` has no such comment, so the abridgement reads as a transcription.
- **Fix:** either restore the parentheticals verbatim, e.g.
  `V3471 == '9' ~ 'Social (comunitárias, médicas, odontológicas e ensino)',`
  (and likewise for 4, 7, 8, 10, 11), or add a disclosure comment in the `V0329` style at `:5422`.

### [MINOR] V0310 — three undeclared departures from the dictionary's text

- **Code:** `R/add_labels_population.R:4803` — `V0310 == '77' ~ 'Oriental Seicho-No-Ie'`;
  `:4809`, `:4810`, `:4811` — `'Não determinada ou mal definida - cristã'` /
  `'… - crente'` / `'… - outras'`.
- **Dictionary:** re-read cell-verbatim (`1991_dictionary_microdata_formatted.xlsx`, sheet `PESS`,
  row 102): `77- Oriental Seicho No-Ie` (**no hyphen between "Seicho" and "No-Ie"**);
  `85- Não determinada ou mal definidas - Cristã`; `86- … mal definidas - Crente`;
  `89- … mal definidas - outras` (**plural "definidas"**).
- **Questionnaire:** not consultable — quesito 10 *Religião ou culto* is an open write-in line with no
  printed category list, so the dictionary is the only source for all 47 codes.
- **Why it matters:** the block's declared transformation is *"normalised to sentence case"* (`:4184`).
  Inserting a hyphen and changing a plural adjective to singular are not case normalisation; they are
  silent editorial corrections of the only source — exactly the class of change the 1960 audit flagged
  for `V118`. Both are plausibly *improvements*, which is why this is MINOR and no more, but they are
  undeclared, and a user diffing `add_labels_population(1991)` against
  `data_dictionary(1991, "population")` will see four rows that do not match.
- **Fix:** either transcribe (`'Oriental Seicho No-Ie'`,
  `'Não determinada ou mal definidas - cristã'`, `… - crente`, `… - outras`) or extend the
  NOTE at `:4184` to name the two repairs.

### [MINOR] V0214 code 6 — dictionary and questionnaire disagree, and the block comment claims they never do

- **Code:** `R/add_labels_population.R:4427` and `R/add_labels_households.R:1784` —
  `V0214 == '6' ~ 'Jogado em rio, lago, lagoa ou mar'`
- **Dictionary:** `dict1991_DOMI.txt` VAR `V0214` — `6 Jogado em rio, lago, lagoa ou mar` (R transcribes
  it exactly; the binding is correct).
- **Questionnaire:** long form p.1, quesito **14 DESTINO DO LIXO** (crop `long_p1_q14.png`, read at
  350 dpi): the boxes under the two brackets read `Coletado → 1 Diretamente, 2 Indiretamente`;
  `3 Queimado`; `4 Enterrado`; `Jogado → 5 Terreno baldio, 6 Rio, lago ou mar`; `7 Outro`.
  The form says **"Rio, lago ou mar" — there is no "lagoa"**. (Note also that the "Jogado" bracket spans
  only boxes 5 and 6; `4 Enterrado` sits outside it, which the dictionary's `4 Enterrado` /
  `5 Jogado em terreno baldio` wording preserves correctly.)
- **Why it matters:** two things. (i) It is a genuine source conflict on a category's substantive
  wording, which the questionnaire governs — reported, not silently resolved; the divergence is
  semantically harmless, so following the dictionary is defensible. (ii) It falsifies, by one instance,
  the block comment at `R/add_labels_population.R:4185-4186` — *"cross-checked against the 1991 sample
  questionnaire (CD 1.02 …), which agrees with the dictionary throughout"* — and
  `R/add_labels_households.R:1547-1548`, *"which agrees with it"*. A second instance runs the other way
  (`V0333` code 6, where the **dictionary** is the abridged one — struck finding #1).
- **Fix:** leave the label (the dictionary governs the microdata) and amend the comment to note the two
  exceptions: `…which agrees with the dictionary except on the wording of V0214 code 6 and V0333 code 6.`

### [MINOR] Both `# NOTE:` blocks under-enumerate the variables deliberately left unlabelled

- **Code:** `R/add_labels_population.R:4190-4195` — *"…as are the numeric variables (ages, counts of
  children, incomes, V0313 anos de moradia, V3005 ordem da mae, V0211-V0213, V0335-V0342, ids,
  weights), V0099/V0098 record fields, and the geography codes V1101, V1102, V7001, V7002 and V7004"*;
  `R/add_labels_households.R:1550-1552` — *"Numeric variables (V0209 aluguel, V0211-V0213 comodos e
  banheiros, V2012, V2111, V2121, V0111, V0112, weights, ids) and the geography codes V1101, V1102,
  V7001, V7002 and V7004 are left as they are."*
- **Dictionary:** three `PESS` variables fall under none of the population note's headings — they are
  not ages, not counts of children, not incomes, and not named: `V0317` *Anos em que mora na Unidade da
  Federação*, `V0318` *Anos em que mora no Município*, and `V3152` *Ano que fixou residência no País*
  (`00 = brasileiro nato ou estrangeiro que fixou residência …; 01 a 91 = ano …`). The note singles out
  their exact sibling `V0313` by name, which is what makes the omission read as an oversight. The
  households note omits **`V0099` *Tipo de Registro* (`1 domicilio` / `2 pessoas`)** — a documented
  **categorical**, not an id or a number, and the one documented categorical that block leaves
  unlabelled.
- **Why it matters:** both notes read as exhaustive inventories and are used as such when the block is
  re-audited (the 1960 note had the same defect). Every one of these variables is **correctly** left
  unlabelled in the code — only the comments are short.
- **Fix:** population — append `, V0317/V0318 anos de moradia na UF e no municipio, V3152 ano de fixacao de residencia no pais`;
  households — change `…weights, ids)` to `…weights, ids), the record fields V0098/V0099`.

### [MINOR] The 1991 label tests pin only two-digit codes, so they cannot detect the leading-zero regression the block comment rules out

- **Code:** `R/add_labels_population.R:4188-4190` asserts *"Every labelled variable is stored as a
  string without leading zeros ('1', …, '15', '20')"*; the whole block depends on it.
- **Tests:** `tests/testthat/test_read_population.R:119-126` — `'Cunhado(a)'` is `V0302 == '11'` and
  `'Empregador'` is `V0349 == '10'`; `tests/testthat/test_read_households.R:108-114` —
  `'Mais de 20 a 30 salários mínimos'` is `V2013 == '10'`, and `'Vala negra'` is `V0206 == '5'`, whose
  dictionary field is one digit wide anyway. **All four pinned codes are two characters (or come from a
  1-wide field), so all four would pass identically whether the file stores `'01'` or `'1'` for the
  single-digit codes.** The failure mode the tests are captioned as guarding against — *"codes are
  strings without leading zeros"* — is precisely the one they cannot see.
- **Dictionary / questionnaire:** the sources contradict each other on rendering, so neither settles it.
  The dictionary writes `V0302`/`V0303`/`V2013`/`V2014`/`V3044`/`V3046`/`V3047`/`V3049`/`V0316`
  **padded** (`01 Chefe`) but `V0349`/`V3241`/`V3461`/`V0329`/`V3562`–`V3614` **unpadded** (`1- Sim`,
  `11- Sem remuneração`) — while the questionnaire prints quesito 49 (= `V0349`) **padded**, `01 … 11`
  (crop `p2_q49.png`), and quesitos 02/03 (= `V0302`/`V0303`) padded, `01 … 20` (crop `p2_q0203.png`).
  The padding in the dictionary is a transcription style, not a field width.
- **Corroborating (non-authoritative):** the legacy builder `data_prep/R/microdata_sample_1991.R:255-266`
  writes the assembled table out with `data.table::fwrite()` and re-reads it with
  `arrow::open_csv_dataset()` (type inference) before `write_parquet()` — a round trip that strips
  leading zeros; the same script has to re-pad `V1102` explicitly
  (`stringi::stri_pad_left(V1102, 4, 0)`, commented *"add trailing zeros to municipality column"*),
  direct evidence that the CSV round trip loses them. `data_prep/` is **legacy** and `.Rbuildignore`d
  (the live pipeline is `ipea/censobr_prep_data`), so this corroborates the comment but does not prove
  it for the shipped v0.6.0 file.
- **Why it matters:** if a single-digit code of a two-wide field were stored padded, codes 1–9 of
  `V0302`, `V0303`, `V2013`, `V2014`, `V3044`, `V3046`, `V3047`, `V3049` and `V0316` would all silently
  become `NA` — `'Chefe'`, `'Cônjuge'`, `'Filho(a)'` and every income band below 15 SM would vanish
  while `'Cunhado(a)'` and the upper bands survived, and the suite would stay green.
- **Fix:** add one discriminating assertion per file — in `test_read_population.R` after `:126`,
  `testthat::expect_true('Chefe' %in% test1991$V0302)` (code `1` of a two-wide field), and in
  `test_read_households.R` after `:114`,
  `testthat::expect_true('Até 1/4 de salário mínimo' %in% test1991$V2013)`.
  This is a test change, not an `R/` change; the label block needs no edit if the check passes.

---

## Reconciliation table

`Q` = corroborated against the questionnaire (CD 1.02 unless stated). Dictionary code counts are the
number of **numbered** codes; unnumbered trailing `branco …` / `- Pessoas com menos de …` lines are the
**NA state**, never a code (the 1960 convention, which the 1991 dictionary follows for 39 variables),
and are correctly left to fall through to `NA` — no block in `R/add_labels_*.R` uses a `.default` /
`TRUE ~` arm.

### Household record — `R/add_labels_population.R:4197-4550` **≡** `R/add_labels_households.R:1554-1907` (byte-identical)

| VAR | R lines (labels), pop / hh | codes in R | codes in dict | verdict |
|---|---|---|---|---|
| `V1061` | 4202-4209 / 1559-1566 | 1-8 | 8 (`DOMI`) | **MATCH** (derived setor classification; not on the form) |
| `V7003` | 4219-4228 / 1576-1585 | 0-9 | 10 | **MATCH** |
| `V0201` | 4238-4240 / 1595-1597 | 1,2,3 | 3 | **MATCH** — Q p.1 quesito 1 (`Particular → 1 Permanente, 2 Improvisado; 3 Coletivo`) |
| `V0202` | 4250-4256 / 1607-1613 | 1-7 | 7 | **MATCH** — Q quesito 2 (`Casa 1-3 / Apartamento 4-6 / 7 Cômodo(s)`) |
| `V0203` | 4266-4271 / 1623-1628 | 1-6 | 6 | **MATCH** — Q quesito 3 |
| `V0204` | 4281-4288 / 1638-1645 | 1-8 | 8 | **MATCH** — Q quesito 4 |
| `V0205` | 4298-4303 / 1655-1660 | 1-6 | 6 | **MATCH** — Q quesito 5 (`Com canalização interna 1-3 / Sem 4-6`) |
| `V0206` | 4313-4320 / 1670-1677 | 0-7 | 8 | **MATCH** — Q quesito 6 ESCOADOURO; the `Fossa séptica` bracket over boxes 2 and 3 confirms `2 … ligada à rede pluvial` / `3 … sem escoadouro` |
| `V0207` | 4330-4332 / 1687-1689 | 0,1,2 | 3 | **MATCH** — Q quesito 7 |
| `V0208` | 4342-4347 / 1699-1704 | 1-6 | 6 | **MATCH** — Q quesito 8 (`Próprio 1-2 / 3 Alugado / Cedido 4-5 / 6 Outra`) |
| `V2094` | 4357-4366 / 1714-1723 | 0-9 | 10 | **MATCH** (derived band of the quesito 9 value field) |
| `V0210` | 4376-4382 / 1733-1739 | 0-6 | 7 | **MATCH** — Q quesito 10 |
| `V2112` | 4392-4396 / 1749-1753 | 1-5 | 5 | **MATCH** (derived) |
| `V2122` | 4406-4412 / 1763-1769 | 1-7 | 7 | **MATCH** (derived) |
| `V0214` | 4422-4428 / 1779-1785 | 1-7 | 7 | **MINOR** — code 6: Q quesito 14 reads *"Rio, lago ou mar"*, dictionary adds *"lagoa"* |
| `V0217` | 4438-4440 / 1794-1796 | 0,1,2 | 3 | **MATCH** — Q quesito 17 |
| `V0218` | 4450-4453 / 1806-1809 | 0-3 | 4 | **MATCH** — Q quesito 18 |
| `V0219` | 4463-4465 / 1819-1821 | 0,1,2 | 3 | **MATCH** — Q quesito 19 |
| `V0221` | 4475-4478 / 1831-1834 | 1-4 | 4 | **MATCH** — Q quesito 21 (`Elétrica 1-2 / 3 Óleo ou querosene / 4 Outra`) |
| `V0222` | 4488-4490 / 1844-1846 | 0,1,2 | 3 | **MATCH** — Q quesito 22 |
| `V0224` | 4500-4503 / 1856-1859 | 0-3 | 4 | **MATCH** — Q quesito 24 |
| `V2013` | 4513-4525 / 1869-1882 | 1-13 | 13 | **MATCH** (derived band) |
| `V2014` | 4535-4547 / 1891-1904 | 1-13 | 13 | **MATCH** (derived band) |
| `V0216` | 5707-5708 / 1919-1920 (`across`) | 0,1 | 2 | **MATCH** — Q quesito 16 (`1 Tem / 0 Não tem`) |
| `V0220` | idem | 0,1 | 2 | **MATCH** — Q quesito 20 |
| `V0223` | idem | 0,1 | 2 | **MATCH** — Q quesito 23 |
| `V0225` | idem | 0,1 | 2 | **MATCH** — Q quesito 25 |
| `V0226` | idem | 0,1 | 2 | **MATCH** — Q quesito 26 |
| `V0227` | idem | 0,1 | 2 | **MATCH** — Q quesito 27 |

The two skip patterns printed on the form are reflected exactly by the dictionary's `branco` lines and
correctly left as `NA` by both blocks: *"(Os quesitos seguintes só serão preenchidos para o domicílio
particular permanente)"* under quesito 1 → `branco Domicílios improvisados ou Domicílios coletivos` on
`V0202`–`V0227`; and *"(Os quesitos seguintes só serão preenchidos quando houver iluminação elétrica)"*
under quesito 21 → `branco … ou (V0221) = código 3 ou 4` on `V0222`–`V0227`.

### Person record — `R/add_labels_population.R:4552-5695` (population file only)

| VAR | R lines (labels) | codes in R | codes in dict | verdict |
|---|---|---|---|---|
| `V0301` | 4557-4558 | 1,2 | 2 | **MATCH** — Q p.2 quesito 01 |
| `V0302` | 4568-4584 | 1-16,20 | 17 | **MATCH** — Q quesito 02 prints endpoints `01 Chefe` / `20 Individual` only |
| `V0303` | 4594-4610 | 1-16,20 | **16** (1-15,20) | **MAJOR** — code `16` labelled but undocumented; comment at `:4589` says it cannot occur |
| `V0304` | 4620-4626 | 1-7 | 7 | **MATCH** — Q quesito 04 (`1 Única, 2 Domicílio coletivo, Convivente 3-7 = 1ª…5ª`) |
| `V2011` | 4636-4639 | 1-4 | 4 | **MATCH** (derived) |
| `V3044` | 4649-4663 | 1-15 | 15 | **MATCH** (derived band; 3/4-SM cut-points, correctly distinct from V3046) |
| `V3046` | 4673-4685 | 1-13 | 13 | **MATCH** (derived band) |
| `V3047` | 4695-4707 | 1-13 | 13 | **MATCH** (derived band) |
| `V3049` | 4717-4730 | 1-14 | 14 | **MATCH** (per-capita band; code 13 is `Sem rendimento` **singular** in the dictionary and R transcribes it — not a typo) |
| `V3071` | 4740-4741 | 1,2 | 2 | **MATCH** |
| `V0309` | 4751-4756 | 1-5,9 | 6 | **MATCH** — Q quesito 09 (`1 Branca, 2 Preta, 3 Amarela, 4 Parda, 5 Indígena`); `9 Ignorado` is microdata-only |
| `V0310` | 4766-4812 | 0,11-13,21-41,45,49,51-53,59,61-63,71,75-77,79,81-86,89,99 (47) | 47 | **MINOR** — 4 wording departures (codes 77, 85, 86, 89); all 47 code↔label bindings exact |
| `V0311` | 4822-4831 | 0-9 | 10 | **MATCH** — Q quesito 11, box for box, incl. `0 Nenhuma das enumeradas` |
| `V0312` | 4841-4843 | 1,2,3 | 3 | **MATCH** — Q quesito 12 |
| `V0314` | 4853-4855 | 1,2,3 | 3 | **MATCH** — Q quesito 14 |
| `V3151` | 4865-4867 | 1,2,3 | 3 | **MATCH** — Q quesito 15 (`1 Brasileiro nato, 2 Naturalizado brasileiro, 3 Estrangeiro`) |
| `V0316` | 4877-4973 | 1-27,29-56,58-98,99 (97) | 97 | **MATCH** — all 97 exact, including the gaps at 28 and 57. **1991 territorial division confirmed**: 27-unit sequential set with `07 Tocantins`, `04 Roraima` and `06 Amapá` as states, `24 Mato Grosso do Sul`, `27 Distrito Federal`; no Guanabara, no Fernando de Noronha. Period country names (`40 Guiana Inglesa`, `79 Checoslováquia`, `80 U.R.S.S.`, `87 China Formosa`) transcribed from the dictionary, as is right for a 1991 instrument |
| `V0319` | 4983-5012 | 11-17,21-29,31-33,35,41-43,50-54,80,99 (30) | 30 | **MATCH** — IBGE UF codes, 1991 division incl. `17 Tocantins`, plus `54 Brasil não especificado`, `80 País estrangeiro ou mal definido`, `99 Ignorado` |
| `V0320` | 5022-5024 | 1,2,9 | 3 | **MATCH** — Q quesito 20 |
| `V0321` | 5034-5064 | as V0319 + `70` (31) | 31 | **MATCH** — Q quesito 21 instructs *"se residia no Município, assinale o retângulo 7 — Neste"*; the 2-wide microdata field renders it `70`, exactly as dictionary and R have it |
| `V0322` | 5074-5076 | 1,2,9 | 3 | **MATCH** — Q quesito 22 |
| `V0323` | 5086-5087 | 1,2 | 2 | **MATCH** — Q quesito 23 has exactly two rectangles (struck finding #11 re the short form's third) |
| `V0324` | 5097-5105 | 0-8 | 9 | **MATCH** — Q quesito 24 |
| `V0325` | 5115-5120 | 0-5 | 6 | **MATCH** — Q quesito 25 (`Supletivo seriado` bracket over boxes 4 and 5) |
| `V0326` | 5130-5136 | 0-6 | 7 | **MATCH** — Q quesito 26 |
| `V0327` | 5146-5155 | 0-9 | 10 | **MATCH** (code 9 modernises `freqüentou` → `frequentou`; house style — struck finding #2) |
| `V0328` | 5165-5173 | 0-8 | 9 | **MATCH** — Q quesito 28 |
| `V3241` | 5183-5202 | 0-17,20,30 | 20 | **MATCH** (R reorders `30` to the end of the arm list; binding unchanged) |
| `V0329` | 5212-5308 | 0-8,10-97 (97) | 97 | **MATCH** — all 97 bindings exact; 19 `(inclui: …)` lists dropped, **disclosed** by the comment at `:5207`; the whitespace repair at code 18 fixes the dictionary's own typo (`Outro -1º grau`) |
| `V0330` | 5318-5319 | 1,2 | 2 | **MATCH** — Q quesito 30 |
| `V0332` | 5329-5333 | 1-4,9 | 5 | **MATCH** — Q quesito 32, word for word |
| `V0333` | 5343-5347 | 5-9 | 5 | **MATCH** — Q quesito 33 reads `6 Desquitado(a) ou separado(a) judicialmente`; **R matches the questionnaire; the dictionary is the abridged source** |
| `V3342` | 5357-5361 | 1-5 | 5 | **MATCH** (derived; the feminine forms are the dictionary's own — asked of women only) |
| `V0343` | 5371-5374 | 1,2,7,9 | 4 | **MATCH** — Q quesitos 43/44 (`7 Não tem`, `1 Homem`, `2 Mulher`) |
| `V3444` | 5384-5386 | 1,2,9 | 3 | **MATCH** (derived) |
| `V0345` | 5396-5398 | 1,2,3 | 3 | **MATCH** — Q quesito 45 (`Trabalhou → 1 Habitualmente, 2 Eventualmente; 3 Não trabalhou`) |
| `V3461` | 5408-5417 | 1-10 | 10 | **MATCH** (derived from the quesito 46 write-in) |
| `V3471` | 5427-5437 | 1-11 | 11 | **MINOR** — 6 undisclosed abridgements (codes 4, 7, 8, 9, 10, 11); bindings all correct |
| `V0349` | 5447-5457 | 1-11 | 11 | **MATCH** — Q quesito 49, boxes 01-11 one for one, incl. the `Parceiro ou meeiro`, `Trabalhador doméstico` and `Empregado do setor público` brackets |
| `V0350` | 5467-5470 | 1-4 | 4 | **MATCH** — Q quesito 50 |
| `V0351` | 5480-5487 | 1-8 | 8 | **MATCH** — Q quesito 51 (form prints `1 ou 2` / `3 ou 4` / `5 a 9` / `10 ou mais`; R uses the dictionary's spelled-out forms) |
| `V0352` | 5497-5504 | 1-8 | 8 | **MATCH** — Q quesito 52 (`No domicílio 1-2 / Via pública 3-4 / 5-8`) |
| `V0353` | 5514-5516 | 1,2,3 | 3 | **MATCH** — Q quesito 53 |
| `V3562` | 5526-5540 | 1-15 | 15 | **MATCH** (derived band) |
| `V3563` | 5550-5564 | 1-15 | 15 | **MATCH** (derived band) |
| `V3564` | 5574-5588 | 1-15 | 15 | **MATCH** (derived band) |
| `V3574` | 5598-5612 | 1-15 | 15 | **MATCH** (derived band) |
| `V0358` | 5622-5631 | 0-9 | 10 | **MATCH** — Q quesito 58 (`Procurando trabalho → 1 Já trabalhou, 2 Nunca trabalhou`; 3-9; `0 Sem ocupação`) |
| `V0359` | 5641-5644 | 0-3 | 4 | **MATCH** — Q quesito 59 |
| `V3604` | 5654-5668 | 1-15 | 15 | **MATCH** (derived band) |
| `V3614` | 5678-5692 | 1-15 | 15 | **MATCH** (derived band) |

The person-page skip patterns are likewise rendered as `NA` rather than a category, matching the
dictionary's unnumbered lines: *"OS QUESITOS SEGUINTES SÓ SERÃO PREENCHIDOS PARA A PESSOA DE 5 ANOS OU
MAIS"* (before quesito 21) → `branco Pessoas com menos de 5 anos` on `V0321`/`V3211`/`V0322` and
`- pessoas com menos de 5 anos` on `V0323`–`V3241`; *"… PARA A PESSOA DE 10 ANOS OU MAIS (nascida antes
de 01/09/1981)"* (before quesito 29) → `- Pessoas com menos de 10 anos` from `V0329` onward; *"… PARA AS
MULHERES"* (before quesitos 35/36) → `- Homens ou Mulher com menos de 10 anos` on `V0343`/`V3444`; and
the quesito 45 skip → `ou (VAR0345) = código 3` on `V3461`, `V3471`, `V0349`–`V0353`, `V3562`–`V3574`.

*Footnote.* Questionnaire quesito **15** (*"Neste domicílio reside criança com menos de 2 anos,
inclusive alguma recém-nascida?"*, boxes `1 Sim` / `0 Não`) has **no variable in the microdata** — the
`DOMI` dictionary jumps `V0214` → `V0216`. Nothing to label; noted so the next auditor does not hunt
for a missing `V0215`.

---

## Unlabelled documented categoricals

| VAR | dict sheet | codes | why it probably matters — and why it is nonetheless correct here |
|---|---|---|---|
| `V0099` *Tipo de Registro* | PESS + DOMI | `1 domicilio`, `2 pessoas` (2) | A record-type flag, constant within each file (`2` throughout the population parquet, `1` throughout the households parquet). Labelling it would add nothing. Named in the population NOTE (`:4194`); **not** named in the households NOTE — see MINOR #4. |
| `V1101` *UF* | PESS + DOMI | 27 (`11 Rondônia` … `53 Distrito Federal`) | The largest unlabelled categorical, but **verified redundant**: censobr derives `code_state`, `abbrev_state`, `name_state`, `code_region` and `name_region` from it (`data_prep/R/add_geography_cols.R:47-52`, `:89`, `:256-262`), and `tests/testthat/test_read_population.R:121` selects `abbrev_state` from the real 1991 file, so the names are demonstrably present. Contrast 1960, where `R/add_labels_population.R:2311` labels `uf` *because* there are no name columns. |
| `V7004` *Macrorregião* | PESS + DOMI | 5 (`1 Região Norte` … `5 Região Centro-Oeste`) | Same: `name_region` ('Norte' … 'Centro-oeste') is generated from `substr(code_state, 1, 1)`, i.e. the identical 1-5 partition. |
| `V3191` *Município ou País Estrangeiro em que morava em 01/09/1986* | PESS | 69 country codes **plus** the entire município code list in the external file `C1102BR.TXT` | Looks like an unlabelled categorical but **must not** be labelled: the dictionary states the codes *"só têm sentido se combinados com os códigos da (VAR0319)"* — the same 4-digit value is a município when `V0319` is a UF code and a country when `V0319 == 80`. A flat `case_when` would mislabel every internal migrant. Correctly left as codes, and named in the NOTE (`:4191`). |
| `V3211` *Município ou País Estrangeiro de residência em 01/09/1986* | PESS | 69 + external list | Identical reasoning, keyed on `V0321`. |

**Unjustified gaps: 0.** Every documented categorical in either sheet is either labelled or deliberately
and correctly left alone. There is likewise **no variable labelled in R that the dictionary does not
document** (all 74 gated names resolve to a `PESS` or `DOMI` block), and **no `Valor` / free-numeric
variable is labelled as categorical** — the four hybrid fields that mix a count with reserved codes
(`V0212` `0 = nove cômodos ou mais`; `V0213` `0 = não tem`, `5 = cinco ou mais`; `V0313` `98 = nunca
mudou`; `V3005` `70/80/90/99`) are all left numeric, which is the right call: labelling them would
convert an otherwise usable count into a character column.

**Cross-year consistency sweep.** A script over all seven year blocks of `add_labels_population.R`
(boundaries at lines 33, 1017, 1616, 2132, 2654, 3197, 4181) finds **no variable name shared between
the 1991 block and any other year**, so no variable is labelled two different ways across censuses.
House style: no `ü` (trema) appears anywhere in `R/add_labels_*.R`, so `V0327`'s `frequentou` is
consistent; and `'Não aplicável'` appears only at `:399`, `:662`, `:2927`, `:2945`, `:2958`, in every
case for a code the relevant year's dictionary **numbers** — 1991 numbers none of its not-applicable
states, so its absence from this block is the convention correctly applied, not an omission.

---

## Open questions for the maintainer

1. **`V0303 == '16'` (the MAJOR).** Does code `16` occur in the 1991 person parquet? Both the formatted
   and the unformatted dictionary stop at `15 … / 20 Individual`, and the questionnaire prints only the
   endpoints for quesito 03, so the documentation cannot settle it. `count(V0302, V0303)` decides
   whether line 4609 is deleted or the comment at 4589 is rewritten.

2. **Is any 1991 code stored zero-padded?** The block rests on *"stored as a string without leading
   zeros"*; the dictionary renders some variables padded and others not, the questionnaire renders the
   *unpadded* ones padded, and all four existing test assertions use two-character codes. One `count()`
   retires the question:
   `read_population(1991, columns = c('V0302','V2013')) |> dplyr::count(V0302) |> dplyr::collect()`
   (expect `'1'`, not `'01'`). Worth pinning in the test suite either way — MINOR #5.

3. **`V0214` code 6 and `V0333` code 6: the two sources disagree, in opposite directions.** For `V0214`
   the dictionary is fuller (*"rio, lago, lagoa ou mar"* vs the form's *"Rio, lago ou mar"*); for
   `V0333` the dictionary is the abridged one (*"separado judicialmente"* vs the form's *"separado(a)
   judicialmente"*). R follows the dictionary in the first case and the questionnaire in the second.
   Both individual choices are defensible; the blanket comment *"which agrees with the dictionary
   throughout"* is not, and it is exactly the claim a future auditor will lean on.

4. **`V3471` vs `V0329` — pick one policy for long labels.** `V0329` shortens and says so; `V3471`
   shortens and does not. Whichever way it is resolved, resolving it identically in both places is what
   keeps `add_labels_population(1991)` diffable against `data_dictionary(1991, "population")`.

---

## Self-check — findings struck before reporting (11)

1. **"`V0333` code 6 adds an `(a)` the dictionary does not have."** Struck: the questionnaire (long form
   p.2, quesito 33, crop `p2_q3233.png`) reads **"Desquitado(a) ou separado(a) judicialmente"**. R
   matches the questionnaire; the dictionary is the abridged source. Retained instead as evidence under
   the `V0214` MINOR.
2. **"`V0327` code 9 drops the dictionary's trema (`freqüentou` → `frequentou`)."** Struck:
   `grep -rn "u00fc" R/*.R` returns nothing — post-1990-reform orthography is used throughout every
   year block, so this is house style, not a transcription slip.
3. **"`V0349` code 9 changes `conta-própria` to `conta própria`."** Struck: the dictionary itself writes
   the unhyphenated *"Conta própria"* for codes 3 and 5 of the same variable, and the questionnaire
   (quesito 49) prints *"Conta própria"* for boxes 03, 05 **and** 09. R normalises to the form both
   sources use in the majority of cases.
4. **"`V0329` code 18 changes `Outro -1º grau - Industrial` to `Outro - 1º grau - industrial`."**
   Struck: whitespace repair of a dictionary typo — codes 15, 23, 31 and 42 of the same variable use
   the spaced form in the dictionary.
5. **"No `.default` / `TRUE ~` arm, so the `branco` / `Pessoas com menos de N anos` states are silently
   dropped to `NA`."** Struck: those states are **unnumbered** in the 1991 dictionary (they *are* the
   blank in the file), no block in `R/add_labels_*.R` uses a default arm, and the only
   `'Não aplicável'` strings in the package correspond to explicitly numbered codes in their own years.
6. **"`V1101` (27 codes) and `V7004` (5 codes) are documented categoricals left unlabelled — a coverage
   gap."** Struck: censobr ships `abbrev_state` / `name_state` / `name_region` for 1991
   (`data_prep/R/add_geography_cols.R:47-52`, `:89`, `:256-262`), and
   `tests/testthat/test_read_population.R:121` selects `abbrev_state` from the real 1991 file. The
   NOTE's justification is verified, not merely asserted.
7. **"Type mismatch — the 1991 block compares strings while the 1960/1970/2022 blocks compare
   integers."** Struck: comparison style is a per-year property of the stored parquet (2022/1960/1970
   integer; 2000/2010/1991 string; 1980 mixed by design), the 1991 block is 836/836 string — fully
   self-consistent — and four real labelled values are asserted back out of the 1991 parquet by the
   test suite.
8. **"`V0202` code 7 `'Cômodos'` contradicts the questionnaire's `Cômodo(s)`."** Struck: the dictionary
   reads `7 Cômodos` and R transcribes it; the `(s)` is a form-printing convention, not a category
   name.
9. **"The NOTE cites `data_dictionary(1991, 'population')` / `(1991, 'households')`, which are not valid
   `dataset` values."** Struck: `R/data_dictionary.R:58` accepts
   `c("microdata","tracts","population","households")` and `R/availability.R:21-22` registers 1991 under
   `dictionary_population` and `dictionary_households`.
10. **"`V0316`'s UF list is anachronistic."** Struck: the 1991 census is post-1988, and the dictionary's
    27-unit sequential list — Tocantins at `07`, Roraima `04` and Amapá `06` as states — *is* the 1991
    division. All 97 codes, including the deliberate gaps at 28 and 57, are transcribed exactly; the
    opposite check also passes (nothing pre-1988 survives in the list).
11. **"`V0323` is missing code 3, `Menos de 5 anos`, which the questionnaire shows."** Struck: that
    third rectangle is on the **short** form (CD 1.01, quesito 5, `short_p1_ov.png`). The censobr 1991
    file is the 10 % sample from **CD 1.02**, whose quesito 23 has exactly two rectangles, and the
    `PESS` dictionary lists `1`, `2` plus an unnumbered `- Pessoas com menos de 5 anos`.

---

**Bookend.** Goal: a complete, evidence-backed reconciliation of every 1991 code→label pair in
`add_labels_population()` and `add_labels_households()` against the IBGE dictionary and the CD 1.02
questionnaire, in both directions, with no file under `R/` edited. Met: 80 labelled variables
reconciled both ways (74 gated + 6 in the `across()`), every code→label binding compared
string-by-string by script, **0 wrong bindings and 0 swapped pairs**, 0 unjustified coverage gaps,
0 CRITICALs, 1 MAJOR (an undocumented code whose own comment says it cannot occur) and 5 MINORs, each
with both sides quoted; 11 candidate findings struck as unsupported. The households block's "identical
to the population block" claim was verified by `diff` (354 + 16 lines, byte-identical). No file under
`R/` was modified.

---

## Data verification - run 2026-09-13 against data release **v0.7.0**

Every open question that needed the file was settled by reading the parquets through the
package's own `read_population()` / `read_households()` (dev source via `pkgload::load_all()`).
Script and full log: `scratchpad/verify_labels.R`, `scratchpad/verify_labels.log`.

### The MAJOR (`V0303 == '16'`) - **CONFIRMED and FIXED**

Marginal counts on `1991_population_v0.7.0.parquet`:

| variable | code `16` |
|---|---|
| `V0302` | **present - 5,451 records** |
| `V0303` | **absent - the value never occurs** |

Exactly as the dictionary says, and as the comment above the arm claimed. The arm was dead code
copied from `V0302`.

**Action taken:** the `V0303 == '16'` arm was deleted from `R/add_labels_population.R`, and the
comment above the block now records the evidence (the dictionary lists 1-15 + 20; the v0.7.0 file
takes no value 16; `V0302` does, 5,451 times).

### The leading-zero MINOR - **question answered, test gap closed**

All 1991 codes are stored **unpadded**: `V0302` and `V0303` take `'1'`, `'2'`, ... `'15'`, `'20'`
(`V0302 == '1'` -> 3,971,582; `V0303 == '1'` -> 4,271,509); `V0316` takes `'1'`, `'2'`, `'10'` ...;
households `V2013` takes `'1'` (28,101) through `'13'`. The block's stated assumption is verified.

**Action taken:** `tests/testthat/test_read_population.R` now asserts `'Chefe' %in% test1991$V0302`.
`'Chefe'` is code `'1'` of a 2-wide field, so unlike the pre-existing two-character assertions it
fails if padding ever reappears. The four remaining MINORs (`V3471`, `V0310`, `V0214`, the two NOTE
blocks) are documentation/wording and are unaffected by the data.

---

## Fixes applied — 2026-09-13 (plan: `quality_reports/plans/synthetic-dancing-hippo.md`)

Both sides were corrected together, ahead of retiring the served HTML dictionaries in favour
of `[year]_dictionary_microdata_formatted.xlsx`. Every edit is traceable to this year's
questionnaire; where the questionnaire is silent the dictionary governed and the labels
followed it. Verified: workbook structure unchanged (dimensions, merged ranges, fonts, cell
counts, per-cell line counts), both R files parse, the new strings come back from the v0.7.0
parquets, and every touched label now matches its dictionary line.

### Dictionary — `1991_dictionary_microdata_formatted.xlsx` (7 line edits)

| Sheet/cell | Was | Now | Authority |
|---|---|---|---|
| DOMI B37 · `V0214` | `6 Jogado em rio, lago, lagoa ou mar` | `6 Jogado em rio, lago ou mar` | quesito 14 box 6 — the form has no "lagoa" |
| PESS B53 · `V0333` | `6- … ou separado judicialmente` | `… ou separado(a) judicialmente` | quesito 33 |
| PESS B48 · `V0329` | `18- Outro -1º grau - Industrial` | `18- Outro - 1º grau - Industrial` | spacing, matching codes 15/20/23 |
| PESS B102 · `V0310` | `77- Oriental Seicho No-Ie` | `77- Oriental Seicho-No-Ie` | write-in question; approved as a typo fix |
| PESS B102 · `V0310` | `85/86/89- … mal definidas` | `… mal definida` | agreement with "determinada" |

**Side effect worth noting:** with `V0214` and `V0333` corrected, the block NOTE's claim that the
questionnaire *"agrees with the dictionary throughout"* is now **true**, so the MINOR that falsified
it is closed without touching the comment.

### Labels

- `V3471` codes 4, 7, 8, 9 and 10 now carry the dictionary's parentheticals, so `'Social'` reads
  `'Social (comunitárias, médicas, odontológicas e ensino)'` and code 4 is no longer confusable with
  code 11. Code 11's own parenthetical is a 250-character list and stays out — now **disclosed** in a
  comment, exactly as `V0329` does
- `V0310`: labels unchanged; the dictionary was corrected to them instead (maintainer's call)
- `V0214` code 6 → `'Jogado em rio, lago ou mar'` in both files
- both block NOTEs completed: `V0317`, `V0318`, `V3152` (population) and the `V0098`/`V0099` record
  fields (households)
- `V0303`'s undocumented code-16 arm was deleted earlier, after the parquet confirmed the value never
  occurs

### Nothing open
