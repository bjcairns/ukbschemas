#===========#
#           #
#### ZZZ ####
#           #
#===========#

.onLoad <- function(libname, pkgname){
  local({
    path <- file.path(tempdir(), "ukbschemas")
    # if (dir.exists(path)) unlink(x = path, recursive = TRUE, force = TRUE)
    dir.create(path = path, showWarnings = FALSE, recursive = TRUE, mode = "0755")
  })
}
