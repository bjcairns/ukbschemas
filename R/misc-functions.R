# Confirm that the file and path are OK
.check_file_path <- function(file, path, date_str, overwrite) {
  
  # Catch user attempts to force db creation in memory
  if (file == ":memory:" | file == "file::memory:") {
    file <- NULL
    stop(UKBSCHEMAS_ERRORS$NO_IN_MEMORY)
  }
  
  # Parse file name and path
  if (file == "") file <- paste0("ukb-schemas-", date_str, ".sqlite")
  full_path <- paste0(path.expand(path), "\\", file)
  
  # If `file`` exists, session is `interactive()` and `!overwrite`, then prompt 
  # to overwrite the file
  if (file.exists(full_path)) {
    if (interactive() & !isTRUE(overwrite)) {
      overwrite <- utils::askYesNo(
        "Database file already exists. Overwrite?", 
        default = FALSE
      )
    }
    if (!isTRUE(overwrite)) 
      stop(UKBSCHEMAS_ERRORS$OVERWRITE)
    else tryCatch(
      file.remove(full_path),
      error = function(err) {
        stop(UKBSCHEMAS_ERRORS$FAILED_OVERWRITE)
      },
      warning = function(warn) {
        stop(UKBSCHEMAS_ERRORS$FAILED_OVERWRITE)
      }
    )
  }
  
  full_path
  
}


# Get the schemas from the UK Biobank web server
.get_schemas <- function(
  url_prefix = UKB_URL_PREFIX, 
  files = SCHEMA_FILENAMES,
  delim = "\t",
  quote = "\"",
  silent = TRUE,
  ...
) {
  
  # Read each schema directly from the UK Biobank Data Showcase by ID
  if (silent) {
    on.exit(options(readr.num_columns = getOption("readr.num_columns")))
    options(readr.num_columns = 0)
  }
  
  # Download the files
  sch <- files$id %>% 
    purrr::map(
      ~ {
        readr::read_delim(
          paste0(url_prefix, .), 
          delim = delim, 
          quote = quote,
          ...
        )
      }
    )
  
  names(sch) <- files$filename
  
  invisible(sch)
  
}


# Create and populate the tables in the database
.create_tables <- function(db, as_is = FALSE) {
  
  # Start with a blank slate
  .drop_tables(db)
  
  if (!as_is) {
    
    # CREATE TABLE(s)
    .send_statements(
      db, 
      system.file("sql", "ukb-schemas.sql", package = "ukbschemas")
    )
    
  }
  
  invisible(TRUE)
  
}