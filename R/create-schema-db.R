# Confirm that the file and path are OK
.check_file_path <- function(file, path, date_str, overwrite) {
  
  # Catch user attempts to force db creation in memory
  if (file == ":memory:" | file == "file::memory:") {
    file <- NULL
    stop(UKBSCHEMAS_ERRORS$NO_IN_MEMORY)
  }
  
  # Parse file name and path
  if (file == "") file <- paste0("ukb-schemas-", date_str, ".sqlite")
  full_path <- paste0(path.expand(path), "\\", file)
  
  # If `file`` exists, session is `interactive()` and `!overwrite`, then prompt 
  # to overwrite the file
  if (file.exists(full_path)) {
    if (interactive() & !isTRUE(overwrite)) {
      overwrite <- utils::askYesNo(
        "Database file already exists. Overwrite?", 
        default = FALSE
      )
    }
    if (!isTRUE(overwrite)) 
      stop(UKBSCHEMAS_ERRORS$OVERWRITE)
    else tryCatch(
      file.remove(full_path),
      error = function(err) {
        stop(UKBSCHEMAS_ERRORS$FAILED_OVERWRITE)
      },
      warning = function(warn) {
        stop(UKBSCHEMAS_ERRORS$FAILED_OVERWRITE)
      }
    )
  }
  
  full_path
  
}


#' Create UK Biobank data schema database
#' 
#' `create_schema_db()` generates an SQLite database containing the UK Biobank 
#' data schemas from http://biobank.ctsu.ox.ac.uk/crystal/schema.cgi
#' 
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
#' @param debug Report debugging information (useful when e.g. the structure of 
#' the schema files has changed). Defaults to `FALSE`.
#' 
#' @return A database connection object of class 
#' [RSQLite::SQLiteConnection-class].
#' 
#' @details `create_schema_db()` uses [ukbschemas] to load the schemas and 
#' [save_schema_db] to save the result. Debugging information (`debug = TRUE`) 
#' may be helpful to diagnose and/or fix such failures.
#' 
#' @importFrom magrittr "%>%"
#' @export

create_schema_db <- function(
  file = "", 
  path = ".", 
  date_str = Sys.Date(), 
  silent = !interactive(), 
  overwrite = FALSE,
  as_is = FALSE, 
  debug = FALSE
) {
  
  if (debug & silent) silent <- FALSE
  
  # Careful to disconnect the database after function is done
  on.exit(.quiet_dbDisconnect(db))
  
  # Get and process the schemas
  sch <- ukbschemas(silent, as_is, debug)
  
  # Save to database
  db <- save_schema_db(sch, file, path, date_str, silent, overwrite, as_is)
  
  invisible(db)
  
}

