.onAttach <- function(libname, pkgname) {
  required_packages <- c("rvest", "tidyverse", "sf", "jsonlite")
  missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

  if (length(missing_packages) > 0) {
    stop(
      paste("The following required packages are not installed:",
            paste(missing_packages, collapse = ", "),
            ". Please install them before using this package.")
    )
  }
}
