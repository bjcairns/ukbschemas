context("test-tidy-schemas")

# Preliminaries ----------------------------------------------------------------

OLD_UKB_URL_PREFIX <- getFromNamespace("UKB_URL_PREFIX", "ukbschemas")
assignInNamespace(
  "UKB_URL_PREFIX", 
  suppressWarnings(normalizePath("../test-data/")), 
  "ukbschemas"
)
on.exit(
  assignInNamespace(
    "UKB_URL_PREFIX", 
    OLD_UKB_URL_PREFIX, 
    "ukbschemas"
  )
)
  
skip_if_not(curl::has_internet(), "Skipping tests; no internet")


# Tests ------------------------------------------------------------------------

# Testing of this function is limited to checking that it runs; ideally the UKB
# schemas will be updated to make most of it obsolete

test_that(".tidy_schemas() works with default args", {
  expect_error(
    sch <- .tidy_schemas(.get_schemas(quote = ""), silent = TRUE),
    NA
  )
})
