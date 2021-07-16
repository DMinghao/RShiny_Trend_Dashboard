if (!require(bslib)){
    install.packages("bslib")
}

library(shiny)
library(bslib)

source("init_router.R")


shinyOptions(plot.autocolors = TRUE)

shinyUI(bootstrapPage(
    title = "Knowall Search",
    theme = bs_theme(version = 4), 
    navbar,
    tags$div(class = "container",
              router$ui)
))
