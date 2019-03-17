#' @importFrom magrittr "%>%"

.create_tables <- function(db, sch) {
  
  purrr::walk2(
    sch,
    names(sch), 
    ~ dplyr::copy_to(dest = db, df = .x, name = .y,
                     temporary = FALSE, overwrite = TRUE)
  )
  
  db

}