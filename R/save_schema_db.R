#' Save a list of UK Biobank data schemas to an SQLite database
#' 
#' @export

save_schemas_db <- function(
  sch, 
  file = "", 
  path = ".", 
  date_str = Sys.Date(), 
  silent = !interactive(), 
  overwrite = FALSE,
  as_is = FALSE
) {
  
  # Confirm file/path and remove if overwrite
  full_path <- .check_file_path(file, path, date_str, overwrite)
  
  # Create database
  on.exit(.quiet_dbDisconnect(db))
  tryCatch(
    db <- DBI::dbConnect(RSQLite::SQLite(), full_path),
    error = function(err) {
      stop(UKBSCHEMAS_ERRORS$DB_NO_CONNECT)
    }
  )
  
  # Populate database
  tryCatch(
    .create_tables(db, sch, silent = silent, as_is = as_is),
    error = function(err) {
      stop(UKBSCHEMAS_ERRORS$DB_POPULATE_ERROR)
    }
  )
  
  # Wrap up and (extra careful) close the connection
  if (!silent) print(db)
  suppressWarnings(DBI::dbDisconnect(db))
  if (!silent) cat("...DISCONNECTED\n")
  
  db
  
}