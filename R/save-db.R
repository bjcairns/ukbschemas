#' @title
#' Save a list of UK Biobank data schemas to an SQLite database
#' 
#' @description 
#' `save_db()` saves a list of UK Biobank data schemas (or, if `as_is == TRUE`, 
#' any list of data frames) to an SQLite database.
#' 
#' @param sch List of data frames, representing UK Biobank data schemas (unless 
#' `as_is == TRUE`, in which case any list of data frames is permitted)
#' @param file The filename for the schema database. Defaults to `""`, which is 
#' interpreted as `paste0("ukb-schemas-", date, ".sqlite")`. If this file 
#' already exists in directory `path`, the session is interactive, and 
#' `overwrite` is not `FALSE`, then the user will be prompted to decide whether 
#' the file should be overwritten.
#' @param path The path to the directory where the file will be saved. Defaults 
#' to `.` (the current directory).
#' @param date_str The date-stamp for the default filename. Defaults to the 
#' current date in `YYYY-MM-DD` format.
#' @param silent Do not report progress. Defaults to `FALSE`.
#' @param overwrite Always overwrite existing files? Helpful for 
#' non-interactive use. Defaults to `FALSE`.
#' @param as_is Import the schemas into the database without tidying? Defaults 
#' to `FALSE`.
#' 
#' @return
#' A database connection object of class 
#' [RSQLite::SQLiteConnection-class]. 
#' 
#' @details
#' `save_db()` takes a list of UK Biobank schemas and saves them to an SQLite
#' database. If `!as_is`, they are tidied. Note that if the table structure has
#' changed (i.e. has been changed by UK Biobank), then the function may fail
#' partially or fully unless `as_is == TRUE`.
#' 
#' @examples 
#' \dontrun{
#' sch <- ukbschemas()
#' db <- save_db(sch, path = tempdir())
#' }
#' 
#' @importFrom DBI dbConnect
#' @importFrom RSQLite SQLite


### save_db() ###
#' @export
save_db <- function(
  sch,
  file = "",
  path = ".",
  date_str = Sys.Date(),
  silent = !interactive(),
  overwrite = FALSE,
  as_is = FALSE
){
  
  ## Confirm File/Path & Remove if Overwrite ##
  full_path <- .check_file_path(
    file = file,
    path = path,
    date_str = date_str,
    overwrite = overwrite
  )
  
  ## Connect to Database ##
  db <- tryCatch(
    expr = dbConnect(drv = SQLite(), full_path),
    error = function(err) {
      stop(UKBSCHEMAS_ERRORS[["DB_NO_CONNECT"]])
    }
  )
  
  ## Disconnect On Exit ##
  on.exit(.quiet_dbDisconnect(db = db))
  
  ## Populate Database ##
  tryCatch(
    expr = {
      .create_tables(db, as_is = as_is)
      .write_tables(tbls = sch, db = db)
    },
    error = function(err) {
      stop(UKBSCHEMAS_ERRORS[["DB_POPULATE_ERROR"]])
    }
  )
  
  ## Verbosity ##
  if (!silent) {
    message("DB: ", db)
    message("...DISCONNECTED")
  }
  
  ## Output ##
  return(invisible(db))
  
}
