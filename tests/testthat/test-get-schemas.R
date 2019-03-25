context("test-get-schemas")

# Preliminaries ----------------------------------------------------------------

skip_if_not(curl::has_internet(), "Skipping tests; no internet")


# Tests ------------------------------------------------------------------------

test_that(".get_schemas() works with default args", {
  expect_error(
    sch <- .get_schemas(quote = ""),     # Note quote = "" handles data error
    NA
  )
})

test_that(".get_schemas() is silent by default and noisy with debug = TRUE", {
  expect_silent(
    sch <- .get_schemas(quote = "")
  )
  skip("Skip debug test which only passes interactively")
  expect_message(
    sch <- .get_schemas(debug = TRUE, quote = "")
  )
})
