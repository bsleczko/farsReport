% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fars_functions.R
\name{fars_summarize_years}
\alias{fars_summarize_years}
\title{Summarize FARS accidents for given years}
\usage{
fars_summarize_years(years = c("2013", "2014", "2015"))
}
\arguments{
\item{years}{A list of years, format of each year must be corcible to a valid year by as.integer() function}
}
\value{
This function returns a tibble with number of FARS accidents per month of each year
This function does not produce duplicate records, e.g. c("2015", "2015") will produce only one summary
}
\description{
For given list of years, summarize the FARS accidents per month and year
}
\details{
The function can malfunction in case the dataset for specified year is missing, or is given in wrong format
}
\examples{
fars_summarize_years("2013")
fars_summarize_years(c(2013, 2014))
fars_summarize_years(c("2013", "2014", "2015"))

}
