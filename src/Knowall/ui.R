if (!require(shiny.router)){
    install.packages("shiny.router")
}

library(shiny)

root_page <- div(h1("Root page"))
result_page <- div(h1("Result page"))
about_page <- div(h1("About page"))

router <- make_router(
    route("/", root_page),
    route("result", result_page),
    route("about", about_page)
)

menu <- tags$ul(
    tags$li(a(class = "item", href = route_link("/"), "Main")),
    tags$li(a(class = "item", href = route_link("result"), "Result page")),
    tags$li(a(class = "item", href = route_link("about"), "About page")),
)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    title = "Knowall Search", 
    menu, 
    router$ui
))
