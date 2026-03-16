# Full function test — run this after installing from GitHub
# devtools::install_github("reijmerniek/PDOK")

library(PDOK)

cat("=== 1. cbs_pchn6 ===\n")
df2025 <- cbs_pchn6(jaar = 2025, add_names = TRUE)
df2023 <- cbs_pchn6(jaar = 2023, add_names = TRUE)
cat("2025:", nrow(df2025), "rows,", ncol(df2025), "cols\n")
cat("2023:", nrow(df2023), "rows,", ncol(df2023), "cols\n")

cat("\n=== 2. cbs_pchn6_geo ===\n")
geo <- cbs_pchn6_geo()
cat("Rows:", nrow(geo), "\n")
print(head(geo))

cat("\n=== 3. pdok_find_coordinates ===\n")
coords <- pdok_find_coordinates("Dam 1 Amsterdam", verbose_succes = TRUE)
cat("Result:", coords, "\n")

cat("\n=== 4. pdok_wfs_datasets ===\n")
wfs <- pdok_wfs_datasets(stored_df = TRUE)
cat("Rows:", nrow(wfs), "\n")
print(head(wfs[, c("Title", "Type", "ProviderName")]))

cat("\n=== 5. cbs_mutate_statcode ===\n")
tests <- list(
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
all_pass <- TRUE
for (t in tests) {
  result <- cbs_mutate_statcode(t$code, t$prefix)
  pass <- result == t$expected
  if (!pass) all_pass <- FALSE
  cat(t$prefix, nchar(t$code), "chars:", if (pass) "OK" else paste("FAIL — got", result, "expected", t$expected), "\n")
}
cat(if (all_pass) "\nAll cbs_mutate_statcode tests passed.\n" else "\nSome tests FAILED.\n")
