context("test-ukbschemas-db")

# Preliminaries ----------------------------------------------------------------

use_prefix <- .test_data_path()

skip_if_not(curl::has_internet(), "Skipping tests; no internet")

test_db_file <- function() basename(tempfile(fileext = ".sqlite"))
test_db_path <- tempdir()


# Tests ------------------------------------------------------------------------

# Note: closure of db connection after ukbschemas_db() is tested throughout

test_that("ukbschemas_db() runs without errors or warnings", {
  
  expect_error(
    db1 <- ukbschemas_db(
      file = test_db_file(), 
      path = test_db_path, 
      url_prefix = use_prefix
    ),
    NA
  )
  expect_false(DBI::dbIsValid(db1))
  
  expect_warning(
    db2 <- ukbschemas_db(
      file = test_db_file(), 
      path = test_db_path,
      url_prefix = use_prefix
      ),
    NA
  )
  expect_false(DBI::dbIsValid(db2))
  
})


test_that("ukbschemas_db() runs silently if required", {
  expect_silent(
    db <- ukbschemas_db(
      file = test_db_file(),
      path = test_db_path,
      silent = TRUE,
      url_prefix = use_prefix
    )
  )
  expect_false(DBI::dbIsValid(db))
})


test_that("ukbschemas_db() fails on overwrite = FALSE, non-interactive", {
  
  db_file <- test_db_file()
  
  expect_error(
    db1 <- ukbschemas_db(
      file = db_file, 
      path = test_db_path,
      url_prefix = use_prefix
    ),
    NA
  )
  
  expect_false(DBI::dbIsValid(db1))
  
  expect_error(
    {
      db2 <- ukbschemas_db(
        file = db_file, 
        path = test_db_path,
        url_prefix = use_prefix
      )
      suppressWarnings(DBI::dbDisconnect(db2))
    },
    UKBSCHEMAS_ERRORS$OVERWRITE
  )
  
})


test_that("ukbschemas_db() fails to overwrite when db is connected", {
  
  # This only seems to work on Windows
  skip_if_not(.Platform$OS.type == "windows", "Skipping test if not Windows")
  
  db_file <- test_db_file()
  
  expect_error(
    {
      db1 <- ukbschemas_db(
        file = db_file, 
        path = test_db_path,
        url_prefix = use_prefix
      )
      db1 <- DBI::dbConnect(db1)
    },
    NA
  )
  
  expect_true(
    DBI::dbIsValid(db1)
  )
  
  expect_error(
    {
      db2 <- ukbschemas_db(
        file = db_file, 
        path = test_db_path,
        overwrite = TRUE,
        url_prefix = use_prefix
      )
      suppressWarnings(DBI::dbDisconnect(db2))
    },
    UKBSCHEMAS_ERRORS$FAILED_OVERWRITE
  )
  
  suppressWarnings(DBI::dbDisconnect(db1))
  
})


test_that("ukbschemas_db() won't allow in-memory databases", {
  
  expect_error(
    {
      db1 <- ukbschemas_db(
        file = ":memory:", 
        path = test_db_path, 
        url_prefix = use_prefix
      )
      suppressWarnings(DBI::dbDisconnect(db1))
    },
    UKBSCHEMAS_ERRORS$NO_IN_MEMORY
  )
  
  expect_error(
    {
      db2 <- ukbschemas_db(
        file = "file::memory:", 
        path = test_db_path,
        url_prefix = use_prefix
      )
      suppressWarnings(DBI::dbDisconnect(db2))
    },
    UKBSCHEMAS_ERRORS$NO_IN_MEMORY
  )
  
})
