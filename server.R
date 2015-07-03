library(shiny)
library(data.table)
library(reshape2)
library(ggvis)
library(dplyr)

source("helpers.R")

# Load data which is always used -----------------------------------------------
clin <- readRDS("data/brca/clin.Rds")
cnvs_participants <- readRDS("data/brca/cnvs_participants.Rds")
expr_participants <- readRDS("data/brca/expr_participants.Rds")
meth_participants <- readRDS("data/brca/meth_participants.Rds")
muta_participants <- readRDS("data/brca/muta_participants.Rds")
linked_probes_genes <- readRDS("data/brca/linked_probes_genes.Rds")

# Get contents of direcotires to determine available genes/probes --------------
cnvs_genes  <- gsub("\\.Rds", "", list.files("data/brca/cnvs"))
expr_genes  <- gsub("\\.Rds", "", list.files("data/brca/expr"))
meth_probes <- gsub("\\.Rds", "", list.files("data/brca/meth"))

available_genes  <- intersect(cnvs_genes, expr_genes)
available_probes <- intersect(
  linked_probes_genes$probe[linked_probes_genes$gene %in% available_genes],
  meth_probes
)

shinyServer(function(input, output, session) {
  updateSelectizeInput(session, "gene", choices = available_genes, server = TRUE)
  updateSelectizeInput(session, "fill", choices = fill_choices, server = TRUE)
  probe_choices <- reactive({
    if (input$gene == "") {
      return(NULL)
    }
    all_probes <- linked_probes_genes$probe[
      linked_probes_genes$gene == input$gene
    ]
    return(intersect(all_probes, available_probes))
  })
  observe({
    updateSelectizeInput(
      session, "probe", choices = probe_choices(), server = TRUE
    )
  })

  plot_data <- reactive({
    # Reactive function to generate plot data when action button is pressed
    if (
      input$gene == "" || (
        (
          (input$x_value == "meth") || (input$y_value == "meth")
        ) && input$probe == ""
      )
    ) {
      # Return function if selected gene is empty.
      return(
        data.table(
          participant = character(),
          x = numeric(),
          y = numeric(),
          z = character()
        )
      )
    }
    x_raw <- readRDS(
      paste(
        "data/brca/", input$x_value, "/", switch(input$x_value,
          "meth" = input$probe,
          input$gene
        ), ".Rds", sep = ""
      )
    )
    names(x_raw) <- switch(input$x_value,
      "cnvs" = cnvs_participants,
      "expr" = expr_participants,
      "meth" = meth_participants
    )
    y_raw <- readRDS(
      paste(
        "data/brca/", input$y_value, "/", switch(input$y_value,
          "meth" = input$probe,
          input$gene
        ), ".Rds", sep = ""
      )
    )
    names(y_raw) <- switch(input$y_value,
      "cnvs" = cnvs_participants,
      "expr" = expr_participants,
      "meth" = meth_participants
    )
    part_in_both <- intersect(names(x_raw), names(y_raw))
    if (input$fill == "") {
      z_raw <- rep(NA, length(part_in_both))
      names(z_raw) <- part_in_both
    } else if (substr(input$fill, 1, 4) == "clin") {
      z_raw <- clin[, substring(input$fill, 6)]
      names(z_raw) <- clin[, "bcr_patient_barcode"]
    } else if (input$fill == "muta") {
      z_raw <- rep(NA, length(part_in_both))
      names(z_raw) <- part_in_both
      z_raw[names(z_raw) %in% muta_participants] <- "No mutation"
      muta_tmp <- readRDS(
        paste("data/brca/muta/", input$gene, ".Rds", sep = "")
      )
      muta_tmp <- muta_tmp[muta_tmp$participant %in% part_in_both,]
      z_raw[muta_tmp$participant] <- muta_tmp$type
    }
    xy <- data.table(
      participant = part_in_both,
      x = x_raw[part_in_both],
      y = y_raw[part_in_both],
      z = z_raw[part_in_both]
    )
    return(xy)
  })

  plot_tooltip <- function(x){
    if (is.null(x)) return(NULL)
    return(
      paste(
        "<b>", x$participant, "</b><br>",
        gen_title(input$x_value), " : ", signif(x$x, 4), "<br>",
        gen_title(input$y_value), " : ", signif(x$y, 4), "<br>",
        "Fill : ", x["factor(z)"],
        sep = ""
      )
    )
  }

  # Reactive expression to render ggvis plot -------------------------------
  reactive({
    plot_data() %>%
    ggvis(~x, ~y, key := ~participant) %>%
    layer_points(
      fill = ~factor(z),
      stroke := "black",
      opacity := input$point_opacity,
      size := input$point_size
    ) %>%
    add_axis("x", title = gen_title(input$x_value)) %>%
    add_axis("y", title = gen_title(input$y_value), title_offset = 60) %>%
    add_tooltip(plot_tooltip, on = "hover") %>%
    add_legend("fill", title = gen_title(input$fill)) %>%
    set_options(width = 875, height = 575) 
  }) %>% bind_shiny("plot")
})
