#' @importFrom magrittr "%>%"

# Helper to send a statment from an installed SQL file
.SendStatement <- function(db, inst_sql_file) {
  
  NCHAR <- 1e6
  
  DBI::dbSendStatement(
    db, 
    readChar(
      system.file("sql", inst_sql_file, package = "ukbschema"), 
      NCHAR
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
    
    .SendStatement(db, "ukb-schema.sql")
    
    db_tables <- DBI::dbListTables(db)
    db_table_names <- 
      db_tables %>% purrr::map(~ DBI::dbListFields(db, .x))
    
    sch$fields <- sch$fields %>%
      rename(value_type_id = value_type)
    sch$encodings <- sch$encodings %>%
      rename(value_type_id = coded_as)
    
    purrr::walk2(
      sch,
      names(sch),
      ~ RSQLite::dbWriteTable(conn = db, name = .y, value = .x,
                              row.names = FALSE, append = TRUE)
    )
  }
  
  db

}
