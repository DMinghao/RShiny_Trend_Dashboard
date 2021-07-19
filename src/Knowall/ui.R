if (!require(bslib)) {
    install.packages("bslib")
}
if (!require(shinyWidgets)) {
    install.packages("shinyWidgets")
}
if (!require(plotly)) {
    install.packages("plotly")
}

if (!require(mapdeck)) {
    install.packages("mapdeck")
}
if (!require(wordcloud2)) {
    install.packages("wordcloud2")
}
if (!require(shinyjs)) {
    install.packages("shinyjs")
}
library(shinyjs)
library(wordcloud2)
library(mapdeck)
library(shiny)
library(bslib)
library(shinyWidgets)

source("init_router.R")


shinyOptions(plot.autocolors = TRUE)

shinyUI(bootstrapPage(
    title = "Knowall Search",
    theme = bs_theme(
        version = 4,
        base_font = c("Grandstander", "sans-serif"),
        code_font = c("Fira Code", "monospace"),
        heading_font = "'Helvetica Neue', Helvetica, sans-serif"
    ),
    navbar,
    router$ui
))
