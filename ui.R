library(shiny)
library(ggvis)

shinyUI(fluidPage(
  title = "TCGA Plotting app version 0.07",
  fluidRow(
    column(4,
      selectizeInput(
        "gene",
        label = "Search for gene",
        choices = NULL,
        options = list(maxOptions = 15, maxItems = 1)
      ),
      selectizeInput(
        "probe",
        label = "Search for probe",
        choices = NULL,
        options = list(maxOptions = 15, maxItems = 1)
      ),
      radioButtons(
        "x_value",
        label = "Select x-axis variable",
        choices = list(
          "Copy number" = "cnvs",
          "Expression" = "expr",
          "Methylation" = "meth"
        ),
        selected = "cnvs", 
        inline = TRUE
      ),
      radioButtons(
        "y_value",
        label = "Select y-axis variable",
        choices = list(
          "Copy number" = "cnvs",
          "Expression" = "expr",
          "Methylation" = "meth"
        ),
        selected = "expr", 
        inline = TRUE
      )
    ),
    column(4,
      selectizeInput(
        "fill",
        label = "Select variable to color points",
        choices = NULL,
        options = list(maxItems = 1)
      ),
      checkboxInput(
        "log_scale_x",
        "Log scale x axis", 
        value = FALSE
      ),
      checkboxInput(
        "log_scale_y",
        "Log scale y axis", 
        value = FALSE
      )
    ),
    column(4,
      sliderInput(
        "point_size",
        "Point size",
        min = 0,
        max = 100,
        value = 50),
      sliderInput(
        "point_opacity",
        "Point opacity",
        min = 0,
        max = 1,
        value = 0.8
      ),
      sliderInput(
        "plot_height",
        "Plot height",
        min = 0,
        max = 2000,
        value = 800,
        step = 50
      )
    )
  ),
  hr(),
  ggvisOutput("plot")
))
