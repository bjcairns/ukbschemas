#' @importFrom DBI dbConnect dbClearResult dbDisconnect dbIsValid dbListTables dbReadTable dbSendStatement dbWriteTable
#' @importFrom RSQLite SQLite


#############################
### DB CONNECTION HELPERS ###
#############################


# Function to quietly attempt to close a database connection
.quiet_dbDisconnect <- function(db) {
  
  rc <- tryCatch(
    expr = dbDisconnect(db),
    error = function(err) NULL,
    warning = function(warn) NULL
  )
  
  ## Output ##
  return(invisible(rc))
  
}


# Connect to db with error handling
.graceful_dbConnect_db <- function(db) {
  
  if (!dbIsValid(db)) {
    
    rc <- tryCatch(
      expr = dbConnect(db),
      error = function(err) {
        stop(UKBSCHEMAS_ERRORS[["DB_NO_CONNECT"]])
      }
    )
    
  } else {
    
    warning(UKBSCHEMAS_ERRORS[["WARN_DB_CONNECTED"]])
    
  }
  
  ## Output ##
  return(invisible(rc))
  
}


# Connect to db at file
.graceful_dbConnect_file <- function(file) {
  
  if (!is.character(file) | length(file) != 1 | !file.exists(file)) 
    stop(UKBSCHEMAS_ERRORS[["FILE_NOT_EXISTS"]])
  
  rc <- tryCatch(
    expr = dbConnect(SQLite(), file),
    error = function(err) {
      stop(paste0(UKBSCHEMAS_ERRORS[["DB_NO_CONNECT"]], " (", file, ")"))
    }
  )
  
  ## Output ##
  return(invisible(rc))
  
}


###################
### SQL HELPERS ###
###################


# Helper to send statement(s) from an installed SQL file
.send_statements <- function(db, sql_file) {
  
  sql <- readLines(sql_file)
  
  sql <- paste(sql, collapse = "")
  sql <- strsplit(sql, ";", fixed = TRUE)[[1]]
  
  rc <- lapply(
    X = sql,
    FUN = function(x, db){
      dbClearResult(
        dbSendStatement(db, x)
      )
    },
    db = db
  )
  
  ## Output ##
  return(invisible(rc))
  
}


#########################
### TABLE I/O HELPERS ###
#########################


# Helper to clear the database of tables
.drop_tables <- function(db) {
  
  rc <- lapply(
    X = dbListTables(db),
    FUN = function(x, db){
      dbClearResult(
        dbSendStatement(db, paste0("DROP TABLE ", x))
      )
    },
    db = db
  )
  
  ## Output ##
  return(invisible(dbListTables(db) == character()))
  
}


# Write tables from a list of data-frame like objects to a database
.write_tables <- function(tbls, db) {
  
  rc <- mapply(
    FUN = dbWriteTable,
    name = names(tbls),
    value = tbls,
    MoreArgs = list(
      conn = db,
      row.names = FALSE,
      append = TRUE
    )
  )
  
  ## Output ##
  return(invisible(rc))
  
}


# Load tables from a database into a list. This should work with any 
# DBI-compatible connection
.read_tables <- function(db) {
  
  tbl_names <- dbListTables(db)
  
  ## Import Tables ##
  tbls <- lapply(
    X = tbl_names,
    FUN = dbReadTable,
    conn = db
  )
  
  ## Name Output ##
  names(tbls) <- tbl_names
  
  ## Output ##
  return(invisible(tbls))
  
}
