gen_title <- function(type){
  # Generate axis title depending on input type --------------------------------
  if (length(type) > 1) {
    return( sapply(type, gen_title) )
  }
  switch(type, 
    cnvs = "Copy number",
    expr = "Expression",
    meth = "Methylation",
    gender = "Gender",
    menopause_status = "Menopause status", 
    tumor_status = "Tumor status",
    vital_status = "Vital status", 
    ajcc_pathologic_tumor_stage = "Tumor stage",
    er_status_by_ihc = "ER status by IHC",
    pr_status_by_ihc = "PR status by IHC",
    her2_status_by_ihc = "HER2 status by IHC",
    histological_type = "Histological type",
    "Undefined"
  )
}

