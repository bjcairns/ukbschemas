context("test-load-db")

# Preliminaries ----------------------------------------------------------------

OLD_UKB_URL_PREFIX <- getFromNamespace("UKB_URL_PREFIX", "ukbschemas")
assignInNamespace(
  "UKB_URL_PREFIX", 
  suppressWarnings(normalizePath("../test-data/")), 
  "ukbschemas"
  )
on.exit(
  assignInNamespace(
    "UKB_URL_PREFIX", 
    OLD_UKB_URL_PREFIX, 
    "ukbschemas"
  )
)

test_db_file <- tempfile(fileext = ".sqlite")
db <- DBI::dbConnect(
  RSQLite::SQLite(), 
  test_db_file
)
DBI::dbWriteTable(db, "mtcars", mtcars)
DBI::dbDisconnect(db)

mtcars_tbl <- tibble::as_tibble(mtcars)


# Tests ------------------------------------------------------------------------

test_that("load_db() opens from file", {
  sch <- load_db(test_db_file)
  expect_equal(sch[[1]], mtcars_tbl)
  expect_error(load_db(tempfile(fileext = ".sqlite")))
})


test_that("load_db() opens from connected database connection", {
  db <- suppressWarnings(DBI::dbConnect(db))
  expect_warning(
    sch <- load_db(db = db),
    NA
  )
  expect_equal(sch[[1]], mtcars_tbl)
})


test_that("load_db() opens from DISconnected database connection", {
  suppressWarnings(DBI::dbDisconnect(db))
  sch <- load_db(db = db)
  expect_equal(sch[[1]], mtcars_tbl)
})


# Finished ---------------------------------------------------------------------

suppressWarnings(DBI::dbDisconnect(db))
rm(list="db")
file.remove(test_db_file)
