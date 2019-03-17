#' @importFrom magrittr "%>%"

get_schemas <- function(url_prefix = UKB_URL_PREFIX, 
                         files = SCHEMA_FILENAMES) 
{

    sch <- files$id %>% 
      purrr::map(
        ~ readr::read_delim(paste0(url_prefix, .), delim = "\t")
      )
    names(sch) <- files$filename
    sch

}
