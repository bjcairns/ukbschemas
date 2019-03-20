#' @importFrom magrittr "%>%"

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
.create_tables <- function(db, sch, silent = FALSE, as_is = FALSE) {
  
  # Start with a blank slate
  .DropAll(db)
  
  if (as_is) {                       # as_is:  Tables as-is from UKB
    purrr::walk2(
      sch,
      names(sch), 
      ~ dplyr::copy_to(dest = db, df = .x, name = .y,
                       temporary = FALSE, overwrite = TRUE)
    )
  }
  
  else {                             # !as_is: Tables were tidied
    
    # CREATE TABLE(s)
    .SendStatement(db, "ukb-schema.sql")
    
    # If we got here, schemas would have been tidied
    
    # Identify esimp* and ehier* tables
    is_esimp_table <- stringr::str_detect(names(sch), "esimp")
    is_ehier_table <- stringr::str_detect(names(sch), "ehier")
    is_encvalue_table <- (is_esimp_table | is_ehier_table)
    
    # Populate non-encvalue tables
    purrr::walk2(
      sch[!is_encvalue_table],
      names(sch[!is_encvalue_table]),
      ~ RSQLite::dbWriteTable(conn = db, name = .y, value = .x,
                              row.names = FALSE, append = TRUE)
    )
    
    # Populate encvalues from esimp* and ehier* tables
    purrr::walk(
      sch[is_encvalue_table],
      ~ RSQLite::dbWriteTable(conn = db, name = "encvalues", value = .x,
                              row.names = FALSE, append = TRUE)
    )
    
  }
  
  db

}
