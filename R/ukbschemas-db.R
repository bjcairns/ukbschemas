#' @title
#' Create UK Biobank data schema database
#' 
#' @description
#' `ukbschemas_db()` generates an SQLite database containing the UK Biobank 
#' data schemas from http://biobank.ctsu.ox.ac.uk/crystal/schema.cgi.
#' 
#' @param db_file The filename for the schema database. Defaults to `""`, which is 
#' interpreted as `paste0("ukb-schemas-", date, ".sqlite")`. If this file 
#' already exists in directory `path`, the session is interactive, and 
#' `overwrite` is not `FALSE`, then the user will be prompted to decide whether 
#' the file should be overwritten.
#' @param db_path The path to the directory where the file will be saved. Defaults 
#' to `.` (the current directory).
#' @param sch_id The id numbers of the schemas to download. Type
#' `SCHEMA_FILENAMES` for reference. Defaults to all.
#' @param sch_path The directory path of the schema download cache. Defaults to
#' `r file.path(tempdir(), "ukbschemas", "schemas")`.
#' @param date_str The date-stamp for the default filename. Defaults to the
#' current date in `YYYY-MM-DD` format.
#' @param overwrite Always overwrite existing files? Helpful for non-interactive 
#' use. Defaults to `FALSE`.
#' @param nThread Number of threads to spawn for parallelisable tasks, such as
#' the downloading and importing of the schemas. Defaults to the number of
#' logical cores present on the system.
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
  db_file = "",
  db_path = ".",
  sch_id = SCHEMA_FILENAMES[["id"]],
  sch_path = file.path(tempdir(), "ukbschemas", "schemas"),
  date_str = Sys.Date(),
  overwrite = FALSE,
  as_is = FALSE,
  nThread = detectCores(),
  silent = !interactive()
){
  
  ## Get and Process the Schemas ##
  sch <- ukbschemas(
    sch_id = sch_id,
    sch_path = sch_path,
    as_is = as_is,
    nThread = nThread,
    silent = silent
  )
  
  ## Save to Database ##
  db <- save_db(
    sch = sch,
    db_file = db_file,
    db_path = db_path,
    date_str = date_str,
    silent = silent,
    overwrite = overwrite,
    as_is = as_is
  )
  
  ## Output ##
  return(invisible(db))
  
}

