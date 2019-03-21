#' @importFrom magrittr "%>%"

# Help to tidy up the schemas
.tidy_schemas <- function(sch, silent = FALSE) {
  
  if (!silent) cat("Tidying:\n")
  
  sch <- 
    sch %>% append(list(valuetypes=VALUE_TYPES))
  if (!silent) cat("... Added table `value_types`\n")
  
  # Rename columns as needed
  sch$fields <- sch$fields %>%
    dplyr::rename(value_type_id = value_type)
  sch$encodings <- sch$encodings %>%
    dplyr::rename(value_type_id = coded_as)
  if (!silent) {
    cat("... Rename to value_type_id in tables ")
    cat("`fields` and `encodings` \n")
  }
  
  # Add category 119 to categories
  sch[["categories"]] <-
    dplyr::bind_rows(sch[["categories"]], CATEGORY_EXTRA)
  if (!silent) {
    cat("... Add missing category 119 (Reaction time test)\n")
  }
  
  # Add column to categories
  sch[["categories"]] <- 
    dplyr::left_join(sch[["categories"]], sch[["catbrowse"]], 
                     by = c("category_id" = "child_id"))
  sch["catbrowse"] <- NULL
  if (!silent) {
    cat("... Add parent_id from `catbrowse` to `categories` (delete former)\n")
  }
  
  # Identify esimp* and ehier* tables
  is_esimp_table <- stringr::str_detect(names(sch), "esimp")
  is_ehier_table <- stringr::str_detect(names(sch), "ehier")
  is_encvalue_table <- (is_esimp_table | is_ehier_table)
  
  # Add columns to esimp* tables
  sch[is_esimp_table] <- sch[is_esimp_table] %>%
    purrr::map(
      ~ {
        type <- as.character(
          dplyr::select(.x, value) %>% dplyr::summarise_all(class)
        )
        dplyr::mutate(.x, parent_id = NA, selectable = NA) %>%
          dplyr::mutate(type = type, value = as.character(value)) %>%
          dplyr::group_by(encoding_id) %>%
          dplyr::mutate(code_id = row_number()) %>%
          dplyr::ungroup()
      }
    )
  
  # Add columns to ehier* tables
  sch[is_ehier_table] <- sch[is_ehier_table] %>%
    purrr::map(
      ~ {
        type <- as.character(
          dplyr::select(.x, value) %>% dplyr::summarise_all(class)
        )
        dplyr::mutate(
          .x,
          type = type, 
          value = as.character(value)
        )
      }
    )
  
  if (!silent) {
    cat("... Harmonise `esimp*` and `ehier*` tables to add to `encvalues`\n")
  }
  
  if (!silent) cat("\n")
  
  invisible(sch)
}