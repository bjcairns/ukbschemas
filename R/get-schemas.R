#' @importFrom magrittr "%>%"

.get_schemas <- function(
  url_prefix = UKB_URL_PREFIX, 
  files = SCHEMA_FILENAMES,
  debug = FALSE,
  delim = "\t",
  quote = "\"",
  ...
) {
  
  if (!debug) options(readr.num_columns = 0)

  sch <- files$id %>% 
    purrr::map(
      ~ {
        readr::read_delim(
          paste0(url_prefix, .), 
          delim = delim, 
          quote = quote,
          ...
        )
      }
    )
  names(sch) <- files$filename
  sch

}
