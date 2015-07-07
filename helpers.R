gen_title <- function(type){
  # Generate axis title depending on input type --------------------------------
  if (length(type) > 1) {
    return( sapply(type, gen_title) )
  }
  switch(type, 
    cnvs = "Copy number",
    expr = "Expression",
    meth = "Methylation",
    muta = "Mutation status",
    pam50_rnaseq = "PAM50 by RNASeq",
    pam50_array  = "PAM50 by array",
    iC10 = "iC10",
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

fill_major_choices <- c(
  "muta", 
  "subt", 
  "clin"
)
names(fill_major_choices) <- c(
  "Mutation status", 
  "Tumor subtype", 
  "Clinical data"
)

fill_choices <- c(
  "muta",
  "subt_pam50_rnaseq", 
  "subt_pam50_array",
  "subt_iC10",
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
  "Subtype: PAM50 by RNASeq", 
  "Subtype: PAM50 by array", 
  "Subtype: iC10",
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
