# Preliminaries ----------------------------------------------------------------

tmp_db_file <- test_db_file()

db <- DBI::dbConnect(
  RSQLite::SQLite(), 
  tmp_db_file
)
DBI::dbWriteTable(db, "mtcars", dat_mtcars)
DBI::dbDisconnect(db)

# Tests ------------------------------------------------------------------------

test_that(
  desc = "load_db() opens from file",
  code = {
    
    sch <- load_db(tmp_db_file)
    expect_equal(sch[[1]], dat_mtcars)
    expect_error(load_db(tempfile(tmpdir = path_test_db, fileext = ".sqlite")))
    
  }
)


test_that(
  desc = "load_db() opens from connected database connection",
  code = {
    
    db <- suppressWarnings(DBI::dbConnect(db))
    expect_warning(
      sch <- load_db(db = db),
      NA
    )
    expect_equal(sch[[1]], dat_mtcars)
    
  }
)


test_that(
  desc = "load_db() opens from DISconnected database connection",
  code = {
    
    suppressWarnings(DBI::dbDisconnect(db))
    sch <- load_db(db = db)
    expect_equal(sch[[1]], dat_mtcars)
    
  }
)


# Finished ---------------------------------------------------------------------

suppressWarnings(DBI::dbDisconnect(db))
rm(list = "db")
file.remove(tmp_db_file)
rm(tmp_db_file)
