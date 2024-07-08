#' Execute query
#' This function give you a dataframe which contains a query per dataste on PDOK.nl/datasets. Each function can be used within sf::st_read() to return a JSON containing vectors and data regarding the data.
#'
#'
#' @param use_stored_df A logical value. If TRUE, return the stored dataframe.
#'                      If FALSE, run a query.
#' @return A dataframe.
#' @examples
#' df <-PDOK::wfs_datasets(use_stored_df =TRUE)
#' df <-PDOK::wfs_datasets(use_stored_df =FALSE)
#' @export

execute_query <- function(query_number, dataframe, query_column = "query_nr", link_column = "link" , full) {
  # Ensure the query_column and link_column are valid column names
  if (!(query_column %in% colnames(dataframe))) {
    stop("query_column is not a valid column name in the dataframe")
  }
  if (!(link_column %in% colnames(dataframe))) {
    stop("link_column is not a valid column name in the dataframe")
  }

  # Find the query string based on query number
  query_string <- dataframe[[link_column]][dataframe[[query_column]] == query_number]

  # Check if the query string is found
  if (length(query_string) == 0) {
    stop("Query number not found")
  }

  if(full==FALSE) {

    result <- st_read(query_string)
    return(result)
  } else if (full==TRUE){
    all_features <- NULL
    startIndex <- 0

    repeat {
      # Construct the query URL with fixed count and startIndex
      query_url <- paste0(query_string, "&count=1000&startIndex=", startIndex)

      # Read the current batch of features
      current_features <- tryCatch(
        st_read(query_url),
        error = function(e) {
          message("Error in reading the data: ", e)
          return(NULL)
        }
      )

      # Check if the current batch has features
      if (is.null(current_features) || nrow(current_features) == 0) {
        break
      }

      # Append the current batch to the all_features
      if (is.null(all_features)) {
        all_features <- current_features
      } else {
        all_features <- rbind(all_features, current_features)
      }

      # Update startIndex for the next iteration
      startIndex <- startIndex + count
    }


  }



}

# Example usage of the function
execute_query(1, total_test)
