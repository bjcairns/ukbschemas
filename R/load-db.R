#' @title
#' Load schemas from a ukbschemas SQLite database
#' 
#' @description 
#' `load_db()` is a simple front-end to [DBI] functions which can be used to
#' load tables from a ukbschemas database (or in fact, any database; see
#' [DBI::DBI-package]).
#' 
#' @param file Full path to an SQLite database, or `NULL`.
#' @param db A (possibly disconnected) database connection, or `NULL`.
#' 
#' @details
#' `load_db()` will attempt to open an SQLite database from file `file` or
#' from connection `db`. It will throw errors if the file is not a valid
#' database or it is impossible to create a valid connection from `db`. Tables
#' are read with [DBI::dbReadTable] and converted to data frames. The database
#' connection is always closed before the function returns its result.
#' 
#' @return
#' A named list with elements of class `tbl_df`, containing the tables 
#' from `db`.
#' 
#' @examples 
#' \dontrun{
#' db <- ukbschemas_db(path = tempdir())
#' sch <- load_db(db = db)
#' }
#' 
#' @importFrom DBI dbIsValid


### load_db() ###
#' @export
load_db <- function(file = NULL, db = NULL) {
  
  ## Attempt to Connect to the Database & Handle Failures ##
  if (!is.null(file)) 
    db <- .graceful_dbConnect_file(file = file)
  else if (!dbIsValid(db)) 
    db <- .graceful_dbConnect_db(db = db)
  
  ## Disconnect On Exit ##
  on.exit(.quiet_dbDisconnect(db))
  
  ## Load the Tables from db ##
  sch <- .read_tables(db)
  
  ## Output ##
  return(sch)
  
}
