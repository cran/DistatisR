% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read.df.excel.R
\name{read.df.excel}
\alias{read.df.excel}
\title{\code{read.df.excel} reads \code{distatis} formated
 ranking or sorting data from an excel file.}
\usage{
read.df.excel(path, sheet, col_names = TRUE, voc.sheet = NULL)
}
\arguments{
\item{path}{the name of the \code{.xlsx} file (including
the path to the directory if needed, and
the \code{.xlsx} extension). No default.}

\item{sheet}{the name of the sheet where the
(e.g., Sorting or Ranking) data are stored. No default.}

\item{col_names}{(default \code{TRUE})
parameter \code{col.names} from
\code{readxl::read_excel}:
"\code{TRUE} to use the first row as column names,
\code{FALSE} to get default names, or a character vector giving
a name for each column."}

\item{voc.sheet}{If not \code{NULL}
(default) gives the name of the sheet where an optional
contingency table  (products by names) could be stored.
Needs to have the same row names as the sorting/ranking
data frame (df.data) to be useful (but he program does not check).

@return 
a list with one data frame  `$df.data` (contains the data) 
when `voc.sheet = NULL`
or if not: two data frames 
 `$df.data` (contains the data) and 
 `$df.voc` (contains the vocabulary).}
}
\description{
\code{read.df.excel} reads \code{distatis} formated
 ranking or sorting data from an excel file.
}
\details{
@details 
 The data are read from an excel file in which the rows
 are the Products to evaluate and the columns are the Assessors
 (e.g., Judges, Participants, Subjects, Evaluators).
 Depending upon the type of data, the numbers represent
 a partition, a rank, or a score.
 These data are used as input of
 \code{DistanceFromSort} or
 \code{DistanceFromRank}.
 A contingency table for the vocabulary can also be read
 in a different sheet. \code{read.df.excel} is a (small) shell
 on top of \code{readxl::read_excel}, note however that
 whereas \code{readxl::read_excel} returns a \code{tibble},
 \code{read.df.excel} returns a list with one or two
 (depending upon the options) \emph{dataframe(s)}.
}
\author{
Herve Abdi
}
