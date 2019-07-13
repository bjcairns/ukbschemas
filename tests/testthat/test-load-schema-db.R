context("test-load-schema-db")

# Preliminaries ----------------------------------------------------------------

test_db_file <- tempfile(fileext = ".sqlite")
db <- DBI::dbConnect(
  RSQLite::SQLite(), 
  test_db_file
)
DBI::dbWriteTable(db, "mtcars", mtcars)
DBI::dbDisconnect(db)


# Tests ------------------------------------------------------------------------

test_that("load_schema_db() opens from file", {
  sch <- load_schema_db(test_db_file)
  expect_equal(sch[[1]], mtcars)
  expect_error(load_schema_db(tempfile(fileext = ".sqlite")))
})


test_that("load_schema_db() opens from connected database connection", {
  db <- suppressWarnings(DBI::dbConnect(db))
  sch <- load_schema_db(db = db)
  expect_equal(sch[[1]], mtcars)
})


test_that("load_schema_db() opens from DISconnected database connection", {
  suppressWarnings(DBI::dbDisconnect(db))
  sch <- load_schema_db(db = db)
  expect_equal(sch[[1]], mtcars)
})


# Finished ---------------------------------------------------------------------

suppressWarnings(DBI::dbDisconnect(db))
rm(list="db")
file.remove(test_db_file)
