context("test-ukbschemas")

# Preliminaries ----------------------------------------------------------------

skip_if_not(curl::has_internet(), "Skipping tests; no internet")


# Tests ------------------------------------------------------------------------

test_that("ukbschemas() runs without errors or warnings", {
  
  expect_error(sch <- ukbschemas(), NA)
  expect_warning(sch <- ukbschemas(), NA)
  
})

test_that("ukbschemas() runs with as_is = TRUE without errors or warnings", {
  
  expect_error(sch <- ukbschemas(as_is = TRUE, silent = TRUE), NA)
  expect_warning(sch <- ukbschemas(as_is = TRUE, silent = TRUE), NA)
  
})

test_that("ukbschemas() runs silently if required", {
  
  expect_silent(sch <- ukbschemas(silent = TRUE))
  
})

test_that("ukbschemas() returns schemas with columns in the right order", {
  
  db <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  .create_tables(db)
  dummy_sch <- load_db(db = db)
  
  expect_error(sch <- ukbschemas(), NA)
  names(sch) %>% 
    purrr::walk(
      ~ expect_equal(names(sch[[.x]]), names(dummy_sch[[.x]]))
    )
  
  .quiet_dbDisconnect(db)
  
})