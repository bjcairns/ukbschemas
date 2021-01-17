#' @title
#' Load the UK Biobank data schemas from the Internet or other repository
#' 
#' @param sch_id The id numbers of the schemas to download. Type
#' `SCHEMA_FILENAMES` for reference. Defaults to all.
#' @param sch_path The directory path of the schema download cache. Defaults to
#' `r file.path(tempdir(), "ukbschemas", "schemas")`.
#' @param as_is Import the schemas into the database without tidying? Defaults 
#' to `FALSE`.
#' @param nThread Number of threads to spawn for parallelisable tasks, such as
#' the downloading and importing of the schemas. Defaults to the number of
#' logical cores present on the system.
#' @param silent Do not report progress. Defaults to `FALSE`.
#' 
#' @return
#' A list of objects of class `data.frame`.
#' 
#' @details
#' The UK Biobank data schemas are fetched via the Internet unless a  different
#' `url_prefix` is provided. If `!as_is`, they are tidied. Note that  if the
#' table structure has changed (i.e. has been changed by UK Biobank), then the
#' function may fail partially or fully unless `as_is == TRUE`. 
#'
#' @note
#' This is a convenience function to load the schemas directly from the UK
#' Biobank website. For most purposes, it is recommended to use [ukbschemas_db]
#' and [load_db] instead.
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
  sch_id = SCHEMA_FILENAMES[["id"]],
  sch_path = file.path(tempdir(), "ukbschemas", "schemas"),
  as_is = FALSE,
  nThread = detectCores(),
  silent = !interactive()
){
  
  ## Download Schema Tables ##
  rc <- .get_schemas(
    sch_id = sch_id,
    sch_path = sch_path,
    nThread = nThread,
    silent = silent
  )
  
  ## Import Schema Tables ##
  sch <- .import_schemas(
    sch_path = sch_path,
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
