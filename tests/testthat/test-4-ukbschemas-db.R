# Preliminaries ----------------------------------------------------------------

skip_if_offline(host = "biobank.ndph.ox.ac.uk")

# Tests ------------------------------------------------------------------------

# Note: closure of db connection after ukbschemas_db() is tested throughout

test_that(
  desc = "ukbschemas_db() runs without errors or warnings",
  code = {
    
    expect_error(
      object = {
        db1 <- suppressWarnings(
          ukbschemas_db(
            file = test_db_file(), 
            path = path_test_db, 
            cache = path_test_sch,
            nThread = 1L
          )
        )
      },
      regexp = NA
    ) # "Error populating database"
    
    expect_false(
      object = DBI::dbIsValid(db1)
    ) # Fails because above fails
    
    skip("Upstream problems means this throws warnings.")
    
    expect_warning(
      object = {
        db2 <- ukbschemas_db(
          file = test_db_file(), 
          path = path_test_db,
          cache = path_test_sch,
          nThread = 1L
        )
      },
      regexp = NA
    ) # "Error populating database"
    
    expect_false(
      object = DBI::dbIsValid(db2)
    ) # Fails because above fails
    
  }
)


test_that(
  desc = "ukbschemas_db() runs silently if required",
  code = {
    
    expect_silent(
      object = {
        db <- suppressWarnings(
          ukbschemas_db(
            file = test_db_file(),
            path = path_test_db,
            silent = TRUE,
            cache = path_test_sch,
            nThread = 1L
          )
        )
      }
    ) # "Error populating database"
    
    expect_false(
      object = DBI::dbIsValid(db)
    ) # Fails because above fails
    
  }
)


test_that(
  desc = "ukbschemas_db() fails on overwrite = FALSE, non-interactive",
  code = {
    
    db_file <- test_db_file()
    
    expect_error(
      object = {
        db1 <- suppressWarnings(
          ukbschemas_db(
            file = db_file, 
            path = path_test_db,
            cache = path_test_sch,
            nThread = 1L
          )
        )
      },
      regexp = NA
    ) # "Error populating database"
    
    expect_false(
      object = DBI::dbIsValid(db1)
    ) # Fails because above fails
    
    expect_error(
      object = {
        db2 <- suppressWarnings(
          ukbschemas_db(
            file = db_file, 
            path = path_test_db,
            cache = path_test_sch,
            nThread = 1L
          )
        )
        suppressWarnings(DBI::dbDisconnect(db2))
      },
      regexp = UKBSCHEMAS_ERRORS[["OVERWRITE"]]
    )
    
  }
)


test_that(
  desc = "ukbschemas_db() fails to overwrite when db is connected",
  code = {
    
    skip("Functionality removed as no longer required.")
    
    db_file <- test_db_file()
    
    expect_error(
      object = {
        db1 <- suppressWarnings(
          ukbschemas_db(
            file = db_file, 
            path = path_test_db,
            cache = path_test_sch,
            nThread = 1L
          )
        )
        db1 <- DBI::dbConnect(db1)
      },
      regexp = NA
    ) # Error populating database
    
    expect_true(
      object = DBI::dbIsValid(db1)
    ) # Fails because above fails
    
    expect_error(
      object = {
        db2 <- suppressWarnings(
          ukbschemas_db(
            file = db_file, 
            path = path_test_db,
            overwrite = TRUE,
            cache = path_test_sch,
            nThread = 1L,
          )
        )
        suppressWarnings(DBI::dbDisconnect(db2))
      },
      regexp = UKBSCHEMAS_ERRORS[["FAILED_OVERWRITE"]]
    ) # Error populating database
    
    suppressWarnings(DBI::dbDisconnect(db1))
    
  }
)


test_that(
  desc = "ukbschemas_db() won't allow in-memory databases",
  code = {
    
    expect_error(
      object = {
        db1 <- suppressWarnings(
          ukbschemas_db(
            file = ":memory:",
            path = path_test_db,
            cache = path_test_sch,
            nThread = 1L
          )
        )
        suppressWarnings(DBI::dbDisconnect(db1))
      },
      regexp = UKBSCHEMAS_ERRORS[["NO_IN_MEMORY"]]
    )
    
    expect_error(
      object = {
        db2 <- suppressWarnings(
          ukbschemas_db(
            file = "file::memory:",
            path = path_test_db,
            cache = path_test_sch,
            nThread = 1L
          )
        )
        suppressWarnings(DBI::dbDisconnect(db2))
      },
      regexp = UKBSCHEMAS_ERRORS[["NO_IN_MEMORY"]]
    )
    
  }
)
