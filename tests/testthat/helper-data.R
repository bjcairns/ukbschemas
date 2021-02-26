## Generate test data to avoid pulling database in every time a test is run


# Function to locate local copy of downloaded files
### .test_data_path() ###
.test_data_path <- function(test_data_dir = "test-data") {
  
  ## Conditional Test Path Prefix ##
  new_prefix <- if (identical(Sys.getenv("TRAVIS"), "true")) {
    
    file.path(Sys.getenv("HOME"), test_data_dir)
    
  } else {
    
    file.path(Sys.getenv("HOME"), "ukbschemas", test_data_dir)
    
  }
  
  ## Normalise Path ##
  new_prefix <- normalizePath(new_prefix, mustWork = FALSE)
  
  ## Output ##
  return(new_prefix)
  
}


### Test Data Set ###
dat_mtcars <- mtcars
rownames(dat_mtcars) <- seq.int(nrow(dat_mtcars))
mtcars_sch <- list(mtcars = dat_mtcars)


### Set Test Data Directory Prefix ###
use_prefix <- .test_data_path()
path_test_sch <- file.path(use_prefix, "schemas")
path_test_db <- file.path(use_prefix, "db") # test_db_path <- file.path(use_prefix, "db")

# Create the directory to hold the schema files if necessary
if (!dir.exists(use_prefix)){
  
  message("Setting up test data...")
  
  ## Create Test Directories ##
  dir.create(path = use_prefix, showWarnings = FALSE, recursive = TRUE)
  dir.create(path = path_test_sch, showWarnings = FALSE, recursive = TRUE)
  dir.create(path = path_test_db, showWarnings = FALSE, recursive = TRUE)
  
  ## Download the Schemas ##
  rc <- mapply(
    FUN = function(url, destfile){
      if (!file.exists(file.path(destfile))) {
        utils::download.file(
          url = url,
          destfile = destfile,
          method = if (capabilities("libcurl")) "libcurl" else "auto",
          quiet = TRUE,
          mode = "w",
          cacheOK = FALSE
        )
      } else {
        0L
      }
    },
    url = paste0(UKB_URL_PREFIX, SCHEMA_FILENAMES[["id"]]),
    destfile = file.path(path_test_sch, paste(SCHEMA_FILENAMES[["filename"]], "tsv", sep = "."))
  )
  
  if (!all(rc == 0L))
    warning(UKBSCHEMAS_ERRORS[["WARN_SCH_DOWNLOAD"]])
  rm(rc)
  
}

### Test DB File Function ###
test_db_file <- function() basename(tempfile(tmpdir = path_test_db, fileext = ".sqlite"))
