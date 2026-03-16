# Refresh pchn6_geo with new entries from the latest CBS postcode/huisnummer table.
#
# Steps:
#   1. Load existing cached geo data
#   2. Download the latest year's CBS table (update `jaar` below each year)
#   3. Find new pc/hn combinations not yet in the geo cache
#   4. Geocode new entries in parallel via PDOK API
#   5. Append and save back to data/pchn6_geo.rda
#
# Run manually from the package root (or via GitHub Actions).
# Requires: PDOK, dplyr, parallel

library(PDOK)
library(dplyr)
library(parallel)

# ---- Config ----------------------------------------------------------------
jaar         <- 2025   # <-- update this each year
num_workers  <- 14     # parallel workers for geocoding
# ----------------------------------------------------------------------------

# 1. Load existing geo cache
geo <- cbs_pchn6_geo()
cat("Existing geo entries:", nrow(geo), "\n")

# 2. Download latest CBS table (only need pc + hn to find new entries)
cat("Downloading cbs_pchn6 for", jaar, "...\n")
latest <- cbs_pchn6(jaar = jaar, add_names = FALSE)
latest  <- latest[, c("pc", "hn")]

# 3. Find new entries not yet geocoded
new_entries <- anti_join(latest, geo[, c("pc", "hn")], by = c("pc", "hn"))
cat("New entries to geocode:", nrow(new_entries), "\n")

if (nrow(new_entries) == 0) {
  cat("Nothing to do — geo cache is already up to date.\n")
  quit(save = "no", status = 0)
}

new_entries$coordinates <- NA_character_

# 4. Geocode in parallel
process_chunk <- function(chunk) {
  library(PDOK)
  for (i in seq_len(nrow(chunk))) {
    chunk$coordinates[i] <- tryCatch(
      pdok_find_coordinates(
        input         = paste0("postcode:", chunk$pc[i], " huisnummer:", chunk$hn[i]),
        verbose_succes = FALSE
      ),
      error = function(e) "error"
    )
  }
  chunk
}

cl     <- makeCluster(num_workers)
chunks <- split(new_entries, cut(seq(nrow(new_entries)), num_workers, labels = FALSE))
clusterExport(cl, varlist = c("process_chunk"))

cat("Geocoding", nrow(new_entries), "entries across", num_workers, "workers...\n")
t_start <- proc.time()
results <- parLapply(cl, chunks, process_chunk)
stopCluster(cl)
t_end <- proc.time()
cat("Done in", round((t_end - t_start)["elapsed"], 1), "seconds.\n")

geocoded <- do.call(rbind, results)
row.names(geocoded) <- NULL

cat("Geocoded:", sum(!is.na(geocoded$coordinates) & geocoded$coordinates != "error"), "/", nrow(geocoded), "\n")

# 5. Append and save
pchn6_geo <- rbind(geo, geocoded)
row.names(pchn6_geo) <- NULL

save(pchn6_geo, file = "data/pchn6_geo.rda", compress = "xz")
cat("Saved data/pchn6_geo.rda —", nrow(pchn6_geo), "total entries.\n")
