#===========#
#           #
#### ZZZ ####
#           #
#===========#


### .onLoad() ###
.onLoad <- function(libname, pkgname){
  local({
    path <- file.path(tempdir(), "ukbschemas")
    dir.create(path = path, showWarnings = FALSE, recursive = TRUE, mode = "0755")
  })
}
