# Help to tidy up the schemas
### .tidy_schemas() ###
.tidy_schemas <- function(sch, silent = FALSE) {
  
  if (!silent) message("Tidying:")
  
  # Add the missing valuetypes table
  sch <- append(
    sch,
    list(
      valuetypes = VALUE_TYPES,
      stability = STABILITY,
      itemtypes = ITEM_TYPES,
      strata = STRATA,
      sexed = SEXED
    )
  )
  if (!silent) message("... Added property type tables")
  
  # Rename columns as needed
  vars <- c("value_type", "stability", "item_type", "strata", "sexed")
  names(sch[["fields"]])[match(vars, names(sch[["fields"]]))] <- paste(vars, "id", sep = "_")
  names(sch[["fields"]])[names(sch[["fields"]]) == "main_category"] <- "category_id"
  
  names(sch[["encodings"]])[names(sch[["encodings"]]) == "coded_as"] <- "value_type_id"
  if (!silent) {
    message("... Rename coded properties in tables: `fields` and `encodings`")
  }
  
  # Add parent_id column to categories
  sch[["categories"]] <- merge(
    x = sch[["categories"]],
    y = sch[["catbrowse"]],
    by.x = "category_id",
    by.y = "child_id",
    all.x = TRUE
  )
  rownames(sch[["categories"]]) <- seq.int(nrow(sch[["categories"]]))
  sch["catbrowse"] <- NULL
  if (!silent) {
    message("... Add parent_id from `catbrowse` to `categories` (delete former)")
  }
  
  # Identify esimp* and ehier* tables
  is_esimp_table <- grepl("^esimp", names(sch))
  is_ehier_table <- grepl("^ehier", names(sch))
  
  # Add columns to esimp* tables
  # value is converted to character after recording the (R) class as type
  # code_id is generated as the position within encoding_id for harmonisation
  sch[is_esimp_table] <- lapply(
    X = sch[is_esimp_table],
    FUN = .format_esimp
  )
  
  # Add columns to ehier* tables
  # As with the esimp* tables, type records the (R) class of value
  sch[is_ehier_table] <- lapply(
    X = sch[is_ehier_table],
    FUN = .format_eheir
  )
  
  if (!silent) {
    message("... Harmonise `esimp*` and `ehier*` tables to add to `encvalues`")
  }
  
  # bind all the encoding values tables together and delete
  encvalues <- do.call(rbind, sch[is_esimp_table | is_ehier_table])
  sch[is_esimp_table | is_ehier_table] <- NULL
  sch[["encvalues"]] <- encvalues
  rownames(sch[["encvalues"]]) <- seq.int(nrow(sch[["encvalues"]]))
  
  if (!silent) {
    message("... Bind `esimp*` and `ehier*` tables into `encvalues`")
    cat("\n\n")
    message("Tables after tidying:")
    message(paste(names(sch), collapse = ", "), "\n")
  }
  
  ## Sort schemas ##
  sch <- sch[sort(names(sch))]
  
  ## Output ##
  return(sch)
}


### .format_esimp() ###
.format_esimp <- function(dat){
  
  ## Data Management ##
  dat[c("parent_id", "selectable")] <- NA_integer_
  dat[["type"]] <- class(dat[["value"]])[1]
  dat[["value"]] <- as.character(dat[["value"]])
  
  # Row Number by Group #
  code_id <- unlist(
    tapply(
      X = seq.int(nrow(dat)),
      INDEX = dat[["encoding_id"]],
      FUN = seq_along,
      simplify = FALSE
    )
  )
  names(code_id) <- NULL
  dat[["code_id"]] <- code_id
  
  ## Output ##
  return(dat)
  
}


### .format_eheir() ###
.format_eheir <- function(dat){
  
  ## Data Management ##
  dat[["type"]] <- class(dat[["value"]])[1]
  dat[["value"]] <- as.character(dat[["value"]])
  
  ## Output ##
  return(dat)
  
}
