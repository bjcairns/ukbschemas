context("test-tidy-schemas")

# Preliminaries ----------------------------------------------------------------

use_prefix <- .test_data_path()
  
skip_if_not(curl::has_internet(), "Skipping tests; no internet")


# Tests ------------------------------------------------------------------------

# Testing of this function is limited to checking that it runs; ideally the UKB
# schemas will be updated to make most of it obsolete

test_that(".tidy_schemas() works with default args", {
  expect_error(
    sch <- .tidy_schemas(
      .get_schemas(quote = "", url_prefix = use_prefix), 
      silent = TRUE
    ),
    NA
  )
})
