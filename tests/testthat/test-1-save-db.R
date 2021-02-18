# Tests ------------------------------------------------------------------------

# Note: closure of db connection after save_db() is tested throughout

test_that(
  desc = "save_db() runs without errors or warnings on mtcars",
  code = {
    
    expect_error(
      db <- save_db(
        sch = mtcars_sch, 
        file = test_db_file(), 
        path = path_test_db, 
        as_is = TRUE
      ),
      NA
    )
    
    expect_false(DBI::dbIsValid(db))
  
  }
)


test_that(
  desc = "save_db() runs silently if required",
  code = {
    
    expect_silent(
      db <- save_db(
        sch = mtcars_sch,
        file = test_db_file(),
        path = path_test_db,
        silent = TRUE,
        as_is = TRUE
      )
    )
    
    expect_false(DBI::dbIsValid(db))
    
  }
)


test_that(
  desc = "save_db() fails on overwrite = FALSE, non-interactive",
  code = {
    
    db_file <- test_db_file()
    
    expect_error(
      db1 <- save_db(
        sch = mtcars_sch,
        file = db_file,
        path = path_test_db,
        as_is = TRUE
      ),
      NA
    )
    
    expect_false(DBI::dbIsValid(db1))
    
    expect_error(
      {
        db2 <- save_db(
          sch = mtcars_sch,
          file = db_file,
          path = path_test_db,
          as_is = TRUE
        )
        suppressWarnings(DBI::dbDisconnect(db2))
      },
      UKBSCHEMAS_ERRORS[["OVERWRITE"]]
    )
    
  }
)


test_that(
  desc = "save_db() fails to overwrite when db is connected",
  code = {
    
    db_file <- test_db_file()
    
    expect_error(
      {
        db1 <- save_db(
          sch = mtcars_sch,
          file = db_file,
          path = path_test_db,
          as_is = TRUE
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
        db2 <- save_db(
          sch = mtcars_sch,
          file = db_file, 
          path = path_test_db,
          overwrite = TRUE,
          as_is = TRUE
        )
        suppressWarnings(DBI::dbDisconnect(db2))
      },
      UKBSCHEMAS_ERRORS[["FAILED_OVERWRITE"]]
    )
    
    suppressWarnings(DBI::dbDisconnect(db1))
    
  }
)


test_that(
  desc = "save_db() won't allow in-memory databases",
  code = {
    
    expect_error(
      {
        db1 <- save_db(
          sch = mtcars_sch,
          file = ":memory:",
          path = path_test_db,
          as_is = TRUE
        )
        suppressWarnings(DBI::dbDisconnect(db1))
      },
      UKBSCHEMAS_ERRORS[["NO_IN_MEMORY"]]
    )
    
    expect_error(
      {
        db2 <- save_db(
          sch = mtcars_sch,
          file = "file::memory:",
          path = path_test_db,
          as_is = TRUE
        )
        suppressWarnings(DBI::dbDisconnect(db2))
      },
      UKBSCHEMAS_ERRORS[["NO_IN_MEMORY"]]
    )
    
  }
)


test_that(
  desc = "save_db() runs without errors or warnings with genuine data",
  code = {
    
    sch <- suppressWarnings(
      ukbschemas(
        cache = path_test_sch,
        nThread = 1L
      )
    )    
    
    expect_error(
      object = {
        db1 <- save_db(
          sch = sch,
          file = test_db_file(),
          path = path_test_db
        )
      },
      regexp = NA
    )
    
    expect_false(DBI::dbIsValid(db1))
    
    expect_warning(
      object = {
        db2 <- save_db(
          sch = sch,
          file = test_db_file(),
          path = path_test_db
        )
      },
      regexp = NA
    )
  
    expect_false(DBI::dbIsValid(db2))
    
  }
)

# Finished ---------------------------------------------------------------------


