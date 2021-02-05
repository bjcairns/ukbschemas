# Preliminaries ----------------------------------------------------------------

skip_if_offline(host = "biobank.ndph.ox.ac.uk")

# Tests ------------------------------------------------------------------------

test_that(
  desc = "ukbschemas() runs without errors or warnings",
  code = {
    
    expect_error(
      sch <- suppressWarnings(
        ukbschemas(
          sch_path = path_test_sch,
          nThread = 1L
        )
      ),
      NA
    )
    
    skip("ukbschemas returns warnings")
    expect_warning(
      sch <- ukbschemas(
        sch_path = path_test_sch,
        nThread = 1L
      ),
      NA
    )
    
  }
)

test_that(
  desc = "ukbschemas() runs with as_is = TRUE without errors or warnings",
  code = {
    
    expect_error(
      sch <- suppressWarnings(
        ukbschemas(
          sch_path = path_test_sch,
          as_is = TRUE,
          nThread = 1L,
          silent = TRUE
        )
      ),
      NA
    )
    
    skip("ukbschemas returns warnings")
    expect_warning(
      sch <- ukbschemas(
        sch_path = path_test_sch,
        as_is = TRUE,
        nThread = 1L,
        silent = TRUE
      ),
      NA
    )
  
  }
)

test_that(
  desc = "ukbschemas() runs silently if required",
  code = {
    
    skip("ukbschemas returns warnings")
    expect_silent(
      object = {
        sch <- ukbschemas(
          sch_path = path_test_sch,
          nThread = 1L,
          silent = TRUE
        )
      }
    )
    
    # There seems to be no way to force readr to show a progress bar when 
    # reading small files or over fast connections (estimated read time <5
    # seconds), but if there was, this is where a further test would go to 
    # ensure progress bars are always suppressed when silent = TRUE.
  
  }
)

test_that(
  desc = "ukbschemas() returns schemas in the right order",
  code = {
    
    skip("Test may be outdated.")
    
    db <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
    .create_tables(db)
    dummy_sch <- load_db(db = db)
    
    expect_error(
      object = {
        sch <- ukbschemas(
          sch_path = path_test_sch,
          nThread = 1L
        )
      }
    )
    
    # Schemas in the right order
    expect_identical(
      object = names(dummy_sch),
      expected = names(sch)
    )
    
    # Columns of each in the right order
    purrr::walk(
      .x = names(sch),
      .f = ~ expect_equal(names(sch[[.x]]), names(dummy_sch[[.x]]))
    )
    
    .quiet_dbDisconnect(db)
  
  }
)
