#' @importFrom data.table fread
#' @importFrom parallel detectCores
#' @importFrom readr read_delim


### .import_schemas() ###
.import_schemas <- function(
  sch_path = file.path(Sys.getenv("HOME"), "ukbschemas", "schemas"),
  nThread = detectCores(),
  silent = TRUE,
  ...
){
  
  ## Schema File Names ##
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
  sch <- list()
  for (i in seq_along(schemas)) {
    sch[[i]] <- .tryRead(
      file = schemas[i],
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
      ...
    )  
  }
  
  ## Coerce IDates to Dates ##
  sch <- lapply(
    X = sch,
    FUN = .IDateToDate
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


### .tryRead() - read a UKB schema with error handling/fallback
.tryRead <- function(
  file,
  sep = "\t",
  quote = "",
  header = TRUE,
  na.strings = c("", "NA"),
  verbose = FALSE,
  blank.lines.skip = TRUE,
  showProgress = FALSE,
  data.table = FALSE,
  nThread = detectCores(),
  logical01 = FALSE,
  ...
) {
  
  silent <- !showProgress
  
  ## Import This Schema ##
  this_sch_and_warning <- tryCatch(
    
    ## Attempt to use data.table
    withCallingHandlers(
      
      {
        warn_text <- NA_character_
        
        list(
          this_sch = fread(
            file = file,
            sep = sep,
            quote = quote,
            header = header,
            na.strings = na.strings,
            integer64 = "double",
            verbose = verbose,
            blank.lines.skip = blank.lines.skip,
            showProgress = showProgress,
            data.table = data.table,
            nThread = nThread,
            logical01 = logical01
          ),
          warn = warn_text
        )
      },
      
      ## If there was a warning, capture it and continue
      ## Trick from https://r.789695.n4.nabble.com/Resume-processing-after-warning-handler-td4357217.html
      ## via https://stackoverflow.com/a/49829161
      warning = function(warn) {
        
        warn_text <<- warn
        invokeRestart("muffleWarning")
        
      }
    ),
    
    ## If there was an error, also fall back to readr
    error = function(err) {
      if (!silent) message(UKBSCHEMAS_ERRORS[["WARN_FREAD_FAIL"]])
      return(list(this_sch = NULL, warn_text = NA_character_))
    }
  )
  
  this_sch <- this_sch_and_warning[["this_sch"]]
  warn <- this_sch_and_warning[["warn"]]
  
  ## Check if fread might have stopped early, and report warnings as needed
  if (!is.null(this_sch) & grepl("Stopped early", as.character(warn))) {
    if (!silent) {
      message(paste0(
        UKBSCHEMAS_ERRORS[["WARN_FREAD_STOP_EARLY"]], 
        "\n  (in ", file, ")"
      ))
    }
    this_sch <- NULL
  } else if (!is.na(warn)) {
    warning(warn)
  }
  
  # If at this point this_sch is NULL, fall back to try readr::read_delim
  if (is.null(this_sch)) {
    
    this_sch <- suppressMessages(
      .readrFallback(
        file = file,
        delim = sep,
        quote = quote,
        na = na.strings,
        skip_empty_rows = blank.lines.skip,
        progress = showProgress
      )
    )
    
  }
  
  return(this_sch)
}


### .readrFallback() ###
.readrFallback <- function(
  file,
  delim = "\t",
  quote = "",
  na = c("", "NA"),
  skip_empty_rows = TRUE,
  progress = TRUE
) {
  tryCatch(
    expr = {
      ## Import ##
      this_sch <- read_delim(
        file = file, 
        delim = delim,
        quote = quote,
        na = na,
        skip_empty_rows = skip_empty_rows,
        progress = progress
      )
      
      ## Coerce & Strip readr Attributes ##
      this_sch <- as.data.frame(this_sch)
      attributes(this_sch) <- attributes(this_sch)[c("names", "class", "row.names")]
      this_sch
    },
    error = function(err) {
      stop(UKBSCHEMAS_ERRORS[["SCH_READ_ERROR"]])
    }
  )
  
  return(this_sch)
}


### .IDateToDate() ###
.IDateToDate <- function(data){
  
  ### Variables ###
  vars <- names(data)
  
  ### IDate Variables ###
  vars_IDate <- vapply(
    X = data,
    FUN = .isIDate,
    FUN.VALUE = logical(1L)
  )
  vars_IDate <- vars[vars_IDate]
  
  ## Coerce IDates to Dates ##
  data[vars_IDate] <- lapply(
    X = data[vars_IDate],
    FUN = as.Date
  )
  
  ### Output ###
  return(data)
  
}


### .isIDate() ###
.isIDate <- function(x){
  
  isIDate <- "IDate" %in% class(x)
  
  ## Output ##
  return(isIDate)
  
}