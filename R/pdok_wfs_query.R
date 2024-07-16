#' @title Execute query to get wfs geodata.
#' @description This function can execute queries that are stored in the dataframe that comes out of wfs_datasets(). It can do a single query or query the full underlying dataset.
#'
#'
#' @param dataframe The dataframe from which to get your query, it can be called by using wfs_datasets()
#' @param query_column The column in which the queries are stored, defaults to 'query_nr'
#' @param query_number The row related to the query in the query column
#' @param link_column  The column in which the queries are stored, defaults to 'query'
#' @param full TRUE/FALSE, if TRUE it will query until there are no more results left, if FALSE it will query max 1k once.
#'
#' @return A dataframe.
#' @examples
#' wfs_results <- pdok_wfs_query( query_number =1, dataframe = df, full=TRUE)
#' @import sf
#'
#' @export

pdok_wfs_query <- function(query_number, dataframe, query_column = "query_nr", link_column = "query" , full= TRUE) {
  if (!(query_column %in% colnames(dataframe))) {
    stop("query_column is not a valid column name in the dataframe")
  }
  if (!(link_column %in% colnames(dataframe))) {
    stop("link_column is not a valid column name in the dataframe")
  }

  query_string <- dataframe[[link_column]][dataframe[[query_column]] == query_number]

  if (length(query_string) == 0) {
    stop("Query number not found")
  }

  if(full==FALSE) {
    result <- tryCatch(
      st_read(query_string),
      error = function(e) {
        message("Error in reading the data: ", e)
        return(NULL)
      }
    )
    return(result)
  } else if (full==TRUE){
    all_features <- NULL
    startIndex <- 0

    repeat {
      query_url <- paste0(query_string, "&count=1000&startIndex=", startIndex)
      current_features <- tryCatch(
        st_read(query_url),
        error = function(e) {
          message("Error in reading the data: ", e)
          return(NULL)
        }
      )
      if (is.null(current_features) || nrow(current_features) == 0) {
        break
      }
      if (is.null(all_features)) {
        all_features <- current_features
      } else {
        all_features <- rbind(all_features, current_features)
      }
      startIndex <- startIndex + 1000
    }
    return(all_features)
  }
  else {
    message("'full' not filled with TRUE/FALSE")
  }
}

