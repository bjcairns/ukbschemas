#' @importFrom data.table fread
#' @importFrom readr read_delim
#' @importFrom parallel detectCores mcmapply
#' @importFrom utils askYesNo download.file

### Notes ###
# - Alternatives to `lsof`: https://unix.stackexchange.com/questions/18614/alternatives-for-lsof-command


### .autoISOdate() ###
.autoISOdate <- function(data){
  
  ## Variables ##
  vars <- names(data)
  
  ## Character Variables ##
  vars_char <- vapply(
    X = data,
    FUN = is.character,
    FUN.VALUE = logical(1L)
  )
  vars_char <- vars[vars_char]
  
  ## ISO Date Variables ##
  vars_date <- vapply(
    X = data[vars_char],
    FUN = .isISOdate,
    FUN.VALUE = logical(1L)
  )
  vars_date <- vars_char[vars_date]
  
  ## Coerce to Date ##
  data[, vars_date] <- lapply(
    X = data[vars_date],
    FUN = as.Date,
    format = "%Y-%m-%d"
  )
  
  ## Output ##
  return(data)
  
}


# Confirm that the file and path are OK
### .check_file_path() ###
.check_file_path <- function(file, path, date_str, overwrite) {
  
  ## Catch User Attempts to Force db Creation in Memory ##
  if (file == ":memory:" | file == "file::memory:") {
    
    file <- NULL
    stop(UKBSCHEMAS_ERRORS[["NO_IN_MEMORY"]])
    
  }
  
  # Parse file name and path
  if (file == "") file <- paste0("ukbschemas-", date_str, ".sqlite")
  
  ## Expand Path ##
  full_path <- file.path(path.expand(path), file)
  
  # If `file` exists, session is `interactive()` and `!overwrite`, then prompt 
  # to overwrite the file
  if (file.exists(full_path)) {
    
    if (interactive() & !isTRUE(overwrite)) {
      
      overwrite <- askYesNo(
        msg = "Database file already exists. Overwrite?", 
        default = FALSE
      )
    }
    
    if (!isTRUE(overwrite)) {
      
      stop(UKBSCHEMAS_ERRORS[["OVERWRITE"]])
      
    } else {
      
      # Stop Active Databases & Remove #
      tryCatch(
        expr = {
          if (.Platform[["OS.type"]] == "unix") {
            
            if (!.inPATH("lsof"))
              stop("'lsof' must be installed on Unix-like systems to check db connections.")
            
            sys_command <- paste("lsof", full_path, "| wc -l")
            processes_using_file <- system(
              command = sys_command,
              intern = TRUE,
              ignore.stdout = FALSE,
              ignore.stderr = TRUE
            )
            processes_using_file <- as.integer(processes_using_file) - 1L
            processes_using_file <- max(processes_using_file, 0L)
            
            if (processes_using_file > 1) {
              
              stop(UKBSCHEMAS_ERRORS[["FAILED_OVERWRITE"]])
              
            }
            
          }
          
          # Remove SQL Database #
          file.remove(full_path)
        },
        error = function(err) {
          stop(UKBSCHEMAS_ERRORS[["FAILED_OVERWRITE"]])
        },
        warning = function(warn) {
          stop(UKBSCHEMAS_ERRORS[["FAILED_OVERWRITE"]])
        }
      )
      
    }
  }
  
  ## Output ##
  return(full_path)
  
}


# Get the schemas from the UK Biobank web server
### .get_schemas() ###
.get_schemas <- function(
  sch_id = SCHEMA_FILENAMES[["id"]],
  sch_path = file.path(tempdir(), "ukbschemas", "schemas"),
  nThread = detectCores(),
  silent = FALSE
) {
  
  ## Checks ##
  if (any(!{sch_id %in% c(1:18, 999L)}))
    stop("One or more schema IDs does not exist")
  
  ## Create TempDir ##
  dir.create(sch_path, showWarnings = FALSE, recursive = TRUE, mode = "0755")
  
  ## Subset Schema Table ##
  schemas <- SCHEMA_FILENAMES[SCHEMA_FILENAMES[["id"]] %in% sch_id, ]
  
  ## Schemas to Download ##
  schema_destfile <- file.path(sch_path, paste(schemas[["filename"]], "tsv", sep = "."))
  schema_url <- paste0(UKB_URL_PREFIX, schemas[["id"]])
  ind <- which(!file.exists(file.path(schema_destfile)))
  schema_destfile <- schema_destfile[ind]
  schema_url <- schema_url[ind]
  
  ## Download Schemas ##
  rc <- if (.Platform[["OS.type"]] == "unix") {
    
    mcmapply(
      FUN = download.file,
      url = schema_url,
      destfile = schema_destfile,
      MoreArgs = list(
        method = if (capabilities("libcurl")) "libcurl" else "auto",
        quiet = silent,
        mode = "w",
        cacheOK = FALSE
      ),
      SIMPLIFY = FALSE,
      mc.cores = nThread
    )
    
  } else {
    
    mapply(
      FUN = download.file,
      url = schema_url,
      destfile = schema_destfile,
      MoreArgs = list(
        method = if (capabilities("libcurl")) "libcurl" else "auto",
        quiet = silent,
        mode = "w",
        cacheOK = FALSE
      ),
      SIMPLIFY = FALSE
    )
    
  }
  
  ## Check Download Success Return Codes ##
  rc <- as.integer(unlist(rc))
  if (length(rc) != 0L)
    if (!all(rc == 0L))
      warning(UKBSCHEMAS_ERRORS[["WARN_SCH_DOWNLOAD"]])
  
  ## Verbosity ##
  if (!silent) {
    
    if (length(schemas[["filename"]][rc == 0L]) != 0L){
      
      message("Downloaded tables:")
      message(paste(schemas[["filename"]][rc == 0L], collapse = ", "), "\n")
      
    }
    
  }
  
  ## Output ##
  return(invisible(rc))
  
}


### .import_schemas() ###
.import_schemas <- function(
  sch_path = file.path(tempdir(), "ukbschemas", "schemas"),
  nThread = detectCores(),
  silent = TRUE,
  ...
){
  
  ## Schema Filenames ##
  schemas <- SCHEMA_FILENAMES[["filename"]]
  schemas <- paste(schemas, collapse = "|")
  schemas <- paste0("^(", schemas, ").tsv$")
  schemas <- list.files(pattern = schemas, path = sch_path, full.names = TRUE)
  
  ## Checks ##
  if (length(schemas) == 0L)
    stop("Schemas not located on system")
  
  ## Parallelisation ##
  nThread <- min(nThread, length(schemas))
  
  ## Import Schemas ##
  sch <- lapply(
    X = schemas,
    FUN = .tryRead,
    sep = "\t",
    quote = "",
    header = TRUE,
    na.strings = c("", "NA"),
    verbose = FALSE,
    blank.lines.skip = TRUE,
    showProgress = !silent,
    data.table = FALSE,
    nThread = nThread,
    logical01 = FALSE,
    keepLeadingZeros = TRUE,
    ...
  )
  
  ## Coerce Dates ##
  sch <- lapply(
    X = sch,
    FUN = .autoISOdate
  )
  
  ## Name Schemas ##
  names(sch) <- sub("\\.tsv$", "", basename(schemas))
  
  ## Sort schemas ##
  sch <- sch[sort(names(sch))]
  
  ## Verbosity ##
  if (!silent) {
    
    message("Imported tables:")
    message(paste(names(sch), collapse = ", "), "\n")
    
  }
  
  ## Output ##
  return(sch)
  
}


### .inPATH() ###
.inPATH <- function(prog){
  
  ## Look For Command in PATH ##
  command <- suppressWarnings(
    system(
      command = paste("command -v", prog),
      ignore.stdout = TRUE,
      ignore.stderr = TRUE,
      intern = TRUE
    )
  )
  
  ## Check Presence of Return Code ##
  rc <- attributes(command)[["status"]]
  inPATH <- if (is.null(rc)) TRUE else FALSE
  
  ## Output ##
  return(inPATH)
  
}


### .isISOdate() ###
.isISOdate <- function(x){
  
  ## Pattern Match ##
  isDate <- all(
    grepl("^\\d{4}-\\d{2}-\\d{2}$", x, perl = TRUE)
  )
  
  ## Output ##
  return(isDate)
  
}

.tryRead <- function(
  x, 
  sep = "\t",
  quote = "",
  header = TRUE,
  na.strings = c("", "NA"),
  verbose = FALSE,
  blank.lines.skip = TRUE,
  showProgress = TRUE,
  data.table = FALSE,
  nThread = detectCores(),
  logical01 = FALSE,
  keepLeadingZeros = TRUE,
  ...) {
  
  ## Import Schemas ##
  this_sch <- tryCatch(
    expr = {
      this_sch <- fread(
        x,
        sep = sep,
        quote = quote,
        header = header,
        na.strings = na.strings,
        verbose = verbose,
        blank.lines.skip = blank.lines.skip,
        showProgress = showProgress,
        data.table = data.table,
        nThread = nThread,
        logical01 = logical01,
        keepLeadingZeros = keepLeadingZeros
      )
    }, 
    warning = function(warn) {
      if (grepl("Stopped early", warn$message)) {
        warning(paste0(
          UKBSCHEMAS_ERRORS[["WARN_FREAD_STOP_EARLY"]], 
          "\n  (in ", x, ")"
        ))
        tryCatch(
          expr = {
            this_sch <- as.data.frame(read_delim(
              x, 
              delim = sep,
              quote = quote,
              na = na.strings,
              skip_empty_rows = blank.lines.skip,
              progress = showProgress
            ))
          },
          error = function(err) {
            stop(UKBSCHEMAS_ERRORS[["SCH_READ_ERROR"]])
          }
        )
      }
    },
    error = function(err) {
      warning(UKBSCHEMAS_ERRORS[["WARN_FREAD_FAIL"]])
      tryCatch(
        expr = {
          this_sch <- as.data.frame(readr::read_delim(
            x, 
            delim = sep,
            quote = quote,
            na = na.strings,
            skip_empty_rows = blank.lines.skip,
            progress = showProgress
          ))
        },
        error = function(err) {
          stop(UKBSCHEMAS_ERRORS[["SCH_READ_ERROR"]])
        }
      )
    }
  )
  
  return(this_sch)
}
