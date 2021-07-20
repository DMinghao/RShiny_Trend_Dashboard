source("requirements.R")
source("getDataFunc.R")
source("init_router.R")

shinyOptions(plot.autocolors = TRUE)

shinyUI(bootstrapPage(
    title = "Knowall Search",
    theme = bs_theme(
        version = 4,
        # bootswatch = "black",
        base_font = c("Grandstander", "sans-serif"),
        code_font = c("Fira Code", "monospace"),
        heading_font = "'Helvetica Neue', Helvetica, sans-serif"
    ),
    navbar,
    router$ui
))
