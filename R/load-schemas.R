#' Load schemas from a ukbschema database
#' 
#' `load_schemas()` is a simple front-end to [DBI::DBI] functions which can be 
#' used to load tables from a ukbschema database.
#' 
#' @param file Full path to an SQLite database, or `NULL`.
#' @param db A (possibly disconnected) database connection, or `NULL`.
#' 
#' @details `load_schemas()` will attempt to open `file` as an SQLite database, 
#' or will attempt to open connection `db` (if closed) and will throw errors if 
#' the file is not a valid databse or it is impossible to create a valid 
#' connection from `db`. Tables are read with [DBI::dbReadTable] and converted 
#' to data frames of class `tbl_df`. The database connection is *always* closed 
#' before the function returns its result.
#' 
#' @return A named list with elements of class [tibble::tbl_df], containing the 
#' tables from `db`.
#' 
#' @importFrom magrittr "%>%"
#' @export

load_schemas <- function(file = NULL, db = NULL) {
  
  # Attempt to connect to the database and handle failures
  if (!is.null(file)) {
    if (!is.character(file) | length(file) != 1 | !file.exists(file)) 
      stop(UKBSCHEMA_ERRORS$FILE_NOT_EXISTS)
    tryCatch(
      db <- DBI::dbConnect(RSQLite::SQLite(), file),
      error = function(err) {
        stop(paste0(UKBSCHEMA_ERRORS$DB_NO_CONNECT, " (", file, ")"))
      }
    )
  }
  
  # If no `file` was loaded or it is invalid, connect to `db`
  if (!is.null(db)) {
    if (!DBI::dbIsValid(db)) tryCatch(
      db <- DBI::dbConnect(db),
      error = function(err) {
        stop(UKBSCHEMA_ERRORS$DB_NO_CONNECT)
      }
    )
  }
  
  # Load the tables from `db` by name
  sch_names <- DBI::dbListTables(db)
  sch <- sch_names %>%
    purrr::map(
      ~ tibble::as_tibble(DBI::dbReadTable(db, .x))
    )
  names(sch) <- sch_names
  
  # Always disconnect
  DBI::dbDisconnect(db)
  
  sch
  
}
