#' @importFrom utils askYesNo


# Confirm that the file and path are OK
### .check_file_path() ###
.check_file_path <- function(
  file = "",
  path = ".",
  date_str = Sys.Date(),
  overwrite = FALSE
){
  
  ## Catch User Attempts to Force db Creation in Memory ##
  if (file == ":memory:" | file == "file::memory:") {
    
    stop(UKBSCHEMAS_ERRORS[["NO_IN_MEMORY"]])
    
  }
  
  ## Generate File Name (if Unspecified) ##
  if (file == "") file <- paste0("ukbschemas-", date_str, ".sqlite")
  
  ## Expand Path ##
  path <- normalizePath(path, mustWork = FALSE)
  if (!dir.exists(path)) dir.create(path, showWarnings = FALSE, recursive = TRUE, mode = "0755")
  file_path <- file.path(path, file)
  
  # If `file` exists, session is `interactive()` and `!overwrite`, then prompt 
  # to overwrite the file
  if (file.exists(file_path)) {
    
    if (interactive() & !isTRUE(overwrite)) {
      
      overwrite <- askYesNo(
        msg = "Database file already exists. Overwrite?", 
        default = FALSE
      )
    }
    
    if (!isTRUE(overwrite)) {
      
      stop(UKBSCHEMAS_ERRORS[["OVERWRITE"]])
      
    } else {
      
      # Remove Existing File #
      tryCatch(
        expr = file.remove(file_path),
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
  return(file_path)
  
}
