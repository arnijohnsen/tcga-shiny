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

clin_choices <- c(
  "gender",
  "menopause_status",
  "tumor_status",
  "vital_status",
  "ajcc_pathologic_tumor_stage",
  "er_status_by_ihc",
  "pr_status_by_ihc",
  "her2_status_by_ihc",
  "histological_type"
)
names(clin_choices) <- c(
  "Gender",
  "Menopause status", 
  "Tumor status",
  "Vital status", 
  "Tumor stage",
  "ER status by IHC",
  "PR status by IHC",
  "HER2 status by IHC",
  "Histological type"
)
