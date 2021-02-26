# Preliminaries ----------------------------------------------------------------
  
skip_if_offline(host = "biobank.ndph.ox.ac.uk")

# Tests ------------------------------------------------------------------------

# Testing of this function is limited to checking that it runs; ideally the UKB
# schemas will be updated to make most of it obsolete

### .tidy_schemas() works with default args ###
test_that(
  desc = ".tidy_schemas() works with default args",
  code = {
    
    ## Test Setup ##
    .get_schemas(nThread = 1L)
    sch <- suppressWarnings(.import_schemas(nThread = 1L))
    
    ## Test ##
    expect_error(
      object = {
        sch <- .tidy_schemas(silent = TRUE)
      }
    )
    
    ## Tidy Up ##
    rm(sch)
    
  }
)
