#' Load schemas from a ukbschemas database
#' 
#' `load_schema_db()` is a simple front-end to [DBI] functions which can be 
#' used to load tables from a ukbschemas database.
#' 
#' @param file Full path to an SQLite database, or `NULL`.
#' @param db A (possibly disconnected) database connection, or `NULL`.
#' 
#' @details `load_schema_db()` will attempt to open `file` as an SQLite database, 
#' or will attempt to open connection `db` (if closed) and will throw errors if 
#' the file is not a valid databse or it is impossible to create a valid 
#' connection from `db`. Tables are read with [DBI::dbReadTable] and converted 
#' to data frames of class `tbl_df` (see [tibble::tibble]). The database 
#' connection is always closed before the function returns its result.
#' 
#' @return A named list with elements of class `tbl_df`, containing the tables 
#' from `db`.
#' 
#' @importFrom magrittr "%>%"
#' @export

load_schema_db <- function(file = NULL, db = NULL) {
  
  # Attempt to connect to the database and handle failures
  if (!is.null(file)) {
    if (!is.character(file) | length(file) != 1 | !file.exists(file)) 
      stop(UKBSCHEMAS_ERRORS$FILE_NOT_EXISTS)
    tryCatch(
      db <- DBI::dbConnect(RSQLite::SQLite(), file),
      error = function(err) {
        stop(paste0(UKBSCHEMAS_ERRORS$DB_NO_CONNECT, " (", file, ")"))
      }
    )
    on.exit(.quiet_dbDisconnect(db))
  }
  
  # If no `file` was loaded or it is invalid, connect to `db`
  if (!is.null(db)) {
    if (!DBI::dbIsValid(db)) {
      tryCatch(
        db <- DBI::dbConnect(db),
        error = function(err) {
          stop(UKBSCHEMAS_ERRORS$DB_NO_CONNECT)
        }
      )
      on.exit(.quiet_dbDisconnect(db))
    }
  }
  
  # Load the tables from `db` by name
  sch_names <- DBI::dbListTables(db)
  sch <- sch_names %>%
    purrr::map(
      ~ tibble::as_tibble(DBI::dbReadTable(db, .x))
    )
  names(sch) <- sch_names
  
  # Always disconnect
  .quiet_dbDisconnect(db)
  
  sch
  
}
