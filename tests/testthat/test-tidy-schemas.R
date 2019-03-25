context("test-tidy-schemas")

# Preliminaries ----------------------------------------------------------------
  
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
