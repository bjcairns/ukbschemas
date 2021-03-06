# URLs and other data for accessing the UKB Data Showcase

UKB_SCHEMAS_URL <- "http://biobank.ctsu.ox.ac.uk/crystal/schema.cgi"


UKB_URL_PREFIX <- "http://biobank.ndph.ox.ac.uk/showcase/scdown.cgi?fmt=txt&id="


# Filenames acquired via UKB_SCHEMA_URL
#
# Last update: 2019-03-15
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
ids <- as.integer(c(1:14, 999))
SCHEMA_FILENAMES <- tibble::tibble(id = ids, filename = filenames)


# Errors
UKBSCHEMAS_ERRORS <- list(
  OVERWRITE = "Will not overwrite existing file without 'overwrite=TRUE'",
  NO_IN_MEMORY = "ukbschema does not support in-memory databases",
  FAILED_OVERWRITE = paste0("Could not overwrite existing file; ",
                            "is there an existing database connection?"),
  FILE_NOT_EXISTS = "Not a valid name of an existing file",
  DB_NO_CONNECT = "Could not connect to database",
  DB_POPULATE_ERROR = "Error populating database",
  WARN_DB_CONNECTED = "Database object is already connected"
)

# Additional tables to add to the schemas
source("data-raw/aux_tables.R")


# Export to R/sysdata.rda
usethis::use_data(
  VALUE_TYPES, STABILITY, ITEM_TYPES, STRATA, SEXED,
  UKB_SCHEMAS_URL, UKB_URL_PREFIX, SCHEMA_FILENAMES, UKBSCHEMAS_ERRORS,
  internal = TRUE, overwrite = TRUE
)
