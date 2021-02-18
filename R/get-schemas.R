#' @importFrom parallel detectCores mcmapply
#' @importFrom utils download.file


# Get the schemas from the UK Biobank web server
### .get_schemas() ###
.get_schemas <- function(
  url_prefix = UKB_URL_PREFIX,
  sch_id = SCHEMA_FILENAMES[["id"]],
  sch_path = file.path(Sys.getenv("HOME"), "ukbschemas", "schemas"),
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
  schema_url <- paste0(url_prefix, schemas[["id"]])
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