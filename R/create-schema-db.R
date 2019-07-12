#' Create UK Biobank data schema database
#' 
#' `create_schema_db()` generates an SQLite database containing the UK Biobank 
#' data dictionaries from http://biobank.ctsu.ox.ac.uk/crystal/schema.cgi
#' 
#' @param file The filename for the schema database. Defaults to `""`, which is 
#' interpreted as `paste0("ukb-schema-", date, ".sqlite")`. If this file already
#' exists in directory `path`, the session is interactive, and `overwrite` is 
#' not `FALSE`, then the user will be prompted to decide whether the file should 
#' be overwritten.
#' @param path The path to the directory where the file will be saved. Defaults 
#' to `.` (the current directory).
#' @param date The date-stamp for the default filename. Defaults to the current 
#' date in `YYYY-MM-DD` format.
#' @param silent Do not report progress. Defaults to `FALSE`.
#' @param debug Report debugging information (useful when e.g. the structure of 
#' the schema files has changed). Defaults to `FALSE`.
#' @param overwrite Always overwrite existing files? Helpful for non-interactive 
#' use. Defaults to `FALSE`.
#' @param as_is Import the schemas into the database without tidying? Defaults 
#' to `FALSE`.
#' 
#' @return A database connection object of class 
#' [RSQLite::SQLiteConnection-class].
#' 
#' @details Most of the workings of `create_schema_db()` are hidden from the 
#' user; the function downloads all the schema files and loads them into 
#' an SQLite database with pre-defined table structure. Note that if the 
#' table structure has changed (i.e. has been changed by UK Biobank), then the 
#' function will fail partially or fully. Debugging information (`debug = TRUE`) 
#' may be helpful to diagnose and/or fix such failures. 
#' 
#' @importFrom magrittr "%>%"
#' @export

create_schema_db <- function(
  file = "", 
  path = ".", 
  date = Sys.Date(), 
  silent = !interactive(), 
  debug = FALSE, 
  overwrite = FALSE,
  as_is = FALSE
) {

  if (debug & !silent) silent <- FALSE
  
  # Catch user attempts to force db creation in memory
  if (file == ":memory:" | file == "file::memory:") {
    file <- NULL
    stop(UKBSCHEMA_ERRORS$NO_IN_MEMORY)
  }
  
  # Parse file name and path
  if (file == "") file <- paste0("ukb-schema-", date, ".sqlite")
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
      stop(UKBSCHEMA_ERRORS$OVERWRITE)
    else tryCatch(
      file.remove(full_path),
      error = function(err) {
        stop(UKBSCHEMA_ERRORS$FAILED_OVERWRITE)
      },
      warning = function(warn) {
        stop(UKBSCHEMA_ERRORS$FAILED_OVERWRITE)
      }
    )
  }
  
  # Download and tidy (?) schema tables
  sch <- .get_schemas(debug = debug, quote = "")
  if (!silent) {
    cat("Downloaded tables:\n")
    cat(paste(names(sch), collapse = ", "))
    cat("\n\n")
  }
  if (!as_is) {
    sch <- .tidy_schemas(sch, silent = silent)
  }
  else {
    cat("[downloaded tables added to database as-is]\n\n")
  }
  
  # Create database
  db <- DBI::dbConnect(RSQLite::SQLite(), full_path)
  on.exit(suppressWarnings(DBI::dbDisconnect(db)))
  
  # Populate database
  .create_tables(db, sch, silent = silent, as_is = as_is)
  
  # Always close the connection
  if (!silent) print(db)
  suppressWarnings(DBI::dbDisconnect(db))
  if (!silent) cat("...DISCONNECTED\n")
  
  invisible(db)
  
}
