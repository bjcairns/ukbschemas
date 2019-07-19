#' Save a list of UK Biobank data schemas to an SQLite database
#' 
#' `save_db()` saves a list of UK Biobank data schemas (or, if 
#' `as_is == TRUE`, any list of tibbles) to an SQLite database
#' 
#' @param sch List of tibbles, representing UK Biobank data schemas (unless 
#' `as_is == TRUE`, in which case any list of tibbles is permitted)
#' @param file The filename for the schema database. Defaults to `""`, which is 
#' interpreted as `paste0("ukb-schemas-", date, ".sqlite")`. If this file 
#' already exists in directory `path`, the session is interactive, and 
#' `overwrite` is not `FALSE`, then the user will be prompted to decide whether 
#' the file should be overwritten.
#' @param path The path to the directory where the file will be saved. Defaults 
#' to `.` (the current directory).
#' @param date_str The date-stamp for the default filename. Defaults to the current 
#' date in `YYYY-MM-DD` format.
#' @param silent Do not report progress. Defaults to `FALSE`.
#' @param overwrite Always overwrite existing files? Helpful for non-interactive 
#' use. Defaults to `FALSE`.
#' @param as_is Import the schemas into the database without tidying? Defaults 
#' to `FALSE`.
#' 
#' @return A database connection object of class 
#' [RSQLite::SQLiteConnection-class]. 
#' 
#' @details `save_db()` takes a list of UK Biobank schemas and saves 
#' them to an SQLite database. Note that if the table structure has 
#' changed (i.e. has been changed by UK Biobank), then the function may fail 
#' partially or fully. 
#' 
#' @export

save_db <- function(
  sch, 
  file = "", 
  path = ".", 
  date_str = Sys.Date(), 
  silent = !interactive(), 
  overwrite = FALSE,
  as_is = FALSE
) {
  
  # Confirm file/path and remove if overwrite
  full_path <- .check_file_path(file, path, date_str, overwrite)
  
  # Create database
  tryCatch(
    db <- DBI::dbConnect(RSQLite::SQLite(), full_path),
    error = function(err) {
      stop(UKBSCHEMAS_ERRORS$DB_NO_CONNECT)
    }
  )
  on.exit(.quiet_dbDisconnect(db))
  
  # Create database
  tryCatch(
    {
      .create_tables(db, as_is = as_is)
      .write_tables(sch, db)
    },
    error = function(err) {
      stop(UKBSCHEMAS_ERRORS$DB_POPULATE_ERROR)
    }
  )
  
  # Wrap up and (extra careful) close the connection
  if (!silent) print(db)
  .quiet_dbDisconnect(db)
  if (!silent) cat("...DISCONNECTED\n")
  
  invisible(db)
  
}