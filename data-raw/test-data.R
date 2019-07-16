# Generate test data to avoid pulling database in every time a test is run

.quiet_normalizePath <- function(path) suppressWarnings(normalizePath(path))

if (!dir.exists(.quiet_normalizePath("./tests"))) dir.create("./tests")
if (!dir.exists(.quiet_normalizePath("./tests/test-data"))) dir.create("./tests/test-data")

SCHEMA_FILENAMES$filename %>%
  purrr::walk(
    ~ curl::curl_download(
      url = paste0(UKB_URL_PREFIX, .),
      destfile = .quiet_normalizePath(paste0("./tests/test-data/", .))
    )
  )
