# tcga-shiny
This repository contains an R Shiny app to explore data from The Cancer
Genome Atlas (TCGA). The data used has been processed with scripts from
https://github.com/arnijohnsen/tcga-analysis

## Installation
### Shinyapps.io
The app is available at https://arnijohnsen.shinyapps.io/tcga-shiny
### Running locally
To run the app locally, use the following commands within `R`
```
# install.packages(c("shiny", "ggvis"))
library(shiny)
runGitHub("tcga-shiny", "arnijohnsen")
```
You may need to install the `shiny` and `ggvis` packages before running the app.
If so, run the commented line in the commands above. 

### Cloning repository and running locally
On \*nix systems, you can clone this repository, run the app and make
modifications with the following commands
```
git clone https://github.com/arnijohnsen/tcga-shiny
R
> library(shiny)
> runApp("tcga-shiny")
```

## User guide
### Selecting genes, probes and axis variables
Begin by selecing or searching for a gene by it name, in the "Search for gene"
textbox. Once a gene has been selected, you can select a methylation probe
linked to the selected genes, in "Search for probe". Each probe is annotated
based on its position in the gene:

- `(promoter)` indicates probes in TSS200 or 5'UTR regions
- `(body ...)` indicates probes in gene body\*
    - `(body_island)` indicates probes in gene body inside cpg islands
    - `(body_shore)` indicates probes in gene body on cpg island shores
    - `(body_none)` indicates probes in gene body outside cpg islands
- `(enhancer)` indicates probes linked to enhancer regions
- `(undefined)` indicates probes which fall in to no other category

If a probe falls in to multiple categories, the categorical hierarchy is:
promoter, enhancer, body, undefined

Three numerical variables are available for plotting: 

- Copy number variation
- Gene expression from RNA Sequencing
- Methylation

If methylation is selected as a plotting variable, a methylation probe must also
be selected in "Search for probe".

### Color points by categorical variable
The scatterplot can be colored by 3 types of categorical variables, chosen in
the first "Select variable to color points" textbox:

 - Somatic mutations in the gene
 - Tumor subtype
 - Clinical information

For tumor subtypes and clinical information, a secondary classification is
chosen from the second "Select variable to color points" textbox. 

For tumor subtypes, three classifications are available: 

 - PAM50 subtypes based on microarray data
 - PAM50 subtypes based on RNA Sequencing
 - iC10 subtypes

For clinical information, nine classifications are available:

 - Age
 - Menopause status
 - Tumor status (is the participant tumor free)
 - Vital status of participant
 - Tumor stage
 - ER (Estrogen receptor) status by IHC (immunohistochemistry)
 - PR (Progestrone receptor) status by IHC
 - HER2 (Human epidermal growth factor receptor 2) status by IHC
 - Histological type of tumor

### Change point size and opacity
Sliders can be used to change point size and opacity, as parts of some plots
can become cluttered and difficult to see individual points.

### Change plot dimensions
The plot *width* is automatically set as the browser width. Resize your browser
window to change plot width. 

The plot *height* is set by a slider, which defaults to 800 px.

### Hover tooltips
Once a plot has been generated, you can hover over individual points to display
the following information:

 - Participant barcode
 - x-value for the point
 - y-value for the point
 - Value of categorical variable used to color points

### Save plots
Once a plot has been generated, you can save the plot as either `.svg` or `.png`
file. Click the cogwheel at top right of the plot to choose between *SVG* or
*Canvas*, and click "Download SVG" or "Download PNG" to save the plot.
