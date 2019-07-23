#' Create UK Biobank data schema database
#' 
#' `ukbschemas_db()` generates an SQLite database containing the UK Biobank 
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
#' @param overwrite Always overwrite existing files? Helpful for non-interactive 
#' use. Defaults to `FALSE`.
#' @inheritParams ukbschemas
#' 
#' @return A database connection object of class 
#' [RSQLite::SQLiteConnection-class].
#' 
#' @details `ukbschemas_db()` uses [ukbschemas] to load the schemas and 
#' [save_db] to save the result.
#' 
#' @examples 
#' \dontrun{
#' db <- ukbschemas_db(path = tempdir())
#' }
#' @importFrom magrittr "%>%"
#' @export

ukbschemas_db <- function(
  file = "", 
  path = ".", 
  date_str = Sys.Date(), 
  overwrite = FALSE,
  silent = !interactive(), 
  as_is = FALSE, 
  url_prefix = UKB_URL_PREFIX
) {
  
  # Careful to disconnect the database after function is done
  on.exit(.quiet_dbDisconnect(db))
  
  # Get and process the schemas
  sch <- ukbschemas(silent, as_is, url_prefix)
  
  # Save to database
  db <- save_db(sch, file, path, date_str, silent, overwrite, as_is)
  
  invisible(db)
  
}

