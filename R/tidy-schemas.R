# Help to tidy up the schemas
### .tidy_schemas() ###
.tidy_schemas <- function(sch, silent = FALSE) {
  
  ## Verbosity ##
  if (!silent) message("Tidying:")
  
  ## Add the Missing Tables ##
  if (!silent) message("... Add property type tables")
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
  
  ## Rename Columns - as Needed ##
  if (!silent) {
    message("... Rename coded properties in tables: `fields` and `encodings`")
  }
  vars <- c("value_type", "stability", "item_type", "strata", "sexed")
  names(sch[["fields"]])[match(vars, names(sch[["fields"]]))] <- paste(vars, "id", sep = "_")
  names(sch[["fields"]])[names(sch[["fields"]]) == "main_category"] <- "category_id"
  
  names(sch[["encodings"]])[names(sch[["encodings"]]) == "coded_as"] <- "value_type_id"
  
  # Add parent_id column to categories
  if (!silent) {
    message("... Add parent_id from `catbrowse` to `categories` (delete former)")
  }
  sch[["categories"]] <- merge(
    x = sch[["categories"]],
    y = sch[["catbrowse"]],
    by.x = "category_id",
    by.y = "child_id",
    all.x = TRUE
  )
  rownames(sch[["categories"]]) <- seq.int(nrow(sch[["categories"]]))
  sch["catbrowse"] <- NULL
  
  ## Harmonize esimp & ehier Tables ##
  if (!silent) {
    message("... Harmonise `esimp*` and `ehier*` tables to add to `encvalues`")
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
  
  # bind all the encoding values tables together and delete
  if (!silent) {
    message("... Bind `esimp*` and `ehier*` tables into `encvalues`")
  }
  encvalues <- do.call(rbind, sch[is_esimp_table | is_ehier_table])
  sch[is_esimp_table | is_ehier_table] <- NULL
  sch[["encvalues"]] <- encvalues
  rownames(sch[["encvalues"]]) <- seq.int(nrow(sch[["encvalues"]]))
  
  # Harmonize the recordtab and recordcol tables with each other and the rest
  if (!silent) {
    message("... Harmonise and tidy `recordtab` and `recordcol`")
  }
  names(sch[["recordtab"]])[names(sch[["recordtab"]]) == "record_field_id"] <- "field_id"
  names(sch[["recordcol"]])[names(sch[["recordcol"]]) == "value_type"] <- "value_type_id"
  recordtab_tables <- sch[["recordtab"]][["table_name"]]
  recordcol_tables <- unique(sch[["recordcol"]][["table_name"]])
  missing_tables <- recordcol_tables[!(recordcol_tables %in% recordtab_tables)]
  recordtab_rows <- dim(sch[["recordtab"]])[1]
  for (tbl in missing_tables) {
    sch[["recordtab"]][recordtab_rows + 1, 1] <- tbl
    recordtab_rows <- recordtab_rows + 1
  }
  sch[["recordtab"]][["parent_name"]] <- as.character(sch[["recordtab"]][["parent_name"]])
  sch[["recordcol"]][["units"]] <- as.character(sch[["recordcol"]][["units"]])
  
  ## Table Summary ##
  if (!silent) {
    cat("\n\n")
    message("Tables after tidying:")
    message(paste(names(sch), collapse = ", "), "\n")
  }
  
  ## Sort Schemas ##
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
