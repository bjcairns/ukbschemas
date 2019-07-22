#' Load schemas from a ukbschemas database
#' 
#' `load_db()` is a simple front-end to [DBI] functions which can be 
#' used to load tables from a ukbschemas database.
#' 
#' @param file Full path to an SQLite database, or `NULL`.
#' @param db A (possibly disconnected) database connection, or `NULL`.
#' 
#' @details `load_db()` will attempt to open an SQLite database from file 
#' `file` or from connection `db`. It will throw errors if the file is not a 
#' valid databse or it is impossible to create a valid connection from `db`. 
#' Tables are read with [DBI::dbReadTable] and converted to data frames of 
#' class `tbl_df` (see [tibble::tibble]). The database connection is always 
#' closed before the function returns its result.
#' 
#' @return A named list with elements of class `tbl_df`, containing the tables 
#' from `db`.
#' 
#' @examples 
#' \dontrun{
#' db <- ukbschemas_db(path = tempdir())
#' sch <- load_db(db = db)
#' }
#' @importFrom magrittr "%>%"
#' @export

load_db <- function(file = NULL, db = NULL) {
  
  # Attempt to connect to the database and handle failures
  if (!is.null(file)) 
    db <- .graceful_dbConnect_file(file = file)
  else if (!DBI::dbIsValid(db)) 
    db <- .graceful_dbConnect_db(db = db)
  
  # Always disconnect
  on.exit(.quiet_dbDisconnect(db))
  
  # Load the tables from `db`
  sch <- .read_tables(db)
  
  # Always, definitely, disconnect
  .quiet_dbDisconnect(db)
  
  sch
  
}
