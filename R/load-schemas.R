#' Load schemas from a ukbschema database
#' 
#' `load_schemas()` is a simple front-end to [DBI::DBI] functions which can be 
#' used to load tables from a ukbschema database.
#' 
#' @param db A (possibly disconnected) database connection.
#' 
#' @details `load_schemas()` will attempt to open connection `db` and will 
#' throw an error if this is not possible. Tables are read with 
#' [DBI::dbReadTable] and converted to data frames of class `tbl_df`. The 
#' database connection is always closed after the tables are loaded.
#' 
#' @return A named list with elements of class [tibble::tbl_df], containing the 
#' tables from `db`.
#' 
#' @importFrom magrittr "%>%"
#' @export

load_schemas <- function(db) {
  
  tryCatch(db <- dbConnect(db),
           error = function(err) {
             stop("Could not connect to database")
           }
  )
  
  sch_names <- DBI::dbListTables(db)
  sch <- sch_names %>%
    purrr::map(
      ~ tibble::as_tibble(DBI::dbReadTable(db, .x))
    )
  names(sch) <- sch_names
  
  DBI::dbDisconnect(db)
  
  sch
  
}
