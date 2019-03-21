#' Load schemas from a ukbschema database
#' 
#' `load_schemas()` is a simple front-end to [DBI::DBI] functions which can be 
#' used to load tables from a ukbschema database.
#' 
#' @param file Full path to an SQLite database, or `NULL`.
#' @param db A (possibly disconnected) database connection, or `NULL`.
#' 
#' @details `load_schemas()` will attempt to open connection `db` (if closed) 
#' and will throw an error if this is not possible. Tables are read with 
#' [DBI::dbReadTable] and converted to data frames of class `tbl_df`. The 
#' database connection is *always* closed after the tables are loaded.
#' 
#' @return A named list with elements of class [tibble::tbl_df], containing the 
#' tables from `db`.
#' 
#' @importFrom magrittr "%>%"
#' @export

load_schemas <- function(file = NULL, db = NULL) {
  
  if (!is.null(file)) {
    if (!is.character(file) | length(file) != 1 | !file.exists(file)) 
      stop("Not a valid name of an existing file")
    tryCatch(
      db <- DBI::dbConnect(RSQLite::SQLite(), file),
      error = function(err) {
        stop(paste0("Could not connect to database (", file, ")"))
      }
    )
  }
  if (!is.null(db)) {
    if (!DBI::dbIsValid(db)) tryCatch(
      db <- DBI::dbConnect(db),
      error = function(err) {
        stop("Could not connect to database")
      }
    )
  }
  
  sch_names <- DBI::dbListTables(db)
  sch <- sch_names %>%
    purrr::map(
      ~ tibble::as_tibble(DBI::dbReadTable(db, .x))
    )
  names(sch) <- sch_names
  
  DBI::dbDisconnect(db)
  
  sch
  
}
