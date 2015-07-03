library(shiny)
library(data.table)
library(reshape2)
library(ggvis)
library(dplyr)

shinyUI(fluidPage(

  titlePanel("TCGA Plotting app version 0.07"),

  sidebarLayout(
    sidebarPanel(
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
      ),
      selectizeInput(
        "fill",
        label = "Select variable to color points",
        choices = NULL,
        options = list(maxItems = 1)
      ),
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
      )
    ),

    mainPanel(
      ggvisOutput("plot")
    )
  )
))
