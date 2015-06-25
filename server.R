library(shiny)
library(data.table)
library(reshape2)
library(ggvis)
library(dplyr)
library(stringr)

source("helpers.R")

clin <- readRDS("data/clin.Rds")
cnvs <- readRDS("data/cnvs_cancer.Rds")
expr <- readRDS("data/expr_cancer.Rds")
meth <- readRDS("data/meth_cancer.Rds")

nice_genes          <- readRDS("data/nice_genes.Rds")
nice_probes         <- readRDS("data/nice_probes.Rds")
linked_probes_genes <- readRDS("data/linked_probes_genes.Rds")

allowed_probes <- meth$probe

shinyServer(function(input, output, session) {
  updateSelectizeInput(session, "gene", choices = nice_genes, server = TRUE)
  # clin_choices <- names(clin)
  # names(clin_choices) <- gen_title(clin_choices)
  updateSelectizeInput(session, "clin", choices = clin_choices, server = TRUE)
  probe_choices <- reactive({
    if (input$gene == "") {
      return(NULL)
    }
    all_probes <- linked_probes_genes[gene == input$gene]$probe
    return(intersect(all_probes, allowed_probes))
  })
  observe({
    updateSelectizeInput(
      session, "probe", choices = probe_choices(), server = TRUE
    )
  })

  plot_data <- reactive({
    # Reactive function to generate plot data when action button is pressed
    if (input$gene == "" || input$probe == "" || input$clin == "") {
      # Return function if selected gene is empty.
      return(
        data.table(
          participant = character(),
          x = numeric(),
          y = numeric(),
          clinical = character()
        )
      )
    }
    x_raw <- switch(input$x_value,
      "cnvs" = unlist(cnvs[input$gene]),
      "expr" = unlist(expr[input$gene]),
      "meth" = unlist(meth[input$probe])
    )
    y_raw <- switch(input$y_value,
      "cnvs" = unlist(cnvs[input$gene]),
      "expr" = unlist(expr[input$gene]),
      "meth" = unlist(meth[input$probe])
    )
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
          participant = character(),
          x = numeric(),
          y = numeric(),
          clinical = character()
        )
      )
    }
    xy_cast[,clinical := clin[participant, input$clin, with = F]]
    return(xy_cast)
  })

  plot_tooltip <- function(x){
    # Returns tooltip text in html form
    if (is.null(x)) return(NULL)
    str_replace_all(x$participant, "_", "-")
  }

  # Reactive expression to render ggvis plot -------------------------------
  reactive({
    plot_data() %>%
    ggvis(~x, ~y, key := ~participant) %>%
    layer_points(
      fill = ~factor(clinical),
      stroke := "black",
      opacity := input$point_opacity,
      size := input$point_size
    ) %>%
    add_axis("x", title = gen_title(input$x_value)) %>%
    add_axis("y", title = gen_title(input$y_value), title_offset = 60) %>%
    add_tooltip(plot_tooltip, on = "hover") %>%
    add_legend("fill", title = gen_title(input$clin)) %>%
    set_options(width = 875, height = 575) 
  }) %>% bind_shiny("plot")
})
