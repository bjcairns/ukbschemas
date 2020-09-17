library(ukbschemas)
library(stubble)
library(magrittr)

use_rows <- 10

temp_prefix <- tempdir(check = TRUE)
stopifnot(dir.exists(temp_prefix))
cat("Temporarily saving schemas to: ", temp_prefix, "\n")

# Get the files
ukbschemas:::SCHEMA_FILENAMES$id %>%
  purrr::walk(
    ~ if (!file.exists(paste0(temp_prefix, "\\", .))) {
      curl::curl_download(
        url = paste0(ukbschemas:::UKB_URL_PREFIX, .),
        destfile = paste0(temp_prefix, "\\", .)
      )
    }
  )

# Set up 'raw' schemas
sch <- ukbschemas:::SCHEMA_FILENAMES$id %>%
  purrr::map(
    ~ read.delim(paste0(temp_prefix, "\\", .), stringsAsFactors = FALSE)
  )
names(sch) <- ukbschemas:::SCHEMA_FILENAMES$filename

# Work out which fields should be unique (primary keys)
uniqs <- sch %>%
  purrr::map2(
    names(sch),
    function(x, y) {
      uniq <- rep(FALSE, ncol(x))
      if (!(substr(y, 1, 5) %in% c("insva", "recom", "esimp", "ehier"))) {
        uniq[1] <- TRUE
      }
      if (y == "catbrowse") {
        uniq[3] <- TRUE
      }
      uniq
    }
  )

# Create stubble
set.seed(2020021013)
test_schemas <- sch %>%
  purrr::map2(
    uniqs, 
    ~ stubblise(
      .x, 
      rows = use_rows, 
      unique = .y,
      int_max = use_rows * 2,
      chr_sym = list(LETTERS), 
      chr_min = 1
    )
  )

# Fixes to match the relational structure of the schemas

# catbrowse:
# - fewer rows than in categories
test_schemas$catbrowse <- 
  test_schemas$catbrowse[seq(to = use_rows / 2),]
# - child_id should be from category_id
use_category_ids <- test_schemas$categories$category_id
test_schemas$catbrowse$child_id <- 
  sample(
    use_category_ids, use_rows / 2, replace = FALSE
  )
# - parent_id from those not in child_id (depth 1 tree)
test_schemas$catbrowse$parent_id <-
  sample(
    setdiff(use_category_ids, test_schemas$catbrowse$child_id), 
    use_rows / 2, 
    replace = TRUE
  )

# instances and insvalues
# - fewer rows in instances than in insvalues
test_schemas$instances <- 
  test_schemas$instances[seq_along(use_rows / 2),]
# - insvalues instance_id from instances instance_id
use_instance_ids <- test_schemas$instances$instance_id
test_schemas$insvalues$instance_id <- 
  sample(
    use_instance_ids, use_rows, replace = FALSE
  )
# - insvalues index should be unique within instance_id (NOT DONE)

# recommended
# - recommended categories and fields should be from those tables
test_schemas$recommended$category_id <-
  sample(
    use_category_ids, use_rows, replace = FALSE
  )
use_field_ids <- test_schemas$fields$field_id
test_schemas$recommended$field_id <-
  sample(
    use_field_ids, use_rows, replace = FALSE
  )

# ehier* and esimp*
# - encoding_id should be unique between but not necessarily within these
encoding_tables <- names(test_schemas)[
  substr(names(test_schemas), 1, 5) %in% c("esimp", "ehier")
  ]
all_encoding_ids <- test_schemas[[encoding_tables[1]]]$encoding_id
for (tbl in encoding_tables[-1]) {
  
  all_encoding_ids <- c(all_encoding_ids, test_schemas[[tbl]]$encoding_id)
}

# ehier*
# - encoding_id should come from encodings table
use_encoding_ids <- test_schemas$encodings$encoding_id
test_schemas$ehierint$encoding_id <-
  sample(
    use_encoding_ids, use_rows, replace = FALSE
  )
test_schemas$ehierstring$encoding_id <-
  sample(
    use_encoding_ids, use_rows, replace = FALSE
  )
# - parent_id should be a subset of code_id
use_code_ids_int <- test_schemas$ehierint$code_id
test_schemas$ehierint$parent_id <-
  sample(
    use_code_ids_int, use_rows, replace = FALSE
  )
use_code_ids_str <- test_schemas$ehierstring$code_id
test_schemas$ehierstring$parent_id <-
  sample(
    use_code_ids_str, use_rows, replace = FALSE
  )
# - pick only unique encoding_id - code_id pairs
test_schemas$ehierint <-
  test_schemas$ehierint[!duplicated(test_schemas$ehierint[,1:2]),]
test_schemas$ehierstring <-
  test_schemas$ehierstring[!duplicated(test_schemas$ehierstring[,1:2]),]

