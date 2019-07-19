
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ukbschemas

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Build
Status](https://travis-ci.com/bjcairns/ukbschemas.svg?token=tA2cYTLpigx5VuTgcHFd&branch=master)](https://travis-ci.com/bjcairns/ukbschemas)
<!-- badges: end -->

This R package can be used to create and/or load a database containing
the [UK Biobank Data Showcase
schemas](http://biobank.ctsu.ox.ac.uk/crystal/schema.cgi), which are
data dictionaries describing the structure of the UK Biobank main
dataset.

## Installation

You can install the current version of ukbschemas from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("bjcairns/ukbschemas")

library(ukbschemas)
```

## Examples

The package supports two workflows.

#### Save-Load workflow (recommended)

The recommended approach is to use `ukbschemas_db()` to download the
schema tables and save them to an SQLite database, then use `load_db()`
to load the tables from the database and store them as tibbles in a
named list:

``` r
db <- ukbschemas_db(path = tempdir())
sch <- load_db(db = db)
```

By default, the database is named `ukb-schemas-YYYY-MM-DD.sqlite` (where
`YYYY-MM-DD` is the current date) and placed in the current working
directory. (`path = tempdir()` in the above example puts it in the
current temporary directory instead.) At the most recent compilation of
the database (19 July 2019), the size of the .sqlite database file
produced by `ukbschemas_db()` was approximately 10.1MB.

Note that without further arguments, `ukbschemas_db()` tidies up the
database to give it a more consistent relational structure (the changes
are summarised in the output of the first example, above). Alternatively
the raw data can be loaded with the `as_is` argument:

``` r
db <- ukbschemas_db(path = tempdir(), overwrite = TRUE, as_is = TRUE)
```

The `overwrite` option allows the database file to be overwritten (if
`TRUE`), or prevents this (`FALSE`), or if not specified and the session
is interactive (`interactive() == TRUE`) then the user is prompted to
decide.

#### Load-Save workflow

The second approach is to download the schemas and store them in memory
in a list, and save them to a database only as requried.

This is **not** recommended, because it is better (for everyone) not to
download the schema files every time they are needed, and because the
database assumes a certain structure that should be guaranteed when the
database is saved. If you still want to take this approach, use:

``` r
sch <- ukbschemas()
db <- save_db(sch, path = tempdir())
```

## Why R?

This package was originally written in bash (a Unix shell scripting
language). However, R is more accessible and all dependencies are loaded
when you install the package; there is no need to install any secondary
software (not even SQLite).

## Notes

#### Design notes

  - All the encoding value tables (`esimpint`, `esimpstring`,
    `esimpreal`, `esimpdate`, `ehierint`, `ehierstring`) have been
    harmonised and combined into a single table `encvalues`. The `value`
    column in `encvalues` has type `TEXT`, but a `type` column has been
    added in case the value is not clear from context. The original
    type-specific tables have been deleted.
  - To avoid redunancy, category parent-child relationships have been
    moved to table `categories`, as column `parent_id`, from table
    `catbrowse` (which has been deleted).
  - Reference to the category to which a field belongs is in the
    `main_category` column in the `fields` schema, but has been renamed
    to `category_id` for consistency with the `categories` schema.
  - The value types described [on the UKB
    Showcase](http://biobank.ctsu.ox.ac.uk/crystal/help.cgi?cd=value_type)
    have been added manually to a table `valuetypes` and appropriate ID
    references have been renamed to `value_type_id` in tables `fields`
    and `encodings`.

#### Known code issues

  - The UK Biobank data schemas are regularly updated as new data are
    added to the system. ukbschemas does not currently include a
    facility for updating the database; it is necessary to create a new
    database.
  - Any [other issues](https://github.com/bjcairns/ukbschemas/issues).
