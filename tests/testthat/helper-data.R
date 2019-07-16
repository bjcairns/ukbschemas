## Generate test data to avoid pulling database in every time a test is run

# normalizePath gives a message when the file/path does not exist
.quiet_normalizePath <- function(path) suppressWarnings(normalizePath(path))


# Function to locate local copy of downloaded files
.test_data_path <- function() {
  
  new_prefix <- ifelse(
    identical(Sys.getenv("TRAVIS"), "true"),
    "/home/travis/ukbschemas-test-data/",
    ifelse(
      identical(Sys.getenv("NOT_CRAN"), "true"),
      paste0("../../tests/test-data/"),
      paste0(here::here(), "/tests/test-data/")
    )
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
SCHEMA_FILENAMES$id %>%
  purrr::walk(
    ~ if (!file.exists(paste0(new_prefix, .))) {
      curl::curl_download(
        url = paste0(UKB_URL_PREFIX, .),
        destfile = paste0(new_prefix, .)
      )
    }
  )
