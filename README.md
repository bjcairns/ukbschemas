
<!-- README.md is generated from README.Rmd. Please edit that file -->
ukbschema
=========

<!-- badges: start -->
<!-- badges: end -->
This R package can be used to create and/or load the [UK Biobank Data Showcase schemas](http://biobank.ctsu.ox.ac.uk/crystal/schema.cgi) for further use.

Installation
------------

You can install the current version of ukbschema from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("bjcairns/ukbschema")
```

Examples
--------

The package exports two functions. The first is `create_schema_db()`, which downloads the schema tables and saves them to an SQLite database:

``` r
library(ukbschema)

db <- create_schema_db(path = tempdir())
#> Downloaded tables:
#> fields, encodings, categories, archives, esimpint, esimpstring, esimpreal, esimpdate, instances, insvalues, ehierint, ehierstring, catbrowse, recommended, schema
#> 
#> Tidying:
#> ... Added table `value_types`
#> ... Rename to value_type_id in tables `fields` and `encodings` 
#> ... Add missing category 119 (Reaction time test)
#> ... Add parent_id from `catbrowse` to `categories` (delete former)
#> ... Harmonise `esimp*` and `ehier*` tables to add to `encvalues`
#> 
#> <SQLiteConnection>
#>   Path: C:\Users\ben\AppData\Local\Temp\RtmpMTpxEh\ukb-schema-2019-03-20.sqlite
#>   Extensions: TRUE
#> ...DISCONNECTED
```

By default, the database is named `ukb-schema-YYYY-MM-DD.sqlite` and placed in the current working directory (`path = tempdir()` in the above example puts it in the current temporary directory instead). At time of writing (20 March 2019), the size of the .sqlite database file produced by `create_schema_db()` is approximately 7.9M.

The second function, `load_schemas()`, loads the tables from the database and stores them as tibbles in a named list:

``` r
sch <- load_schemas(db)
names(sch)
#>  [1] "archives"    "categories"  "encodings"   "encvalues"   "fields"     
#>  [6] "instances"   "insvalues"   "recommended" "schema"      "valuetypes"
```

Note that without further arguments, `create_schema_db()` tidies up the database to give it a more consistent relational structure (the changes are summarised in the output of the first example, above). Alternatively the raw data can be loaded with the `as_is` argument:

``` r
db <- create_schema_db(path = tempdir(), overwrite = TRUE, as_is = TRUE)
#> Downloaded tables:
#> fields, encodings, categories, archives, esimpint, esimpstring, esimpreal, esimpdate, instances, insvalues, ehierint, ehierstring, catbrowse, recommended, schema
#> 
#> [downloaded tables added to database as-is]
#> 
#> <SQLiteConnection>
#>   Path: C:\Users\ben\AppData\Local\Temp\RtmpMTpxEh\ukb-schema-2019-03-20.sqlite
#>   Extensions: TRUE
#> ...DISCONNECTED
```

Why R?
------

This package was originally written in bash (a Unix shell scripting language). However, R is more accessible and all dependencies are loaded when you install the package; there is no need to install any secondary software (not even SQLite).

Notes
-----

#### Design notes

-   All the encoding value tables (`esimpint`, `esimpstring`, `esimpreal`, `esimpdate`, `ehierint`, `ehierstring`) have been harmonised and combined into a single table `encvalues`. The `value` column in `encvalues` has type `TEXT`, but a `type` column has been added in case the value is not clear from context. The original type-specific tables have been deleted.
-   To avoid redunancy, category parent-child relationships have been moved to table `categories`, as column `parent_id`, from table `catbrowse` (which has been deleted).
-   The value types described [on the UKB Showcase](http://biobank.ctsu.ox.ac.uk/crystal/help.cgi?cd=value_type) have been added manually to a table `valuetypes` and appropriate ID references have been renamed to `value_type_id` in tables `fields` and `encodings`.

#### Known code issues

-   The UK Biobank database schema are regularly updated as new data are added to the system. ukbschema does not currently include a facility for updating the database; it is necessary at present to create a new database.
-   Any [other issues](https://github.com/bjcairns/ukbschema/issues).

#### Known data issues

-   Category 119 does not exist in the data file for categories, but is referenced in table `catbrowse`. As a work-around it has been manually added to the database in [category-parents.sql](sql/category-parents.sql) by inferring information about it from related category [100032](https://biobank.ctsu.ox.ac.uk/crystal/label.cgi?id=100032).
-   Value types as described in <http://biobank.ctsu.ox.ac.uk/crystal/help.cgi?cd=value_type> are not included in the UKB schema. See [Design notes](https://github.com/bjcairns/ukbschema#design-notes), above.
