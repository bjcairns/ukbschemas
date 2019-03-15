# URLs and other data for accessing the UKB Data Showcase

UKB_SCHEMA_URL <- "http://biobank.ctsu.ox.ac.uk/crystal/schema.cgi"

UKB_URL_PREFIX <- "http://biobank.ndph.ox.ac.uk/showcase/scdown.cgi?fmt=txt&id="

filenames <- c(
  "fields",
  "encodings",
  "categories",
  "archives",
  "esimpint",
  "esimpstring",
  "esimpreal",
  "esimpdate",
  "instances",
  "insvalues",
  "ehierint",
  "ehierstring",
  "catbrowse",
  "recommended",
  "schema"
)
ids <- c(1:14, 999)
SCHEMA_FILENAMES <- tibble::tibble(id = ids, filename = filenames)

# Export to R/sysdata.rda
usethis::use_data(
  UKB_SCHEMA_URL, UKB_URL_PREFIX, SCHEMA_FILENAMES, 
  internal = TRUE
)