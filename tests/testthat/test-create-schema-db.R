context("test-create-schema-db")

# Preliminaries ----------------------------------------------------------------

skip_if_not(curl::has_internet(), "Skipping tests; no internet")

test_db_file <- function() basename(tempfile(fileext = ".sqlite"))
test_db_path <- tempdir()


# Tests ------------------------------------------------------------------------

test_that("create_schema_db() runs without errors or warnings", {
  
  expect_error(
    db1 <- create_schema_db(file = test_db_file(), path = test_db_path),
    NA
  )
  expect_false(DBI::dbIsValid(db1))
  
  expect_warning(
    db2 <- create_schema_db(file = test_db_file(), path = test_db_path),
    NA
  )
  expect_false(DBI::dbIsValid(db2))
  
})

test_that("create_schema_db() runs silently if required", {
  expect_silent(
    db <- create_schema_db(
      file = test_db_file(),
      path = test_db_path,
      silent = TRUE
    )
  )
  expect_false(DBI::dbIsValid(db))
})

test_that("create_schema_db() fails on overwrite = FALSE, non-interactive", {
  
  db_file <- test_db_file()
  
  expect_error(
    db1 <- create_schema_db(file = db_file, path = test_db_path),
    NA
  )
  
  expect_false(DBI::dbIsValid(db1))
  
  expect_error(
    {
      db2 <- create_schema_db(file = db_file, path = test_db_path)
      suppressWarnings(DBI::dbDisconnect(db2))
    },
    UKBSCHEMA_ERRORS$OVERWRITE
  )
  
})

test_that("create_schema_db() fails to overwrite when db is connected", {
  
  # This only seems to work on Windows
  skip_if_not(.Platform$OS.type == "windows", "Skipping test if not Windows")
  
  db_file <- test_db_file()
  
  expect_error(
    {
      db1 <- create_schema_db(file = db_file, path = test_db_path)
      db1 <- DBI::dbConnect(db1)
    },
    NA
  )
  
  expect_true(
    DBI::dbIsValid(db1)
  )
  
  expect_error(
    {
      db2 <- create_schema_db(
        file = db_file, 
        path = test_db_path,
        overwrite = TRUE
      )
      suppressWarnings(DBI::dbDisconnect(db2))
    },
    UKBSCHEMA_ERRORS$FAILED_OVERWRITE
  )
  
  suppressWarnings(DBI::dbDisconnect(db1))
  
})

test_that("create_schema_db() won't allow in-memory databases", {
  
  expect_error(
    {
      db1 <- create_schema_db(file = ":memory:", path = test_db_path)
      suppressWarnings(DBI::dbDisconnect(db1))
    },
    UKBSCHEMA_ERRORS$NO_IN_MEMORY
  )
  
  expect_error(
    {
      db2 <- create_schema_db(file = "file::memory:", path = test_db_path)
      suppressWarnings(DBI::dbDisconnect(db2))
    },
    UKBSCHEMA_ERRORS$NO_IN_MEMORY
  )
  
})
