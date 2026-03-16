# PDOK - Dutch Geospatial Data Package

Public R package providing easy access to PDOK.nl (Dutch open geospatial data) with pre-cached datasets for offline use.

Install: `devtools::install_github("reijmerniek/PDOK")`

---

## Functions

| Function | Description |
|---|---|
| `cbs_pchn6(jaar, add_names)` | Downloads CBS postcode6-huisnummer table for a given year (2017–2025). Downloads ~20MB zip from cbs.nl. |
| `cbs_pchn6_geo()` | Returns the full pre-cached pc6/huisnummer table with GPS coordinates (~8M rows). Bundled in `data/pchn6_geo.rda`. |
| `pdok_find_coordinates(input)` | Geocodes a Dutch address via the PDOK API. Returns lat/lon string. Very fast, no auth needed. |
| `pdok_wfs_datasets(stored_df)` | Returns a catalogue of PDOK WFS datasets. `stored_df=TRUE` uses bundled data, `FALSE` scrapes live from pdok.nl. |
| `pdok_wfs_query(query_number, dataframe, full)` | Executes a WFS query from the `pdok_wfs_datasets()` catalogue. `full=TRUE` paginates through all results (1000 per page). Returns an `sf` dataframe. |
| `cbs_mutate_statcode(code, prefix)` | Pads a CBS stat code to the correct format (e.g. `WK`, `BU`, `GM`). |

## Key Files

| File | Purpose |
|---|---|
| `R/` | All function implementations |
| `data/pchn6_geo.rda` | Cached postcode/huisnummer GPS table (~8M rows) |
| `data/pdok_datasets.rda` | Cached WFS dataset catalogue (1505 rows) |
| `data-raw/refresh_pchn6_geo.R` | Script to update `pchn6_geo.rda` with new CBS entries |
| `data-raw/refresh_pdok_datasets.R` | Script to re-scrape WFS catalogue from pdok.nl |
| `tests/test_all_functions.R` | Manual smoke test for all functions |
| `coordinates db/script laden coordinaten.R` | Original parallel geocoding script (reference only) |

---

## Yearly Update Process (run every October)

CBS releases new postcode tables annually around August/September. The update process takes ~10 minutes.

### Step 1 — Open the project in RStudio
```r
setwd("C:/Users/reijm/OneDrive/Projects/big_projects/r_pdok_package")
```

### Step 2 — Refresh cached data
```r
# Update pchn6_geo with new CBS entries (geocodes new pc/hn combos in parallel)
source("data-raw/refresh_pchn6_geo.R")

# Re-scrape WFS catalogue from pdok.nl (~3 minutes)
source("data-raw/refresh_pdok_datasets.R")
```

### Step 3 — Reinstall and test
```r
devtools::install()
source("tests/test_all_functions.R")
```

### Step 4 — Commit and push
```bash
git add data/pchn6_geo.rda data/pdok_datasets.rda
git commit -m "Update cached data to [YEAR]"
git push origin master
```

---

## Testing Plan

### Manual smoke test (run after any change)
```r
source("tests/test_all_functions.R")
```
Covers all 5 functions with expected outputs. Paste failures here if debugging.

### What to check each October
- `cbs_pchn6(jaar = [NEW_YEAR])` — does the new year's zip download and parse correctly?
- `refresh_pchn6_geo.R` — how many new entries? (expect ~50k–100k per year)
- `pdok_find_coordinates("Dam 1 Amsterdam")` — API still returns valid coords?
- `pdok_wfs_datasets(stored_df = FALSE)` — does the live scrape still work? (PDOK may restructure their site)

### Likely failure points
| Issue | Symptom | Fix |
|---|---|---|
| CBS changed zip URL format | `cbs_pchn6()` download fails | Update URL pattern in `R/cbs_pchn6.R` |
| CBS changed CSV column names | `cbs_pchn6()` returns wrong columns | Check column names after `read.csv` and update |
| PDOK API endpoint changed | `pdok_find_coordinates()` errors | Check `https://api.pdok.nl` for new endpoint |
| PDOK site restructured | `pdok_wfs_datasets(stored_df=FALSE)` scrape fails | Update CSS selectors in `R/pdok_wfs_datasets.R` |

---

## GitHub Auth

Push requires a Personal Access Token (PAT) with `repo` scope:
```bash
git remote set-url origin https://reijmerniek:YOUR_TOKEN@github.com/reijmerniek/PDOK.git
git push origin master
```
Generate tokens at: github.com → Settings → Developer settings → Personal access tokens → Tokens (classic)
