library(parallel)
library(DBI)
library(RSQLite)
library(PDOK)
library(dplyr)


con <- dbConnect(RSQLite::SQLite(), dbname = "coordinates_db.sqlite")
df <- dbGetQuery(con, "SELECT * FROM coordinates_db")

dataset <- PDOK::cbs_pchn6(jaar=2023, add_names = TRUE)
dataset <- dataset[,c(1:2)]
dataset$coordinates <- NA

coord_data <- cbs_pchn6_geo()

dataset <- dataset %>%
  anti_join(df, by = c('hn','pc'))


dataset <- dataset[c(1:1000000),]
Sys.time()

num_workers <- 14

cl <- makeCluster(num_workers)

chunks <- split(dataset, cut(seq(nrow(dataset)), num_workers, labels = FALSE))

process_chunk <- function(chunk) {
  for (i in 1:nrow(chunk)) {
    chunk$coordinates[i] <- tryCatch({
      find_coordinates(input = paste0("postcode:", chunk$pc[i], " huisnummer:", chunk$hn[i]), verbose_succes = TRUE)
    }, error = function(e) {
      "error"
    })
  }
  return(chunk)
}

clusterExport(cl, varlist = c("find_coordinates", "process_chunk"))
results <- parLapply(cl, chunks, process_chunk)
combined_results <- do.call(rbind, results)
stopCluster(cl)
Sys.time()

dbWriteTable(con, "coordinates_db", combined_results, append = TRUE)













