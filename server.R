library(shiny)
library(data.table)
library(RSQLite)
library(reshape2)
library(ggvis)
library(dplyr)
library(stringr)

db <- dbConnect(SQLite(), dbname = "data/brca_min.sqlite")

clinical <- data.table(dbGetQuery(db, "SELECT * FROM clin"))
clinical[,bcr_patient_barcode := str_replace_all(bcr_patient_barcode, "-", "_")]
setkey(clinical, bcr_patient_barcode)
allowed_probes <- unlist(dbGetQuery(db, "SELECT probe FROM meth_cancer"))

shinyServer(function(input, output, session) {

  gen_title <- function(type){
    # Generate axis title depending on input type ------------------------------
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

  # Selectize input for gene selection -----------------------------------------
  gene_choice_list <- dbGetQuery(db, "SELECT * FROM nice_genes")$nice_genes
  updateSelectizeInput(
    session,
    "gene",
    choices = gene_choice_list,
    server = TRUE
  )

  # Selectize input for clinical selection -------------------------------------
  clin_choice_list <- c(
    "gender", "menopause_status", "tumor_status", "vital_status",
    "ajcc_pathologic_tumor_stage", "er_status_by_ihc", "pr_status_by_ihc",
    "her2_status_by_ihc", "histological_type"
  )
  names(clin_choice_list) <- gen_title(clin_choice_list)
  updateSelectizeInput(
    session,
    "clin",
    choices = clin_choice_list,
    server = TRUE
  )

  # Selcetize input for probe selection, whih updates once a gene is selected --
  probe_choice_list <- data.table(
    dbGetQuery(db, "SELECT * FROM linked_probes_genes")
  )
  f_probe_choice_list <- reactive({
    if (input$gene == "") {
      return(NULL)
    }
    all_probes <- probe_choice_list[gene == input$gene]$probe
    return(intersect(all_probes, allowed_probes))
  })
  observe({
    updateSelectizeInput(
      # Selectize input for probe
      session,
      "probe",
      choices = f_probe_choice_list(),
      server = TRUE
    )
  })

  plot_data <- eventReactive(input$go_plot, {
    # Reactive function to generate plot data when action button is pressed
    if (input$gene == "") {
      # Return function if selected gene is empty.
      return(
        data.table(
          x <- numeric(),
          y <- numeric()
        )
      )
    }
    x_query <- paste(
      # Generate SQLite query for x-variable
      "SELECT * FROM ",
      input$x_value,
      "_cancer WHERE ",
      switch(input$x_value, meth = "probe", "gene"),
      "='",
      switch(input$x_value, meth = input$probe, input$gene),
      "'",
      sep = ""
    )
    y_query <- paste(
      # Generate SQLite query for y-variable
      "SELECT * FROM ",
      input$y_value,
      "_cancer WHERE ",
      switch(input$y_value, meth = "probe", "gene"),
      "='",
      switch(input$y_value, meth = input$probe, input$gene),
      "'",
      sep = ""
    )
    x_raw <- unlist(dbGetQuery(db, x_query))
    y_raw <- unlist(dbGetQuery(db, y_query))
    x <- x_raw[grep("^TCGA", names(x_raw))]
    y <- y_raw[grep("^TCGA", names(y_raw))]
    xy <- data.table(
      participant = str_sub(c(names(x), names(y)), 1, 12),
      type = c(rep("x", length(x)), rep("y", length(y))),
      value = c(as.numeric(x), as.numeric(y))
    )
    xy_cast <- dcast.data.table(xy, participant ~ type, value.var="value")
    xy_cast <- xy_cast[complete.cases(xy_cast)]
    if (!(all(c("x","y") %in% names(xy_cast)))) {
      return(
        data.table(
          x <- numeric(),
          y <- numeric()
        )
      )
    }
    xy_cast[,clin := clinical[participant, input$clin, with = F]]
    return(xy_cast)
  })

  plot_tooltip <- function(x){
    # Returns tooltip text in html form
    if (is.null(x)) return(NULL)
    str_replace_all(x$participant, "_", "-")
  }

  observe({
    # Reactive expression to render ggvis plot -------------------------------
    eventReactive(input$go_plot,{
      plot_data() %>%
      ggvis(~x, ~y, key := ~participant) %>%
      layer_points(
        fill = ~factor(clin),
        stroke := "black",
        opacity := input$point_opacity,
        size := input$point_size
      ) %>%
      add_axis("x", title = gen_title(input$x_value)) %>%
      add_axis("y", title = gen_title(input$y_value), title_offset = 60) %>%
      add_legend("fill", title = gen_title("gender")) %>%
      set_options(width = 875, height = 575) 
    }) %>% bind_shiny("plot")
  })
})
