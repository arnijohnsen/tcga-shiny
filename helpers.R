gen_title <- function(type){
  # Generate axis title depending on input type --------------------------------
  if (length(type) > 1) {
    return( sapply(type, gen_title) )
  }
  switch(type, 
    cnvs = "Copy number",
    expr = "Expression",
    meth = "Methylation",
    clin_gender = "Gender",
    clin_menopause_status = "Menopause status", 
    clin_tumor_status = "Tumor status",
    clin_vital_status = "Vital status", 
    clin_ajcc_pathologic_tumor_stage = "Tumor stage",
    clin_er_status_by_ihc = "ER status by IHC",
    clin_pr_status_by_ihc = "PR status by IHC",
    clin_her2_status_by_ihc = "HER2 status by IHC",
    clin_histological_type = "Histological type",
    "Undefined"
  )
}

fill_choices <- c(
  "muta",
  "clin_gender",
  "clin_menopause_status",
  "clin_tumor_status",
  "clin_vital_status",
  "clin_ajcc_pathologic_tumor_stage",
  "clin_er_status_by_ihc",
  "clin_pr_status_by_ihc",
  "clin_her2_status_by_ihc",
  "clin_histological_type"
)
names(fill_choices) <- c(
  "Mutation status", 
  "Clinical: Gender",
  "Clinical: Menopause status", 
  "Clinical: Tumor status",
  "Clinical: Vital status", 
  "Clinical: Tumor stage",
  "Clinical: ER status by IHC",
  "Clinical: PR status by IHC",
  "Clinical: HER2 status by IHC",
  "Clinical: Histological type"
)
