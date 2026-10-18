% Generated manually because roxygen2 cannot load optional runtime dependencies in this environment.
\name{label_variable_metadata}
\alias{label_variable_metadata}
\title{List aliases and descriptions for configured label variables}
\usage{
label_variable_metadata(
  dataset,
  year,
  lang = "pt",
  root = system.file("labels", package = "censobr")
)
}
\arguments{
\item{dataset}{Character scalar identifying the dataset.}

\item{year}{Numeric scalar identifying the census year.}

\item{lang}{Character scalar identifying the language.}

\item{root}{Root directory containing dataset label directories.}
}
\value{
A data frame with the dataset, year, language, original variable name, alias,
and description declared by the label configuration.
}
\description{
Lists optional aliases and descriptions declared for label variables. These
metadata do not rename, add, or remove columns from the returned data.
}
