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


# Value types from 
#   http://biobank.ctsu.ox.ac.uk/crystal/help.cgi?cd=value_type
# Note that the IDs for "Binary object" and "Records" have been set arbitrarily.
# The value_type_id 0 has been added for consistency with the coded_as column 
# of `encodings`.
#
# Last update: 2019-03-16
VALUE_TYPES <- tibble::tribble(
  ~value_type_id, ~title, ~description,
  0L, "", "",
  11L, "Integer", "whole numbers, for example the age of a participant on a particular date",
  21L, "Categorical (single)", "a single answer selected from a coded list or tree of mutually exclusive options, for example a yes/no choice",
  22L, "Categorical (multiple)", "sets of answers selected from a coded list or tree of options, for instance concurrent medications",
  31L, "Continuous", "floating-point numbers, for example the height of a participant",
  41L, "Text", "data composed of alphanumeric characters, for example the first line of an address",
  51L, "Date", "a calendar date, for example 14th October 2010",
  61L, "Time", "a time, for example 13:38:05 on 14th October 2010",
  101L, "Compound", "a set of values required as a whole to describe some compound property, for example an ECG trace",
  998L, "Binary object", "a complex dataset (blob), for example an image",
  999L, "Records", "a summary showing the volume of records data available via the secure portal"
)


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


# Export to R/sysdata.rda
usethis::use_data(
  UKB_SCHEMAS_URL, UKB_URL_PREFIX, SCHEMA_FILENAMES, VALUE_TYPES, 
  UKBSCHEMAS_ERRORS,
  internal = TRUE, overwrite = TRUE
)
