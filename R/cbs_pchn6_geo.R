#' @title Get the pchn6 tabel from cbs, GEO encoded with PDOK
#' @description
#' This function gives back a dataframe containing the whole cbs pchn6 table enriched with the geolocation added by running pdok_find_coordinates on it. It has a 99% + coverage
#'
#' @return A dataframe.
#' @examples
#' df <-PDOK::cbs_pchn6_geo
#' @export


cbs_pchn6_geo <- function(){

    e <- new.env()
    data("pchn6_geo", package = "PDOK", envir = e)
    return(e$pchn6_geo)
  }
