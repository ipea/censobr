# Is a downloaded file incomplete?

Is a downloaded file incomplete?

## Usage

``` r
download_is_incomplete(actual, expected, encoding)
```

## Arguments

- actual:

  Numeric. Size of the file on disk, or NA if it does not exist.

- expected:

  String. The `content-length` reported by the server, or NULL.

- encoding:

  String. The `content-encoding` reported by the server, or NULL.

## Value

Logical.
