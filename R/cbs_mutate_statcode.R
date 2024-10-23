#' @title Mutate the statcode of cbs_pchn6
#' @description
#' Mutate the base statcode format in the cbs_pchn6 table to make it joinable with other CBS data
#'
#' @return A column with the the correct format of statcodes to be able to join them to other CBS data
#' @examples
#' data <-PDOK::cbs_pchn6(jaar=2023)
#' data$code_wijk <- sapply(data$code_wijk, function(x) cbs_mutate_statcode(x, "WK"))
#' data <- left_join(data, wijk, by=c("code_wijk"="statcode"))
#' @export


cbs_mutate_statcode <- function(code, prefix) {
  nchar_code <- nchar(code)

  # Logic for WK prefix (lengths 4, 5, 6)
  if (prefix == "WK") {
    if (nchar_code == 4) {
      return(paste0("WK00", code))  # For nchar = 4, add WK00
    } else if (nchar_code == 5) {
      return(paste0("WK0", code))   # For nchar = 5, add WK0
    } else if (nchar_code == 6) {
      return(paste0("WK", code))    # For nchar = 6, add WK
    }
  }

  # Logic for BU prefix (lengths 6, 7, 8)
  if (prefix == "BU") {
    if (nchar_code == 6) {
      return(paste0("BU00", code))  # For nchar = 6, add BU00
    } else if (nchar_code == 7) {
      return(paste0("BU0", code))   # For nchar = 7, add BU0
    } else if (nchar_code == 8) {
      return(paste0("BU", code))    # For nchar = 8, add BU
    }
  }

  # Logic for GM prefix (lengths 2, 3, 4)
  if (prefix == "GM") {
    if (nchar_code == 2) {
      return(paste0("GM00", code))  # For nchar = 2, add GM0000
    } else if (nchar_code == 3) {
      return(paste0("GM0", code))   # For nchar = 3, add GM000
    } else if (nchar_code == 4) {
      return(paste0("GM", code))    # For nchar = 4, add GM00
    }
  }

  return(code)
}


