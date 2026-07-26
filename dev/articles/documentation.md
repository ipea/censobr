# Census documentation

The **{censobr}** package includes a few functions to help users
navigate Brazilian census data, its variables and methodology.

| Function | Documentation | Type | Years available |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|----|
|  |  |  | 1960 | 70 | 80 | 91 | 2000 | 10 | 22 |
| data_dictionary() | Data dictionary (codebook) | Microdata | *X* | X | X | X | X | X | *soon* |
|  |  | Census tract aggregates |  |  |  |  | X | X | *X* |
| questionnaire() | Questionnaires | Long and short | X | X | X | X | X | X | X |
| interview_manual() | Interviewer’s manual (Enumerator Instructions) | \- | X | X | X | X | X | X | X |

All of these functions download supporting documents in either `.html`
or `.pdf` format, and open the documents on a web browser. Like all
other datasets in **{censobr}**, these support documents are downloaded
and cached locally the first time when users run the function. This way,
when users need to take a peak at the documentation again, the functions
simply load local files, making it super quick and convenient.

## Data Dictionary

The
[`data_dictionary()`](https://ipeagit.github.io/censobr/dev/reference/data_dictionary.md)
indicate the definition of each variable, and the meaning of their
categories in the case of categorical variables. The function currently
covers the data dictionaries for all Brazilian censuses since 1960
(`19960`, `1970`, `1980`, `1991`, `2000` and `2010`), and it includes
dictionaries for the variables of both microdata (sample portion of the
census) and for the variables available in census tract-level aggregate
data.

``` r

# Microdata variables
data_dictionary(
  year = 2010,
  dataset = 'microdata'
  )

# Census tract-level variables
data_dictionary(
  year = 2022,
  dataset = 'tracts'
  )
```

## Questionnaires

Oftentimes, it is really important to understand the structure of the
questionnaire used in surveys. The
[`questionnaire()`](https://ipeagit.github.io/censobr/dev/reference/questionnaire.md)
function includes the questionnaires used in the data collection of all
Brazilian censuses since 1970.

Here, users need to pass the `year` parameter indicating the edition of
the census of interest and whether they want the `'short'` questionnaire
that is used to interview all households, or the `'short'` one that is
used in the sample component of the cesus.

``` r

# short questionnaire
questionnaire(
  year = 2022, 
  type = 'short'
  )

# long questionnaire
questionnaire(
  year = 2022, 
  type = 'long'
  )
```

## Interview manual

Finally, the
[`interview_manual()`](https://ipeagit.github.io/censobr/dev/reference/interview_manual.md)
function downloads and opens on a browser the “Manual do Recenseador”,
i.e. the manual of instructions for IBGE’s census takers (recenseadores)
on how to collect the census data.

Manuals for all censuses since 1970 are available.

``` r

# 2022
interview_manual(year = 2022)

# 1960
interview_manual(year = 1960)
```
