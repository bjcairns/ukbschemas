# Value types from 
#   http://biobank.ctsu.ox.ac.uk/crystal/help.cgi?cd=value_type
# Note that the IDs for "Binary object" and "Records" have been set arbitrarily.
# The value_type_id 0 has been added for consistency with the coded_as column 
# of `encodings`.
#
# Last update: 2020-12-17
VALUE_TYPES <- data.frame(
  value_type_id = c(
    0L, 11L, 21L, 22L, 31L, 41L, 51L, 61L, 101L, 998L, 999L
  ),
  title = c(
    NA, "Integer", "Categorical (single)", "Categorical (multiple)", "Continuous", "Text", "Date", "Time", "Compound", "Binary object", "Records"
  ),
  description = c(
    NA,
    "whole numbers, for example the age of a participant on a particular date",
    "a single answer selected from a coded list or tree of mutually exclusive options, for example a yes/no choice",
    "sets of answers selected from a coded list or tree of options, for instance concurrent medications",
    "floating-point numbers, for example the height of a participant",
    "data composed of alphanumeric characters, for example the first line of an address",
    "a calendar date, for example 14th October 2010",
    "a time, for example 13:38:05 on 14th October 2010",
    "a set of values required as a whole to describe some compound property, for example an ECG trace",
    "a complex dataset (blob), for example an image",
    "a summary showing the volume of records data available via the secure portal"
  )
)

# Stability from
#   https://biobank.ctsu.ox.ac.uk/crystal/help.cgi?cd=stability
# Note that the ID for "Obsolete" has been set arbitrarily.
#
# Last update: 2020-12-17
STABILITY <- data.frame(
  stability_id = 0:4,
  title = c("Complete", "Updateable", "Accruing", "Ongoing", "Obsolete"),
  desciption = c(
    "all data has been collected and will never change, an example would be the date at which a participant joined UK Biobank",
    "all data has been collected, but the values may change over time, an example would be the volume of the initial blood samples collected by UKB which will decrease as new analyses are performed using them",
    "data is still being gathered",
    "data is still being gathered and the values already held may change over time",
    "data which has been superceded by other fields and is not recommended for use"
  )
)

# Item types from
#   https://biobank.ctsu.ox.ac.uk/crystal/help.cgi?cd=item_type
#
# Last update: 2020-12-17
ITEM_TYPES <- data.frame(
  item_type_id = c(0L, 10L, 20L, 30L),
  title = c("Data", "Samples", "Bulk", "Records"),
  description = c(
    "data values, of elementary types or with simple structures",
    "inventory information corresponding to biological samples held by UK Biobank",
    "large complex objects, typically binary files (blobs) which cannot be decomposed into smaller chunks",
    "inventory information describing the number of (records) held"
  )
)

# Strata from
#   https://biobank.ctsu.ox.ac.uk/crystal/help.cgi?cd=strata
#
# Last update: 2020-12-17
STRATA <- data.frame(
  strata_id = 0:3,
  title = c("Primary", "Supporting", "Auxillary", "Derived"),
  description = c(
    "the key clinically/scientifically relevant data-fields",
    "data which is clinical/scientific in nature, but largely superceded by a Primary data-field",
    "data which describes the systems or processes used to acquire the data",
    "data which has been constructed by combining/processing values from one or more other data-fields"
  )
)

# Sexed from
#   https://biobank.ctsu.ox.ac.uk/crystal/help.cgi?cd=sexed
#   
# Last update: 2020-12-17
SEXED <- data.frame(
  sexed_id = 0:2,
  title = c("Both sexes", "Males only", "Females only"),
  description = c(
    "for example height",
    "for example prostate cancer history",
    "for example age at menopause"
  )
)
