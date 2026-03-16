# Full function test — run locally or via GitHub Actions
# Local: source("tests/test_all_functions.R")
# GitHub: installs package first, then runs this

library(PDOK)

failures <- character(0)

check <- function(name, expr) {
  tryCatch({
    result <- expr
    cat("  PASS:", name, "\n")
    result
  }, error = function(e) {
    cat("  FAIL:", name, "—", conditionMessage(e), "\n")
    failures <<- c(failures, name)
    NULL
  })
}

# ── 1. cbs_pchn6 ────────────────────────────────────────────────────────────
cat("\n=== 1. cbs_pchn6 ===\n")
df <- check("cbs_pchn6 jaar=2025", cbs_pchn6(jaar = 2025, add_names = TRUE))
if (!is.null(df)) {
  check("cbs_pchn6 has 8 cols",  { stopifnot(ncol(df) == 8); TRUE })
  check("cbs_pchn6 has rows",    { stopifnot(nrow(df) > 7000000); TRUE })
}

# ── 2. cbs_pchn6_geo ─────────────────────────────────────────────────────────
cat("\n=== 2. cbs_pchn6_geo ===\n")
geo <- check("cbs_pchn6_geo loads", cbs_pchn6_geo())
if (!is.null(geo)) {
  check("cbs_pchn6_geo has rows",        { stopifnot(nrow(geo) > 7000000); TRUE })
  check("cbs_pchn6_geo has coordinates", { stopifnot("coordinates" %in% names(geo)); TRUE })
}

# ── 3. pdok_find_coordinates ─────────────────────────────────────────────────
cat("\n=== 3. pdok_find_coordinates ===\n")
coords <- check("pdok_find_coordinates API call", pdok_find_coordinates("Dam 1 Amsterdam", verbose_succes = FALSE))
if (!is.null(coords)) {
  check("coords is character",    { stopifnot(is.character(coords)); TRUE })
  check("coords has comma",       { stopifnot(grepl(",", coords)); TRUE })
  check("coords lat in NL range", {
    lat <- as.numeric(strsplit(coords, ", ")[[1]][1])
    stopifnot(lat > 50.5 && lat < 53.7)
    TRUE
  })
}

# ── 4. pdok_wfs_datasets ─────────────────────────────────────────────────────
cat("\n=== 4. pdok_wfs_datasets ===\n")
wfs <- check("pdok_wfs_datasets stored", pdok_wfs_datasets(stored_df = TRUE))
if (!is.null(wfs)) {
  check("wfs has rows",        { stopifnot(nrow(wfs) > 100); TRUE })
  check("wfs has query column",{ stopifnot("query" %in% names(wfs)); TRUE })
}

# ── 5. pdok_wfs_query ────────────────────────────────────────────────────────
cat("\n=== 5. pdok_wfs_query ===\n")
if (!is.null(wfs)) {
  sf_result <- check("pdok_wfs_query query 1", pdok_wfs_query(query_number = 1, dataframe = wfs, full = FALSE))
  if (!is.null(sf_result)) {
    check("wfs_query returns sf",    { stopifnot(inherits(sf_result, "sf")); TRUE })
    check("wfs_query has rows",      { stopifnot(nrow(sf_result) > 0); TRUE })
    check("wfs_query has geometry",  { stopifnot("geometry" %in% names(sf_result)); TRUE })
  }
}

# ── 6. cbs_mutate_statcode ───────────────────────────────────────────────────
cat("\n=== 6. cbs_mutate_statcode ===\n")
cases <- list(
  list(code="1234",     prefix="WK", expected="WK001234"),
  list(code="12345",    prefix="WK", expected="WK012345"),
  list(code="123456",   prefix="WK", expected="WK123456"),
  list(code="123456",   prefix="BU", expected="BU00123456"),
  list(code="1234567",  prefix="BU", expected="BU01234567"),
  list(code="12345678", prefix="BU", expected="BU12345678"),
  list(code="12",       prefix="GM", expected="GM0012"),
  list(code="123",      prefix="GM", expected="GM0123"),
  list(code="1234",     prefix="GM", expected="GM1234")
)
for (tc in cases) {
  check(paste("statcode", tc$prefix, nchar(tc$code), "chars"), {
    result <- cbs_mutate_statcode(tc$code, tc$prefix)
    stopifnot(result == tc$expected)
    TRUE
  })
}

# ── Summary ──────────────────────────────────────────────────────────────────
cat("\n============================================\n")
if (length(failures) == 0) {
  cat("All tests passed.\n")
} else {
  cat("FAILED tests:\n")
  for (f in failures) cat(" -", f, "\n")
  quit(status = 1)
}
cat("============================================\n")
