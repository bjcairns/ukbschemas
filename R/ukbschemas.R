#' Fetch the UK Biobank data schemas via the internet
#' 
#' `ukbschemas()` loads the UK Biobank data schemas into a list
#' 
#' @param silent Do not report progress. Defaults to `FALSE`.
#' @param overwrite Always overwrite existing files? Helpful for non-interactive 
#' use. Defaults to `FALSE`.
#' @param as_is Import the schemas into the database without tidying? Defaults 
#' to `FALSE`.
#' @param debug Report debugging information (useful when e.g. the structure of 
#' the schema files has changed). Defaults to `FALSE`.
#' 
#' @return A list of objects of class `tbl_df` (see [tibble::tibble]).
#' 
#' @details The UK Biobank data schemas are fetched via the internet. If 
#' `!as_is`, they are tidied. Note that if the table structure has changed 
#' (i.e. has been changed by UK Biobank), then the function may fail partially 
#' or fully. 
#' 
#' @export

ukbschemas <- function(
  silent = !interactive(), 
  overwrite = FALSE,
  as_is = FALSE, 
  debug = FALSE
) {
  
  # Download and tidy (if !as_is) schema tables
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
  
  sch
  
}