#' Load the UK Biobank data schemas from the Internet or other repository
#' 
#' \bold{Note:} this is a convenience function to load the schemas directly 
#' from the UK Biobank website. For most purposes, it is recommended to use 
#' [ukbschemas_db] and [load_db] instead.
#' 
#' @param silent Do not report progress. Defaults to `FALSE`.
#' @param as_is Import the schemas into the database without tidying? Defaults 
#' to `FALSE`.
#' @param url_prefix First part of the URL at which the schema files can be 
#' found. For local repositories, the directory with a trailing delimiter (i.e.
#' `/` or `\\` or `\\\\` as appropriate to your operating system).
#' 
#' @return A list of objects of class `tbl_df` (see [tibble::tibble]).
#' 
#' @details The UK Biobank data schemas are fetched via the Internet unless a 
#' different `url_prefix` is provided. If `!as_is`, they are tidied. Note that 
#' if the table structure has changed (i.e. has been changed by UK Biobank), 
#' then the function may fail partially or fully unless `as_is == TRUE`. 
#' 
#' @examples 
#' \dontrun{
#' sch <- ukbschemas()
#' }
#' @export

ukbschemas <- function(
  silent = !interactive(), 
  as_is = FALSE,
  url_prefix = UKB_URL_PREFIX
) {
  
  # Download schema tables
  sch <- .get_schemas(url_prefix = url_prefix, quote = "", silent = silent)
  if (!silent) {
    cat("Downloaded tables:\n")
    cat(paste(names(sch), collapse = ", "))
    cat("\n\n")
  }
  
  # Tidy schemas as required
  if (!as_is) {
    
    sch <- .tidy_schemas(sch, silent = silent)
    
    # Construct dummy sch for column order
    db <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
    on.exit(.quiet_dbDisconnect(db))
    .create_tables(db)
    dummy_sch <- load_db(db = db)
    
    # Fix column order
    sch_names <- names(sch)
    sch <- sch_names %>% 
      purrr::map(
        ~ sch[[.x]][names(dummy_sch[[.x]])]
      )
    names(sch) <- sch_names
    
  }
  else {
    
    if (!silent) {
      cat("[downloaded tables added to database as-is]\n\n")
    }
    
  }
  
  # Sort schemas
  sch <- sch[sort(names(sch))]
  
  sch
  
}
