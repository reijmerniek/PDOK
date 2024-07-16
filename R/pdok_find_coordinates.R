#' @title Get coordinates for Dutch addresses
#' @description This function will query the PDOK API to get coordinates for your input. It first finds whether or not your input returns a suggestions. If so it will take the first one and find its coordinates. Using postcode: and huisnummer: gives good consistent results
#'
#' @param input Input for coordinates, postcodes/ street names etc. Not all structures work, you should try a few to see what works for your inputdata.
#' @param  verbose_succes If TRUE it will print the current input including the coordinates on a succesfull API call.
#'
#' @return a coordinates string
#'
#' @examples
#'
#' coordinates <-pdok_find_coordinates(input ="Amsterdam", verbose_succes = TRUE)
#'
#' @import jsonlite
#' @import httr
#' @export
#'

pdok_find_coordinates  <- function(input,verbose_succes = TRUE){
  suggest_url <- "https://api.pdok.nl/bzk/locatieserver/search/v3_1/suggest"

  suggest_params <- list(
    q = input,
    fl = "id,weergavenaam,type,score",
    sort = "score desc, sortering asc, weergavenaam asc"
  )
  suggest_response <- GET(suggest_url, query = suggest_params)

  if (status_code(suggest_response) == 200) {
    suggest_content <- content(suggest_response, as = "text", encoding = "UTF-8")
    suggest_result <- fromJSON(suggest_content)

    if (length(suggest_result$response$docs) > 0) {
      object_id <- suggest_result$response$docs$id[[1]]
    } else {
      stop("No results found.")
    }
  } else {
    stop(paste("Error:", status_code(suggest_response)))
  }
  if (exists("object_id")) {
    lookup_url <- paste0("https://api.pdok.nl/bzk/locatieserver/search/v3_1/lookup?id=", object_id)

    lookup_params <- list(
      fl = "id,centroide_ll"
    )

    lookup_response <- GET(lookup_url, query = lookup_params)
    if (status_code(lookup_response) == 200) {
      lookup_content <- content(lookup_response, as = "text")
      lookup_result <- fromJSON(lookup_content)

      if (length(lookup_result$response$docs) > 0) {
        if ("centroide_ll" %in% names(lookup_result$response$docs)) {

          swap_coordinates <- function(point) {
            coordinates <- gsub("POINT\\(|\\)", "", point)
            coords <- strsplit(coordinates, " ")[[1]]
            swapped_coords <- paste(coords[2], coords[1], sep=", ")
            return(swapped_coords)
          }
          gps_coordinates <- swap_coordinates(lookup_result$response$docs$centroide_ll)

          if(verbose_succes==TRUE){
            print(paste0(input, " Coordinates: ", gps_coordinates))
          }

          return(gps_coordinates)

        } else {
          print("Field 'centroide_ll' not found in the response.")
        }
      } else {
        print("No results found.")
      }
    } else {
      print(paste("Error:", status_code(lookup_response)))
    }
  } else {
    print("Object ID not found.")
  }

}



