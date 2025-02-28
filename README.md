
# PDOK: Postcode/Huisnummer and Geolocation Utilities

PDOK is a collection of R utilities to interact with the Dutch public
service provider’s API. This package provides tools to import custom
postcode/huisnummer datasets, get coordinates for Dutch addresses,
retrieve WFS dataset descriptions and execute queries on WFS geodata.

## Table of Contents

- [Overview](#overview)
- [Getting Started](#getting-started)
- [Functions](#functions)
- [Examples](#examples)
- [Contributing](#contributing)

## Overview

PDOK is designed to simplify the process of working with Dutch public
service data. It provides a set of functions that can be used to import
postcode/huisnummer datasets, get coordinates for addresses, and execute
queries on WFS geodata. I build this package becaues i was inspired by
some guides posted on cbs.nl. With this package i want to create some
quality of life functions to use when making maps. For inspiration on
what I made with this package see my other repository:
<https://github.com/reijmerniek/RVisuals> or my shiny server:
<https://shinyreijmer.com>

## Getting Started

To use PDOK, you’ll need to install it from github:

``` r
devtools::install_github("reijmerniek/PDOK")
```

Once installed, load the package in R:

``` r
library(PDOK)
```

## Functions

The following functions are currently available in PDOK:

### cbs_pchn6()

Import Postcode/huisnummer tabels from cbs.nl.

``` r
cbs_pchn6(jaar, remove_files = TRUE, add_names = TRUE)
```

### cbs_pchn6_geo()

Get the pchn6 tabel from cbs, GEO encoded with PDOK.

``` r
cbs_pchn6_geo()
```

### pdok_find_coordinates()

Get coordinates for Dutch addresses.

``` r
pdok_find_coordinates(input, verbose_succes = TRUE)
```

### pdok_wfs_datasets()

Get all WFS dataset descriptions and respective queries.

``` r
pdok_wfs_datasets(stored_df = TRUE)
```

### pdok_wfs_query()

Execute query to get wfs geodata.

``` r
pdok_wfs_query(
query_number,
dataframe,
query_column = "query_nr",
link_column = "query",
full = TRUE
)
```

### cbs_mutate_statcode()

Adjust statcode format of main CBS pchn6 table

``` r
data <-PDOK::cbs_pchn6(jaar=2023)
data$code_wijk <- sapply(data$code_wijk, function(x) cbs_mutate_statcode(x, "WK"))
data <- left_join(data, wijk, by=c("code_wijk"="statcode"))
```

## Examples

The following examples demonstrate how to use some of the functions in
PDOK:

### cbs_pchn6()

``` r
df <-PDOK::cbs_pchn6(jaar=2023, remove_files =TRUE, add_names= TRUE)
```

### cbs_pchn6_geo()

``` r
df <-PDOK::cbs_pchn6_geo()
```

### pdok_find_coordinates()

``` r
coordinates <-pdok_find_coordinates(input ="Amsterdam", verbose_succes = TRUE)
```

### pdok_wfs_datasets()

``` r
df <-PDOK::pdok_wfs_datasets(stored_df =TRUE)
df <-PDOK::pdok_wfs_datasets(stored_df =FALSE)
```

### pdok_wfs_query()

``` r
df <-PDOK::pdok_wfs_query(
query_number,
dataframe,
query_column = "query_nr",
link_column = "query",
full = TRUE
)
```

### cbs_mutate_statcode()

``` r
data <-PDOK::cbs_pchn6(jaar=2023)
data$code_wijk <- sapply(data$code_wijk, function(x) cbs_mutate_statcode(x, "WK"))
data <- left_join(data, wijk, by=c("code_wijk"="statcode"))
```

## Contributing

If you’d like to contribute to PDOK, please see the
[CONTRIBUTING.md](CONTRIBUTING.md) file for guidelines.

## License

PDOK is licensed under the MIT License. See [LICENSE](LICENSE) for
details.
