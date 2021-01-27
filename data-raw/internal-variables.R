# URLs and other data for accessing the UKB Data Showcase

UKB_SCHEMAS_URL <- "https://biobank.ctsu.ox.ac.uk/crystal/schema.cgi"
UKB_URL_PREFIX <- "https://biobank.ndph.ox.ac.uk/showcase/scdown.cgi?fmt=txt&id="


# Filenames acquired via UKB_SCHEMA_URL
#
# Last update: 2019-03-15
filenames <- c(
  "fields" = 1L, # Data field properties.
  "encodings" = 2L, # Encoding dictionaries.
  "categories" = 3L, # Categories used to group data fields and other objects on Showcase interface.
  "returns" = 4L, # Returned datasets from Applications. # MALFORMED - parsing failure!
  "esimpint" = 5L, # Values for simple integer encodings.
  "esimpstring" = 6L, # Values for simple string encodings.
  "esimpreal" = 7L, # Values for simple real (floating-point) encodings.
  "esimpdate" = 8L, # Values for simple date encodings.
  "instances" = 9L, # Instancing dictionaries.
  "insvalues" = 10L, # Values for instances.
  "ehierint" = 11L, # Values for hierarchical integer encodings.
  "ehierstring" = 12L, # Values for hierarchical string encodings
  "catbrowse" = 13L, # Category browse tree structure.
  "recommended" = 14L, # Data field recommendations.
  "snps" = 15L, # Genotyped SNPs.
  "fieldsum" = 16L, # Data field summary.
  "recordtab" = 17L, # Record tables available via data portal.
  "recordcol" = 18L, # Columns of data in Record tables.
  "schema" = 999L # Schema provided for the UK Biobank Showcase system.
)
SCHEMA_FILENAMES <- data.frame(
  id = as.vector(filenames),
  filename = names(filenames)
); rm(filenames)


# Errors
UKBSCHEMAS_ERRORS <- list(
  OVERWRITE = "Will not overwrite existing file without 'overwrite=TRUE'",
  NO_IN_MEMORY = "ukbschema does not support in-memory databases",
  FAILED_OVERWRITE = paste0("Could not overwrite existing file; ",
                            "is there an existing database connection?"),
  FILE_NOT_EXISTS = "Not a valid name of an existing file",
  SCH_READ_ERROR = "Could not read schema (malformed rows in file?)",
  DB_NO_CONNECT = "Could not connect to database",
  DB_POPULATE_ERROR = "Error populating database",
  WARN_DB_CONNECTED = "Database object is already connected",
  WARN_SCH_DOWNLOAD = "One or more schemas could not be downloaded",
  WARN_FREAD_FAIL = "data.table::fread failed, falling back to readr::read_delim",
  WARN_FREAD_STOP_EARLY = "data.table::fread stopped early, falling back to readr::read_delim"
)

# Additional tables to add to the schemas
source("data-raw/aux-tables.R")


# Export to R/sysdata.rda
save(
  VALUE_TYPES, STABILITY, ITEM_TYPES, STRATA, SEXED,
  UKB_SCHEMAS_URL, UKB_URL_PREFIX, SCHEMA_FILENAMES, UKBSCHEMAS_ERRORS,
  file = file.path("R", "sysdata.rda"),
  version = 2,
  compress = "gzip"
)

# Tidy up
rm(VALUE_TYPES, STABILITY, ITEM_TYPES, STRATA, SEXED,
   UKB_SCHEMAS_URL, UKB_URL_PREFIX, SCHEMA_FILENAMES, UKBSCHEMAS_ERRORS)
