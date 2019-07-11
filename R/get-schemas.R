#' @importFrom magrittr "%>%"

.get_schemas <- function(
  url_prefix = UKB_URL_PREFIX, 
  files = SCHEMA_FILENAMES,
  debug = FALSE,
  delim = "\t",
  quote = "\"",
  ...
) {
  
  # Unless in debug mode, do not output tbl summaries when reading schemas 
  # from file
  if (!debug) options(readr.num_columns = 0)

  # Read each schema directly from the UK Biobank Data Showcase by ID
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
  
  # Name the tables
  names(sch) <- files$filename
  
  sch

}
