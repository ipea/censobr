# Column types of the microdata tables of the 2022 census

Column types of the four tables in the controlled-access microdata of
the 2022 census, taken from the layout file distributed by IBGE ("Layout
Microdados CD2022 - acesso Controlado.xlsx"), which declares the width
(`POSICAO INICIAL`, `POSICAO FINAL`, `INT`) and the number of decimal
places (`DEC`) of every variable.

The width and the decimal places give the type:

- `DEC > 0` becomes `float64()`. There are only seven such variables.
  The sample weights carry 13 decimal places and the income variables
  carry 9 digits plus 2 decimals, so neither fits in a 32 bit float.

- `DEC == 0` becomes an integer sized by `INT`: `int8()` up to 2 digits,
  `int16()` up to 4, `int32()` up to 9 and `int64()` for the 10 digit
  codes. The "area de ponderacao" is one of the latter: from state 22
  onwards it is above 2147483647 and overflows a 32 bit integer.

- `F0101` and `M0101` are the exception and become `string()`: they
  carry a letter prefix, `"F001"` and `"M001"`. `P0101` looks like them
  but is not, it is a plain count of 1 to 36, so it stays an integer.

Every type was checked against the data: each of the 330 variables was
scanned across all 27 state files of its table, recording the largest
value, whether any value carries letters, and whether any carries
decimals. The type here is the wider of what the layout declares and
what the values require.

Note that the codes are stored as integers, so the leading zeros of the
categorical variables are not kept: `F0120` is `8`, not `"08"`. This
departs from the microdata of the other censuses, where the codes are
strings.

Declaring the schema also bypasses the type inference of arrow, which
reads only the first block of the first file and therefore mistypes the
variables that happen to be blank in it.

These are functions, and not stored objects, because an
[`arrow::schema()`](https://arrow.apache.org/docs/r/reference/schema.html)
is an external pointer: an object created when the package is built
would be restored as a null pointer when the package is loaded.

## Usage

``` r
schema_households()

schema_families()

schema_mortality()

schema_population()
```

## Value

An
[`arrow::schema()`](https://arrow.apache.org/docs/r/reference/schema.html).
