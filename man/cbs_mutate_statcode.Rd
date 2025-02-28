% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cbs_mutate_statcode.R
\name{cbs_mutate_statcode}
\alias{cbs_mutate_statcode}
\title{Mutate the statcode of cbs_pchn6}
\usage{
cbs_mutate_statcode(code, prefix)
}
\value{
A column with the the correct format of statcodes to be able to join them to other CBS data
}
\description{
Mutate the base statcode format in the cbs_pchn6 table to make it joinable with other CBS data
}
\examples{
data <-PDOK::cbs_pchn6(jaar=2023)
data$code_wijk <- sapply(data$code_wijk, function(x) cbs_mutate_statcode(x, "WK"))
data <- left_join(data, wijk, by=c("code_wijk"="statcode"))
}
