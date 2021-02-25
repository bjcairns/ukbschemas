# Help to tidy up the schemas
### .tidy_schemas() ###
.tidy_schemas <- function(sch, silent = FALSE) {
  
  ## Verbosity ##
  if (!silent) message("Tidying:")
  
  ## Add the Missing Tables ##
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
  
  ## Rename Columns ##
  # 'fields' & 'encodings' #
  sch <- .tidy_fields_encodings(sch = sch, silent = silent)
  
  ## Add `parent_id` Column to Categories ##
  # 'categories' & 'catbrowse' #
  sch <- .tidy_categories_catbrowse(sch = sch, silent = silent)
  
  ## Harmonize esimp & ehier Tables ##
  # 'esimp*' & 'eheir*' #
  sch <- .tidy_esimp_eheir(sch = sch, silent = silent)
  
  ## Harmonize the recordtab and recordcol tables with each other and the rest ##
  # 'recordtab' & 'recordcol' #
  sch <- .tidy_recordcol_recordtab(sch = sch, silent = silent)
  
  ## Table Summary ##
  if (!silent) {
    sch_all <- paste0("'", names(sch), "'")
    sch_all <- paste(sch_all, collapse = ", ")
    cat("\n")
    message("Tables after tidying:")
    message(sch_all)
  }
  
  ## Sort Schemas ##
  sch <- sch[sort(names(sch))]
  
  ## Output ##
  return(sch)
}


### .tidy_fields_encodings() ###
.tidy_fields_encodings <- function(sch, silent = FALSE){
  
  ## Schemas ##
  sch_fld <- names(sch)[names(sch) %in% "fields"]
  sch_enc <- names(sch)[names(sch) %in% "encodings"]
  sch_all <- c(sch_fld, sch_enc)
  
  ## `fields` ##
  if (length(sch_fld) != 0L) {
    
    # Coding #
    vars <- c("value_type", "stability", "item_type", "strata", "sexed")
    names(sch[["fields"]])[match(vars, names(sch[["fields"]]))] <- paste(vars, "id", sep = "_")
    names(sch[["fields"]])[names(sch[["fields"]]) == "main_category"] <- "category_id"
    
  }
  
  ## `encodings` ##
  if (length(sch_enc) != 0L) {
    
    # Coding #
    names(sch[["encodings"]])[names(sch[["encodings"]]) == "coded_as"] <- "value_type_id"
    
  }
  
  ## Verbosity ##
  if (!silent){
    
    if (length(sch_all) != 0L){
      
      sch_all <- paste0("'", sch_all, "'")
      sch_all <- paste(sch_all, collapse = " and ")
      msg <- paste("... Renamed coded properties in tables:", sch_all)
      message(msg)
      
    }
    
  }
  
  ## Output ##
  return(sch)
  
}


### .tidy_categories_catbrowse() ###
.tidy_categories_catbrowse <- function(sch, silent = FALSE){
  
  ## Schemas ##
  sch_cat <- names(sch)[names(sch) %in% c("categories", "catbrowse")]
  
  if (length(sch_cat) == 2L) {
    
    sch[["categories"]] <- merge(
      x = sch[["categories"]],
      y = sch[["catbrowse"]],
      by.x = "category_id",
      by.y = "child_id",
      all.x = TRUE
    )
    rownames(sch[["categories"]]) <- seq.int(nrow(sch[["categories"]]))
    sch["catbrowse"] <- NULL
    
    ## Verbosity ##
    if (!silent)
      message("... Added `parent_id` from 'catbrowse' to 'categories' (delete former)")
    
  }
  
  ### Output ###
  return(sch)
  
}


### .tidy_esimp_eheir() ###
.tidy_esimp_eheir <- function(sch, silent = FALSE){
  
  ## Schemas ##
  sch_esimp <- grep("^esimp[[:lower:]]+$", names(sch), value = TRUE)
  sch_ehier <- grep("^ehier[[:lower:]]+$", names(sch), value = TRUE)
  sch_all <- c(sch_esimp, sch_ehier)
  
  ## Verbosity ##
  sch_out <- c()
  
  ## Harmonose 'esimp*' & 'ehier*' Tables ##
  # 'esimp*' #
  if (length(sch_esimp) != 0L) {
    
    # Verbosity #
    sch_out <- c(sch_out, "esimp*")
    
    # Add columns to esimp* tables
    # value is converted to character after recording the (R) class as type
    # code_id is generated as the position within encoding_id for harmonisation
    sch[sch_esimp] <- lapply(
      X = sch[sch_esimp],
      FUN = .format_esimp
    )
    
  }
  
  # 'ehier*' #
  if (length(sch_ehier) != 0L){
    
    # Verbosity #
    sch_out <- c(sch_out, "ehier*")
    
    # Add columns to ehier* tables
    # As with the esimp* tables, type records the (R) class of value
    sch[sch_ehier] <- lapply(
      X = sch[sch_ehier],
      FUN = .format_ehier
    )
    
  }
  
  ## Bind All the Encoding Values Tables Together & Delete ##
  # 'esimp*' & # 'ehier*' # #
  if (length(sch_all) != 0L) {
    
    encvalues <- do.call(rbind, sch[sch_all])
    rownames(encvalues) <- seq.int(nrow(encvalues))
    sch[sch_all] <- NULL
    sch[["encvalues"]] <- encvalues
    
    # Verbosity #
    if (!silent) {
      
      sch_out <- paste0("'", sch_out, "'")
      sch_out <- paste(sch_out, collapse = " and ")
      msg <- paste("... Harmonised", sch_out, "tables to add to 'encvalues'")
      message(msg)
      msg <- paste("... Bound", sch_out, "tables into 'encvalues'")
      message(msg)
      
    }
      
    
  }
  
  ## Output ##
  return(sch)
  
}


### .tidy_recordcol_recordtab() ###
.tidy_recordcol_recordtab <- function(sch, silent = FALSE){
  
  ## Schemas ##
  sch_rc <- names(sch)[names(sch) %in% "recordcol"]
  sch_rt <- names(sch)[names(sch) %in% "recordtab"]
  sch_all <- c(sch_rc, sch_rt)
  
  # 'recordcol' #
  if (length(sch_rc) != 0L) {
    
    names(sch[["recordcol"]])[names(sch[["recordcol"]]) == "value_type"] <- "value_type_id"
    recordcol_tables <- unique(sch[["recordcol"]][["table_name"]])
    sch[["recordcol"]][["units"]] <- as.character(sch[["recordcol"]][["units"]])
    
  }
  
  # 'recordtab' #
  if (length(sch_rt) != 0L) {
    
    names(sch[["recordtab"]])[names(sch[["recordtab"]]) == "record_field_id"] <- "field_id"
    recordtab_tables <- sch[["recordtab"]][["table_name"]]
    
  }
  
  # 'recordcol' & 'recordtab' #
  if (length(sch_all) == 2L) {
    
    missing_tables <- recordcol_tables[!(recordcol_tables %in% recordtab_tables)]
    recordtab_rows <- nrow(sch[["recordtab"]])
    
    for (tbl in missing_tables) {
      sch[["recordtab"]][recordtab_rows + 1, 1] <- tbl
      recordtab_rows <- recordtab_rows + 1
    }
    sch[["recordtab"]][["parent_name"]] <- as.character(sch[["recordtab"]][["parent_name"]])
    
  }
  
  ## Verbosity ##
  if (!silent) {
    
    if (length(sch_all) != 0L) {
      
      sch_all <- paste0("'", sch_all, "'")
      sch_all <- paste(sch_all, collapse = " and ")
      msg <- paste("... Harmonised and tidied:", sch_all)
      message(msg)
      
    }
    
  }
  
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


### .format_ehier() ###
.format_ehier <- function(dat){
  
  ## Data Management ##
  dat[["type"]] <- class(dat[["value"]])[1]
  dat[["value"]] <- as.character(dat[["value"]])
  
  ## Output ##
  return(dat)
  
}
