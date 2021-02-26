#' @title
#' Load the UK Biobank data schemas from the Internet or other repository
#' 
#' @param silent Do not report progress. Defaults to `FALSE`.
#' @param as_is Import the schemas into the database without tidying? Defaults to `FALSE`.
#' @param url_prefix First part of the URL at which the schema files can be found. For local
#' repositories, the directory with a trailing delimiter (i.e. `/` or `\\` or `\\\\` as appropriate
#' to your operating system).
#' @param sch_id The id numbers of the schemas to download. Type `SCHEMA_FILENAMES` for reference.
#' Defaults to all.
#' @param cache The directory path of the schema download cache. Defaults to
#' `file.path(Sys.getenv("HOME"), "ukbschemas", "schemas")`.
#' @param nThread Number of threads to spawn for parallelisable tasks, such as the downloading and
#' importing of the schemas. Defaults to the number of logical cores present on the system.
#' 
#' @return
#' A list of objects of class `data.frame`.
#' 
#' @details
#' The UK Biobank data schemas are fetched via the Internet unless a  different `url_prefix` is
#' provided. If `as_is == FALSE`, they are tidied. Note that if the table structure has changed
#' (i.e. has been changed by UK Biobank), then the function may fail partially or fully unless
#' `as_is == TRUE`. 
#'
#' @note
#' This is a convenience function to load the schemas directly from the UK Biobank website. For most
#' purposes, it is recommended to use [ukbschemas_db] and [load_db] instead.
#'
#' @examples 
#' \dontrun{
#' sch <- ukbschemas()
#' }
#'
#' @importFrom DBI dbConnect
#' @importFrom parallel detectCores
#' @importFrom RSQLite SQLite


### ukbschemas() ###
#' @export
ukbschemas <- function(
  silent = !interactive(),
  as_is = FALSE,
  url_prefix = UKB_URL_PREFIX,
  sch_id = SCHEMA_FILENAMES[["id"]],
  cache = file.path(Sys.getenv("HOME"), "ukbschemas", "schemas"),
  nThread = detectCores()
){
  
  ## Download Schema Tables ##
  rc <- .get_schemas(
    url_prefix = url_prefix,
    sch_id = sch_id,
    cache = cache,
    nThread = nThread,
    silent = silent
  )
  
  ## Import Schema Tables ##
  sch <- .import_schemas(
    cache = cache,
    nThread = nThread,
    silent = silent
  )
  
  ## Tidy Schemas as Required ##
  if (!as_is) {
    
    sch <- .tidy_schemas(sch, silent = silent)
    
    # Construct dummy sch for column order # - Required?
    db <- dbConnect(SQLite(), ":memory:")
    on.exit(.quiet_dbDisconnect(db))
    .create_tables(db)
    
  } else {
    
    if (!silent) {
      
      message("[downloaded tables added to database as-is]", "\n")
      
    }
    
  }
  
  ## Output ##
  return(sch)
  
}
