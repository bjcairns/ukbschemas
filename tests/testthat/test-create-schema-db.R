context("test-create-schema-db")

# Preliminaries ----------------------------------------------------------------

skip_if_not(curl::has_internet(), "Skipping tests; no internet")

test_db_file <- basename(tempfile(fileext = ".sqlite"))
test_db_path <- tempdir()


# Tests ------------------------------------------------------------------------

test_that("create_schema_db() runs without errors or warnings", {
  expect_error(
    db1 <- create_schema_db(file = test_db_file, path = test_db_path),
    NA
  )
  tryCatch(file.remove(paste0(test_db_path, "\\", test_db_file)))
  expect_warning(
    db2 <- create_schema_db(file = test_db_file, path = test_db_path),
    NA
  )
  tryCatch(file.remove(paste0(test_db_path, "\\", test_db_file)))
})

test_that("create_schema_db() runs silently if required", {
  expect_silent(
    db <- create_schema_db(
      file = test_db_file,
      path = test_db_path,
      silent = TRUE
    )
  )
  tryCatch(file.remove(paste0(test_db_path, "\\", test_db_file)))
})

test_that("create_schema_db() fails on overwrite = FALSE, non-interactive", {
  db1 <- create_schema_db(file = test_db_file, path = test_db_path)
  expect_error(
    db2 <- create_schema_db(file = test_db_file, path = test_db_path),
    UKBSCHEMA_ERRORS$OVERWRITE
  )
  tryCatch(file.remove(paste0(test_db_path, "\\", test_db_file)))
})

test_that("create_schema_db() fails to overwrite when db is connected", {
  db1 <- create_schema_db(file = test_db_file, path = test_db_path)
  db1 <- DBI::dbConnect(db1)
  expect_error(
    db2 <- create_schema_db(
      file = test_db_file, 
      path = test_db_path,
      overwrite = TRUE
    ),
    UKBSCHEMA_ERRORS$FAILED_OVERWRITE
  )
  DBI::dbDisconnect(db1)
  tryCatch(file.remove(paste0(test_db_path, "\\", test_db_file)))
})

test_that("create_schema_db() won't allow in-memory databases", {
  expect_error(
    db1 <- create_schema_db(file = ":memory:", path = test_db_path),
    UKBSCHEMA_ERRORS$NO_IN_MEMORY
  )
  expect_error(
    db2 <- create_schema_db(file = "file::memory:", path = test_db_path),
    UKBSCHEMA_ERRORS$NO_IN_MEMORY
  )
})
