% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rv.R
\name{rv}
\alias{rv}
\title{Function to compute the RV coefficient between to conformable matrices}
\usage{
rv(A, B)
}
\arguments{
\item{A}{a matrix,}

\item{B}{a second matrix.}
}
\value{
the RV coefficient between A and B.
}
\description{
Function to compute the RV coefficient between to conformable matrices
}
\examples{

A <- toeplitz(2:1)
B <- diag(2)
rv(A, B)
}
