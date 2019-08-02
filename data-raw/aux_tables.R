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

# Stability from
#   https://biobank.ctsu.ox.ac.uk/crystal/help.cgi?cd=stability
# Note that the ID for "Obsolete" has been set arbitrarily.
#
# Last update: 2019-08-02
STABILITY <- tibble::tribble(
  ~stability_id, ~title, ~description,
  0L, "Complete", "all data has been collected and will never change, an example would be the date at which a participant joined UK Biobank",
  1L, "Updateable", "all data has been collected, but the values may change over time, an example would be the volume of the initial blood samples collected by UKB which will decrease as new analyses are performed using them",
  2L, "Accruing", "data is still being gathered",
  3L, "Ongoing", "data is still being gathered and the values already held may change over time",
  4L, "Obsolete", "data which has been superceded by other fields and is not recommended for use"
)

# Item types from
#   https://biobank.ctsu.ox.ac.uk/crystal/help.cgi?cd=item_type
#
# Last update: 2019-08-02
ITEM_TYPES <- tibble::tribble(
  ~item_type_id, ~title, ~description,
  0L, "Data", "data values, of elementary types or with simple structures",
  10L, "Samples", "inventory information corresponding to biological samples held by UK Biobank",
  20L, "Bulk", "large complex objects, typically binary files (blobs) which cannot be decomposed into smaller chunks",
  30L, "Records", "inventory information describing the number of (records) held"
)

# Strata from
#   https://biobank.ctsu.ox.ac.uk/crystal/help.cgi?cd=strata
#
# Last update: 2019-08-02
STRATA <- tibble::tribble(
  ~strata_id, ~title, ~description,
  0L, "Primary", "the key clinically/scientifically relevant data-fields",
  3L, "Derived", "data which has been constructed by combining/processing values from one or more other data-fields",
  1L, "Supporting", "data which is clinical/scientific in nature, but largely superceded by a Primary data-field",
  2L, "Auxiliary", "data which describes the systems or processes used to acquire the data"
)

# Sexed from
#   
# Last update: 2019-08-02
SEXED <- tibble::tribble(
  ~sexed_id, ~title, ~description,
  0L, "Unisex", "for example height",
  1L, "Males only", "for example prostate cancer history",
  2L, "Females only", "for example age at menopause"
)
