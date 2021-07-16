
if (!require(shiny.router)){
  install.packages("shiny.router")
}
library(shiny)


# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

    router$server(input, output, session)

})
