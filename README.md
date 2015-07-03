# tcga-shiny
This repository contains an R Shiny app to explore data from The Cancer
Genome Atlas (TCGA). The data used has been processed with scripts from
https://github.com/arnijohnsen/tcga-analysis

## Installation
In `R`, use the following commands
```
# install.packages(c("shiny", "ggvis"))
library(shiny)
runGitHub("tcga-shiny", "arnijohnsen")
```
On \*nix systems, you can clone this repository, run the app and make
modifications with the following commands
```
git clone https://github.com/arnijohnsen/tcga-shiny
R
> library(shiny)
> runApp("tcga-shiny")
```
