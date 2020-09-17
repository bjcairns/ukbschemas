## Generate test data to avoid pulling database in every time a test is run

# normalizePath gives a message when the file/path does not exist
.quiet_normalizePath <- function(path) suppressWarnings(normalizePath(path))


# Function to locate local copy of downloaded files
.test_data_path <- function() {
  
  test_data_dir <- "ukbschemas-test-data/"
  
  new_prefix <- ifelse(
    identical(Sys.getenv("TRAVIS"), "true"),
    paste0(Sys.getenv("HOME"), "/", test_data_dir),
    paste0("~/", test_data_dir)
  )
  
  suppressWarnings(.quiet_normalizePath(new_prefix))
  
}


# Now set up the data
cat("Setting up test data\n")

# Adapt to Travis-CI
new_prefix <- .test_data_path()

# Create the directory to hold the schema files if necessary
if (!dir.exists(new_prefix)) dir.create(new_prefix)

# Get the files
seq(1, nrow(SCHEMA_FILENAMES)) %>%
  purrr::walk(
    ~ if (!file.exists(paste0(new_prefix, SCHEMA_FILENAMES$id[.]))) {
      readr::write_delim(
        test_schemas[[SCHEMA_FILENAMES$filename[.]]], 
        paste0(new_prefix, SCHEMA_FILENAMES$id[.]),
        delim = "\t"
      )
    }
  )
