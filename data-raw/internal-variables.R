# URLs and other data for accessing the UKB Data Showcase

UKB_SCHEMA_URL <- "http://biobank.ctsu.ox.ac.uk/crystal/schema.cgi"


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

# To add missing category 119
#
# Last update: 2019-03-19
CATEGORY_EXTRA <- tibble::tribble(
  ~category_id, ~title, ~availability, ~group_type, ~descript, ~notes, ~parent_id,
  119L, "Reaction time test", 0L, 1L, "This category contains data on a test to assess reaction time and is based on 12 rounds of the card-game 'Snap'. The participant is shown two cards at a time; if both cards are the same, they press a button-box that is on the table in front of them as quickly as possible. For each of the 12 rounds, the following data were collected: the pictures shown on the cards (Index of card A, Index of card B), the number of times the participant clicked the 'snap' button, and the time it took to first click the 'snap' button. <p> This was a follow-up to touchscreen Category 100032.", NA, NA
)


# Errors
UKBSCHEMA_ERRORS <- list(
  OVERWRITE = "Will not overwrite existing file without 'overwrite=TRUE'",
  NO_IN_MEMORY = "ukbschema does not support in-memory databases",
  FAILED_OVERWRITE = paste0("Could not overwrite existing file; ",
                            "is there an existing database connection?"),
  FILE_NOT_EXISTS = "Not a valid name of an existing file",
  DB_NO_CONNECT = "Could not connect to database"
)


# Export to R/sysdata.rda
usethis::use_data(
  UKB_SCHEMA_URL, UKB_URL_PREFIX, SCHEMA_FILENAMES, VALUE_TYPES, CATEGORY_EXTRA,
  UKBSCHEMA_ERRORS,
  internal = TRUE, overwrite = TRUE
)
