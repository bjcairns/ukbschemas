context("test-ukbschemas")

# Preliminaries ----------------------------------------------------------------

use_prefix <- .test_data_path()

skip_if_not(curl::has_internet(), "Skipping tests; no internet")


# Tests ------------------------------------------------------------------------

test_that("ukbschemas() runs without errors or warnings", {
  
  expect_error(sch <- ukbschemas(url_prefix = use_prefix), NA)
  expect_warning(sch <- ukbschemas(url_prefix = use_prefix), NA)
  
})

test_that("ukbschemas() runs with as_is = TRUE without errors or warnings", {
  
  expect_error(
    sch <- ukbschemas(
      as_is = TRUE, 
      silent = TRUE, 
      url_prefix = use_prefix
    ), 
    NA
  )
  expect_warning(
    sch <- ukbschemas(
      as_is = TRUE, 
      silent = TRUE, 
      url_prefix = use_prefix), 
    NA
  )
  
})

test_that("ukbschemas() runs silently if required", {
  
  expect_silent(sch <- ukbschemas(silent = TRUE, url_prefix = use_prefix))
  
  # There seems to be no way to force readr to show a progress bar when 
  # reading small files or over fast connections (estimated read time <5
  # seconds), but if there was, this is where a further test would go to 
  # ensure progress bars are always suppressed when silent = TRUE.
  
})

test_that("ukbschemas() returns schemas in the right order", {
  
  db <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  .create_tables(db)
  dummy_sch <- load_db(db = db)
  expect_error(sch <- ukbschemas(url_prefix = use_prefix), NA)
  
  # Schemas in the right order
  expect_identical(names(dummy_sch), names(sch))
  
  # Columns of each in the right order
  names(sch) %>% 
    purrr::walk(
      ~ expect_equal(names(sch[[.x]]), names(dummy_sch[[.x]]))
    )
  
  .quiet_dbDisconnect(db)
  
})
