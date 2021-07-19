if (!require(bslib)){
    install.packages("bslib")
}
if (!require(shinyWidgets)){
    install.packages("shinyWidgets")
}
if (!require(plotly)){
    install.packages("plotly")
}

library(shiny)
library(bslib)
library(shinyWidgets)

source("init_router.R")


shinyOptions(plot.autocolors = TRUE)

shinyUI(bootstrapPage(
    title = "Knowall Search",
    theme = bs_theme(version = 4), 
    navbar,
    router$ui
))
