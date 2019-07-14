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


# Helper to send statement(s) from an installed SQL file
.SendStatement <- function(db, inst_sql_file) {
  
  sql <- readr::read_file(
    system.file("sql", inst_sql_file, package = "ukbschemas")
  )
  sql <- unlist(strsplit(sql, ";", fixed = TRUE)) %>% 
    purrr::map_chr(~ gsub("[\r\n]", "", .x))
  
  sql[sql != ""] %>%
    purrr::walk(
      ~ DBI::dbClearResult(
        DBI::dbSendStatement(db, .x)
      )
    )
  
  invisible(TRUE)
  
}


# Create and populate the tables in the database
.create_tables <- function(db, sch, silent = FALSE, as_is = FALSE) {
  
  # Start with a blank slate
  .DropAll(db)
  
  if (as_is) {                       # as_is:  Tables as-is from UKB
    
    # For each tbl in sch and its name, copy the tbl to db to a table of 
    # the same name
    purrr::walk2(
      sch,
      names(sch), 
      ~ dplyr::copy_to(dest = db, df = .x, name = .y,
                       temporary = FALSE, overwrite = TRUE)
    )
  }
  
  else {                             # !as_is: Tables were tidied
    
    # CREATE TABLE(s)
    .SendStatement(db, "ukb-schemas.sql")
    
    # Populate tables
    purrr::walk2(
      sch,
      names(sch),
      ~ RSQLite::dbWriteTable(conn = db, name = .y, value = .x,
                              row.names = FALSE, append = TRUE)
    )
    
  }
  
  db

}
