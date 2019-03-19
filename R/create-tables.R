#' @importFrom magrittr "%>%"
#' 

# Helper to clear the database of tables
.DropAll <- function(db) {
  DBI::dbListTables(db) %>% 
    purrr::map(~ {
      DBI::dbClearResult(
        DBI::dbSendStatement(db, paste0("DROP TABLE ", .x))
      )
    })
  invisible(DBI::dbListTables(db) == character())
}

# Helper to send a statment from an installed SQL file
.SendStatement <- function(db, inst_sql_file) {
  
  NCHAR <- 1e6
  
  DBI::dbClearResult(
    DBI::dbSendStatement(
      db, 
      readChar(
        system.file("sql", inst_sql_file, package = "ukbschema"), 
        NCHAR
      )
    )
  )
  
}


# Create and populate the tables in the database
.create_tables <- function(db, sch, as_is = FALSE) {
  
  if (as_is) {                       # as_is:  Do not tidy
    purrr::walk2(
      sch,
      names(sch), 
      ~ dplyr::copy_to(dest = db, df = .x, name = .y,
                       temporary = FALSE, overwrite = TRUE)
    )
  }
  
  else {                             # !as_is: Tidy first
    
    # CREATE TABLE(s)
    .DropAll(db)
    .SendStatement(db, "ukb-schema.sql")
    
    # Rename columns as needed
    sch$fields <- sch$fields %>%
      dplyr::rename(value_type_id = value_type)
    sch$encodings <- sch$encodings %>%
      dplyr::rename(value_type_id = coded_as)
    
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
    
    # Add column to categories
    sch[["categories"]] <- sch[["categories"]] %>%
      dplyr::mutate(parent_id = NA)
    
    # Populate non-encvalue tables
    purrr::walk2(
      sch[!is_encvalue_table],
      names(sch[!is_encvalue_table]),
      ~ RSQLite::dbWriteTable(conn = db, name = .y, value = .x,
                              row.names = FALSE, append = TRUE)
    )
    
    # Populate encvalues
    purrr::walk(
      sch[is_encvalue_table],
      ~ RSQLite::dbWriteTable(conn = db, name = "encvalues", value = .x,
                              row.names = FALSE, append = TRUE)
    )
    
    # Move parent_ids from catbrowse to categories
    RSQLite::dbWriteTable(conn = db, name = "categories", value = CATEGORY_EXTRA,
                          row.names = FALSE, append = TRUE)
    .SendStatement(db, "category_parents.sql")
  }
  
  db

}
