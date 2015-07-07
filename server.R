library(shiny)
library(ggvis)

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

allowed_subt_fill_minor <- c("pam50_rnaseq", "pam50_array", "iC10")
allowed_clin_fill_minor <- c(
  "gender", "menopause_status", "tumor_status", "vital_status", 
  "ajcc_pathologic_tumor_stage", "er_status_by_ihc", "pr_status_by_ihc",
  "her2_status_by_ihc", "histological_type"
 )

shinyServer(function(input, output, session) {
  updateSelectizeInput(session, "gene", choices = available_genes, server = TRUE)
  updateSelectizeInput(
    session, "fill_major",
    choices = fill_major_choices, server = TRUE
  )
  fill_minor_choices <- reactive({
    if (input$fill_major == "") {
      return(NULL)
    } else if (input$fill_major == "muta") {
      return("Mutation status")
    } else if (input$fill_major == "subt") {
      choices <- allowed_subt_fill_minor
      names(choices) <- gen_title(choices)
      return(choices)
    } else if (input$fill_major == "clin") {
      choices <- allowed_clin_fill_minor
      names(choices) <- gen_title(choices)
      return(choices)
    }
  })
  observe({
    updateSelectizeInput(
      session, "fill_minor", choices = fill_minor_choices(), server = TRUE
    )
  })
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
        data.frame(
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

    # Create fill variable -----------------------------------------------------
    if ((input$fill_major == "clin") && (
      input$fill_minor %in% allowed_clin_fill_minor
    )) {
      # Clinical fill
      z_raw <- clin[, input$fill_minor]
      names(z_raw) <- clin[, "bcr_patient_barcode"]
    } else if (input$fill_major == "subt" && (
      input$fill_minor %in% allowed_subt_fill_minor
    )) {
      # Subtype fill
      z_raw <- clin[, input$fill_minor]
      names(z_raw) <- clin[, "bcr_patient_barcode"]
    } else if (input$fill_major == "muta") {
      # Mutation fill
      z_raw <- rep(NA, length(part_in_both))
      names(z_raw) <- part_in_both
      z_raw[names(z_raw) %in% muta_participants] <- "No mutation"
      muta_tmp <- readRDS(
        paste("data/brca/muta/", input$gene, ".Rds", sep = "")
      )
      muta_tmp <- muta_tmp[muta_tmp$participant %in% part_in_both,]
      z_raw[muta_tmp$participant] <- muta_tmp$type
    } else {
      # Empty fill
      z_raw <- rep(NA, length(part_in_both))
      names(z_raw) <- part_in_both
    }
    xy <- data.frame(
      participant = part_in_both,
      x = x_raw[part_in_both],
      y = y_raw[part_in_both],
      z = z_raw[part_in_both]
    )
    xy <- xy[!is.na(xy$x) & !is.na(xy$y),]
    return(xy)
  })

  plot_tooltip <- function(x){
    if (is.null(x)) return(NULL)
    return(
      paste(
        "<b>", x$participant, "</b><br>",
        gen_title(input$x_value), " : ", signif(x$x, 4), "<br>",
        gen_title(input$y_value), " : ", signif(x$y, 4), "<br>",
        gen_title(input$fill_minor),    " : ", x["factor(z)"],
        sep = ""
      )
    )
  }

add_custom_fill_color <- function(vis, type) {
  if (type %in% c("pam50_rnaseq", "pam50_array")) {
    color_range <- c("red", "purple", "blue", "cyan", "green", "gray")
    return(scale_nominal(vis, "fill", range = color_range))
  } else {
    return(vis)
  }
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
    add_custom_fill_color(input$fill_minor) %>%
    scale_numeric("x", trans = ifelse(input$log_scale_x, "log", "linear")) %>%
    scale_numeric("y", trans = ifelse(input$log_scale_y, "log", "linear")) %>%
    add_axis("x", title = gen_title(input$x_value)) %>%
    add_axis("y", title = gen_title(input$y_value), title_offset = 60) %>%
    add_tooltip(plot_tooltip, on = "hover") %>%
    add_legend("fill", title = gen_title(input$fill_minor)) %>%
    set_options(width = "auto", height = input$plot_height) 
  }) %>% bind_shiny("plot")
})
