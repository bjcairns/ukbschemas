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
#' [RSQLite::SQLiteConnection-class]
#' 
#' @details Most of the workings of `create_schema_db()` are hidden from the 
#' user; the function downloads all the schema files and loads them into 
#' an SQLite database with pre-defined table structure. Note that if the 
#' table structure has changed (i.e. has been changed by UK Biobank), then the 
#' function will fail partially or fully. Debugging information may be helpful 
#' to diagnose and/or fix such failures. Fixes currently require changes to 
#' the `.sql` files in the `sql/` subsdirectory of the package installation.
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
    error("ukbschema does not support in-memory databases")
  }
  
  # Parse file name and path
  if (file == "") file <- paste0("ukb-schema-", date, ".sqlite")
  full_path <- paste0(path.expand(path), "/", file)
  
  # If file exists, interactive() and !overwrite, prompt to overwrite
  if (file.exists(full_path)) {
    if (interactive() & !isTRUE(overwrite)) {
      overwrite <- askYesNo(
        "Database file already exists. Overwrite?", 
        default = FALSE
      )
    }
    if (!isTRUE(overwrite)) stop("Could not overwrite existing file")
    else file.remove(full_path)
  }
  
  # Download and tidy schema tables
  sch <- .get_schemas(debug = debug, quote = "")
  if (!silent) {
    cat("Downloaded tables:\n")
    print(names(sch))
    cat("\n")
  }
  if (!as_is) {
    sch <- .tidy_schemas(sch, silent = silent)
  }
  
  # Create database
  db <- DBI::dbConnect(RSQLite::SQLite(), full_path)
  
  # Populate database
  .create_tables(db, sch, as_is)
  
  # Always close the connection
  if (!silent) print(db)
  DBI::dbDisconnect(db)
  if (!silent) cat("...DISCONNECTED\n")
  
  invisible(db)
  
}
