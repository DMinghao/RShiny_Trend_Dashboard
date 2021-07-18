if (!require(shiny.router)) {
  install.packages("shiny.router")
}
if (!require(stringr)) {
  install.packages("stringr")
}
library(shiny)
library(stringr)


# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  router$server(input, output, session)
  
  global <-
    reactiveValues(
      keywordProvided = c(),
      displayKeyword = "",
      GoogleData = NULL,
      TwitterData1 = NULL,
      RedditData1 = NULL,
      TwitterData2 = NULL,
      RedditData2 = NULL
    )
  
  observeEvent(input$go, {
    global$displayKeyword <-  updateKeywordText()
  })
  
  updateKeywordText <- function() {
    if (input$demoMode == TRUE) {
      global$keywordProvided = input$keywordSelect
      # print(input$keywordSelect)
    } else {
      temp = str_split(input$keywords, ',', n = 2)[[1]]
      # print(temp)
      global$keywordProvided = temp
    }
    rt <- "Not Provided"
    if (length(global$keywordProvided) > 0) {
      rt = paste(global$keywordProvided, ", ")
    }
    rt
  }
  
  getData <- function() {
    if(input$demoMode == TRUE){
      
    }else {
      if(length(global$keywordProvided) == 2 && !("" %in% global$keywordProvided)){
        
      }
    }
  }
  
  output$keywordState <- renderText({
    global$displayKeyword
  })
  
  
})
