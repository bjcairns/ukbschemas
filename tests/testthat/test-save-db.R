context("test-save-db")

# Preliminaries ----------------------------------------------------------------

use_prefix <- .test_data_path()

mtcars_sch <- list(mtcars = tibble::as_tibble(mtcars))
test_db_file <- function() basename(tempfile(fileext = ".sqlite"))
test_db_path <- tempdir()

# Tests ------------------------------------------------------------------------

# Note: closure of db connection after save_db() is tested throughout

test_that("save_db() runs without errors or warnings on mtcars", {
  
  expect_error(
    db <- save_db(
      mtcars_sch, 
      file = test_db_file(), 
      path = test_db_path, 
      as_is = TRUE
    ),
    NA
  )
  
  expect_false(DBI::dbIsValid(db))
  
})


test_that("save_db() runs silently if required", {
  
  expect_silent(
    db <- save_db(
      mtcars_sch,
      file = test_db_file(),
      path = test_db_path,
      silent = TRUE,
      as_is = TRUE
    )
  )
  
  expect_false(DBI::dbIsValid(db))
  
})


test_that("save_db() fails on overwrite = FALSE, non-interactive", {
  
  db_file <- test_db_file()
  
  expect_error(
    db1 <- save_db(mtcars_sch, file = db_file, path = test_db_path, 
                   as_is = TRUE),
    NA
  )
  
  expect_false(DBI::dbIsValid(db1))
  
  expect_error(
    {
      db2 <- save_db(mtcars_sch, file = db_file, path = test_db_path, 
                     as_is = TRUE)
      suppressWarnings(DBI::dbDisconnect(db2))
    },
    UKBSCHEMAS_ERRORS$OVERWRITE
  )
  
})


test_that("save_db() fails to overwrite when db is connected", {
  
  # This only seems to work on Windows
  skip_if_not(.Platform$OS.type == "windows", "Skipping test if not Windows")
  
  db_file <- test_db_file()
  
  expect_error(
    {
      db1 <- save_db(mtcars_sch, file = db_file, path = test_db_path, 
                     as_is = TRUE)
      db1 <- DBI::dbConnect(db1)
    },
    NA
  )
  
  expect_true(
    DBI::dbIsValid(db1)
  )
  
  expect_error(
    {
      db2 <- save_db(
        mtcars_sch,
        file = db_file, 
        path = test_db_path,
        overwrite = TRUE,
        as_is = TRUE
      )
      suppressWarnings(DBI::dbDisconnect(db2))
    },
    UKBSCHEMAS_ERRORS$FAILED_OVERWRITE
  )
  
  suppressWarnings(DBI::dbDisconnect(db1))
  
})


test_that("save_db() won't allow in-memory databases", {
  
  expect_error(
    {
      db1 <- save_db(mtcars_sch, file = ":memory:", path = test_db_path, as_is = TRUE)
      suppressWarnings(DBI::dbDisconnect(db1))
    },
    UKBSCHEMAS_ERRORS$NO_IN_MEMORY
  )
  
  expect_error(
    {
      db2 <- save_db(mtcars_sch, file = "file::memory:", path = test_db_path, 
                     as_is = TRUE)
      suppressWarnings(DBI::dbDisconnect(db2))
    },
    UKBSCHEMAS_ERRORS$NO_IN_MEMORY
  )
  
})


test_that("save_db() runs without errors or warnings with genuine data", {
  
  sch <- ukbschemas(url_prefix = use_prefix)
  
  expect_error(
    db1 <- save_db(sch, file = test_db_file(), path = test_db_path),
    NA
  )
  expect_false(DBI::dbIsValid(db1))
  
  expect_warning(
    db2 <- save_db(sch, file = test_db_file(), path = test_db_path),
    NA
  )
  expect_false(DBI::dbIsValid(db2))
  
})

# Finished ---------------------------------------------------------------------


