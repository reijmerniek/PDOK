# Refresh pdok_datasets by scraping the live PDOK WFS catalogue.
#
# Run manually from the package root when PDOK adds/removes datasets.
# Takes a few minutes (scrapes ~100+ dataset pages).
# Requires: PDOK, devtools

library(PDOK)

cat("Scraping PDOK WFS catalogue...\n")
t_start <- proc.time()
pdok_datasets <- pdok_wfs_datasets(stored_df = FALSE)
t_end <- proc.time()
cat("Done in", round((t_end - t_start)["elapsed"], 1), "seconds.\n")
cat("Datasets:", nrow(pdok_datasets), "rows\n")

save(pdok_datasets, file = "data/pdok_datasets.rda", compress = "xz")
cat("Saved data/pdok_datasets.rda\n")
