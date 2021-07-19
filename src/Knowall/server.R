if (!require(shiny.router)) {
  install.packages("shiny.router")
}
if (!require(stringr)) {
  install.packages("stringr")
}
if (!require(DT)) {
  install.packages("DT")
}
library(shiny)
library(stringr)
library(DT)

source("getDataFunc.R")


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
  
  globalPlots <- 
    reactiveValues(
      gtrendTimeHit = NULL
    )
  
  observeEvent(input$go, {
    global$displayKeyword <-  updateKeywordText()
    getData()
    # refreshRender()
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
      if(length(global$keywordProvided) == 1 && !("" %in% global$keywordProvided)) {
        kw <- global$keywordProvided[1]
        print("getting data")
        global$GoogleData <- getGoogleTrendData(kw)
        global$TwitterData1 <- getTwitterData(kw)
        # global$RedditData1 <- getRedditData(kw)
      }
    }
  }
  
  plotDataVali <- reactive({
    validate(
      need(global$GoogleData != NULL, "Waiting for Google Trend Data...")
    )
    get(global$GoogleData, 'GoogleData')
  })
  
  # refreshRender <- function(){
  #   globalPlots$gtrendTimeHit = {
  #     
  #   }
  # }
  
  output$keywordState <- renderText({
    global$displayKeyword
  })
  
  output$gtrendTimeHit <- renderPlotly({
    p <- ggplot(global$GoogleData$interest_over_time) +
      geom_line(aes(x = date, y = hits))
    
    p %>%
      ggplotly()
  })
  
  output$gtrendMapdeck <- renderMapdeck({
    sf <- geojson_sf("./www/us-states.json")
    
    new_sf <- sf %>%
      merge(
        global$GoogleData$interest_by_region %>% select(c(location, hits)),
        by.x = 'name',
        by.y = 'location',
        all = TRUE
      ) %>%
      select(-c(density)) %>%
      mutate(hits_scale = hits * 10) %>%
      mutate(info = paste("<b>", name, " - ", hits, "</b><br>")) %>%
      st_as_sf()
    
    mapdeck(
      style = mapdeck_style('dark'),
      pitch = 45
    ) %>%
      add_polygon(
        data = new_sf,
        fill_colour = "hits",
        elevation_scale = 1000,
        elevation = "hits_scale",
        tooltip = "info",
        legend = TRUE,
        legend_format = list(fill_colour = as.integer)
      )
  })
  
  output$gtrendDTinterest_by_country <- renderDataTable({global$GoogleData$interest_by_country})
  output$gtrendDTinterest_by_region <- renderDataTable({global$GoogleData$interest_by_region})
  output$gtrendDTinterest_by_dma <- renderDataTable({global$GoogleData$interest_by_dma})
  output$gtrendDTinterest_by_city <- renderDataTable({global$GoogleData$interest_by_city})
  output$gtrendDTrelated_topics <- renderDataTable({global$GoogleData$related_topics})
  output$gtrendDTrelated_queries <- renderDataTable({global$GoogleData$related_queries})
  
})
