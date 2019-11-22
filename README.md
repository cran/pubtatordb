# pubtatordb


[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/pubtatordb)](https://cran.r-project.org/package=pubtatordb)
[![Travis-CI Build Status](https://travis-ci.org/MAMC-DCI/pubtatordb.svg?branch=master)](https://travis-ci.org/MAMC-DCI/pubtatordb#)
[![Build status](https://ci.appveyor.com/api/projects/status/deltes4sus3dcj69?svg=true)](https://ci.appveyor.com/project/mamcdci/pubtatordb)
[![Coverage Status](https://img.shields.io/codecov/c/github/mamc-dci/pubtatordb/master.svg)](https://codecov.io/github/mamc-dci/pubtatordb?branch=master)
[![DOI](https://zenodo.org/badge/169114045.svg)](https://zenodo.org/badge/latestdoi/169114045)


The goal of pubtatordb is to allow users to create and query a local version of the PubTator database. [PubTator](https://www.ncbi.nlm.nih.gov/CBBresearch/Lu/Demo/PubTator/) provides detailed annotations of abstracts found on PubMed. It is therefore very useful for directing research questions. While PubTator does provide an API, the use of a local database is more appropriate for high-throughput analyses. pubtatordb provides the tools necessary to download, setup, and query such a database.


## Installation

You can install the released version of pubtatordb from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("pubtatordb")
```


The version on GitHub can be downloaded using the devtools package with:

``` r
install.packages("devtools")
devtools::install_github("MAMC-DCI/pubtatordb")
```


## Example

Querying is only four steps away:

``` r
# Load the package.
library(pubtatordb)

# Download the data.
download_pt(getwd())

# Create the database.
pubtator_path <- file.path(getwd(), "PubTator")
pt_to_sql(
  pubtator_path,
  skip_behavior = FALSE,
  remove_behavior = TRUE,
  db_from_scratch = TRUE
)

# Create a connection to the database.
db_con <- pt_connector(pubtator_path)

# Query the data.
pt_select(
  db_con,
  "gene",
  columns = NULL,
  keys = NULL,
  keytype = NULL,
  limit = 5
)
```


## Disclaimer
The views expressed are those of the author(s) and do not reflect the official policy of the Department of the Army, the Department of Defense or the U.S. Government.
