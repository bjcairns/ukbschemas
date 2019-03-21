context("test-load-schemas")

# Preliminaries ----------------------------------------------------------------

test_db_file <- tempfile(fileext = ".sqlite")
db <- DBI::dbConnect(
  RSQLite::SQLite(), 
  test_db_file
)
DBI::dbWriteTable(db, "mtcars", mtcars)
DBI::dbDisconnect(db)


# Tests ------------------------------------------------------------------------

test_that("load_schemas() opens from file", {
  sch <- load_schemas(test_db_file)
  expect_equal(sch[[1]], mtcars)
  expect_error(load_schemas(tempfile(fileext = ".sqlite")))
})


test_that("load_schemas() opens from connected database connection", {
  db <- suppressWarnings(DBI::dbConnect(db))
  sch <- load_schemas(db = db)
  expect_equal(sch[[1]], mtcars)
})


test_that("load_schemas() opens from DISconnected database connection", {
  suppressWarnings(DBI::dbDisconnect(db))
  sch <- load_schemas(db = db)
  expect_equal(sch[[1]], mtcars)
})


# Finished ---------------------------------------------------------------------

suppressWarnings(DBI::dbDisconnect(db))
rm(list="db")
file.remove(test_db_file)
