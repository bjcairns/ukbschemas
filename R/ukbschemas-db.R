#' @title
#' Create UK Biobank data schema database
#' 
#' @description
#' `ukbschemas_db()` generates an SQLite database containing the UK Biobank 
#' data schemas from http://biobank.ctsu.ox.ac.uk/crystal/schema.cgi.
#' 
#' @param file The filename for the schema database. Defaults to `""`, which is 
#' interpreted as `paste0("ukb-schemas-", date, ".sqlite")`. If this file 
#' already exists in directory `path`, the session is interactive, and 
#' `overwrite` is not `FALSE`, then the user will be prompted to decide whether 
#' the file should be overwritten.
#' @param path The path to the directory where the file will be saved. Defaults 
#' to `.` (the current directory).
#' @param date_str The date-stamp for the default filename. Defaults to the
#' current date in `YYYY-MM-DD` format.
#' @param overwrite Always overwrite existing files? Helpful for non-interactive 
#' use. Defaults to `FALSE`.
#' @inheritParams ukbschemas
#' 
#' @return
#' A database connection object of class [RSQLite::SQLiteConnection-class].
#' 
#' @details
#' `ukbschemas_db()` uses [ukbschemas] to load the schemas and [save_db] to save
#' the result.
#' 
#' @examples 
#' \dontrun{
#' db <- ukbschemas_db(db_path = tempdir())
#' }
#' 
#' @importFrom parallel detectCores


### ukbschemas_db() ###
#' @export
ukbschemas_db <- function(
  file = "",
  path = ".",
  date_str = Sys.Date(),
  overwrite = FALSE,
  silent = !interactive(),
  as_is = FALSE,
  url_prefix = UKB_URL_PREFIX,
  sch_id = SCHEMA_FILENAMES[["id"]],
  cache = file.path(Sys.getenv("HOME"), "ukbschemas", "schemas"),
  nThread = detectCores()
){
  
  ## Get and Process the Schemas ##
  sch <- ukbschemas(
    silent = silent,
    as_is = as_is,
    url_prefix = url_prefix,
    sch_id = sch_id,
    cache = cache,
    nThread = nThread
  )
  
  ## Save to Database ##
  db <- save_db(
    sch = sch,
    file = file,
    path = path,
    date_str = date_str,
    silent = silent,
    overwrite = overwrite,
    as_is = as_is
  )
  
  ## Output ##
  return(invisible(db))
  
}

