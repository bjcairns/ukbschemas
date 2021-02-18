#' @importFrom parallel detectCores
#' @importFrom utils askYesNo


### Notes ###
# - Alternatives to `lsof`: https://unix.stackexchange.com/questions/18614/alternatives-for-lsof-command


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
