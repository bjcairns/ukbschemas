## DB CONNECTION HELPERS

# Function to quietly attempt to close a database connection
.quiet_dbDisconnect <- function(db) {
  
  tryCatch(
    DBI::dbDisconnect(db),
    error = function(err) NULL,
    warning = function(warn) NULL
  )
  
  invisible(TRUE)
}

# Connect to db with error handling
.graceful_dbConnect_db <- function(db) {
  
  if (!DBI::dbIsValid(db)) {
    tryCatch(
      db <- DBI::dbConnect(db),
      error = function(err) {
        stop(UKBSCHEMAS_ERRORS$DB_NO_CONNECT)
      }
    )
  } else warning(UKBSCHEMAS_ERRORS$WARN_DB_CONNECTED)
  
  invisible(db)
}

# Connect to db at file
.graceful_dbConnect_file <- function(file) {
  
  if (!is.character(file) | length(file) != 1 | !file.exists(file)) 
    stop(UKBSCHEMAS_ERRORS$FILE_NOT_EXISTS)
  
  tryCatch(
    db <- DBI::dbConnect(RSQLite::SQLite(), file),
    error = function(err) {
      stop(paste0(UKBSCHEMAS_ERRORS$DB_NO_CONNECT, " (", file, ")"))
    }
  )
  
  invisible(db)
}


## SQL HELPERS

# Helper to send statement(s) from an installed SQL file
.send_statements <- function(db, sql_file) {
  
  sql <- readr::read_file(sql_file)
  
  sql <- unlist(strsplit(sql, ";", fixed = TRUE)) %>% 
    purrr::map_chr(~ gsub("[\r\n]", "", .x))
  
  sql[sql != ""] %>%
    purrr::walk(
      ~ DBI::dbClearResult(
        DBI::dbSendStatement(db, .x)
      )
    )
  
  invisible(TRUE)
  
}


## TABLE I/O HELPERS

# Helper to clear the database of tables
.drop_tables <- function(db) {
  
  DBI::dbListTables(db) %>% 
    purrr::map(~ {
      DBI::dbClearResult(
        DBI::dbSendStatement(db, paste0("DROP TABLE ", .x))
      )
    })
  
  invisible(DBI::dbListTables(db) == character())
}

# Write tables from a list of data-frame like objects to a database
.write_tables <- function(tbls, db) {
 
  purrr::walk2(
    tbls,
    names(tbls),
    ~ RSQLite::dbWriteTable(conn = db, name = .y, value = .x,
                            row.names = FALSE, append = TRUE)
  )
  
  invisible(TRUE)
  
}

# Load tables from a database into a list. This should work with any 
# DBI-compatible connection
.read_tables <- function(db) {
  
  tbl_names <- DBI::dbListTables(db)
  
  tbls <- tbl_names %>%
    purrr::map(
      ~ tibble::as_tibble(DBI::dbReadTable(db, .x))
    )
  
  names(tbls) <- tbl_names
  
  invisible(tbls)
}
