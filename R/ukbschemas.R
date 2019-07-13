#' @export

ukbschemas <- function(
  silent = !interactive(), 
  debug = FALSE, 
  overwrite = FALSE,
  as_is = FALSE
) {
  
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
  
  sch
  
}