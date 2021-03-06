% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pt_tables.R
\name{pt_tables}
\alias{pt_tables}
\title{List the tables in the PubTator sqlite database}
\usage{
pt_tables(db_con)
}
\arguments{
\item{db_con}{A connection to the PubTator sqlite database, as created via
pubator_connector.}
}
\value{
A character vector of the names of the tables found in the database.
}
\description{
List the tables in the PubTator sqlite database
}
\examples{
\donttest{
db_con <- pt_connector(pt_path)
pt_tables(db_con)
}
}
