dash_page <- div(
  h1("Dashboard page"),
  switchInput("demoMode", label = "DEMO", value = TRUE),
  conditionalPanel(
    condition = "input.demoMode == false",
    textInput(
      inputId = "keywords",
      label = "Enter your Keyword",
      placeholder = "keywords seperated by ',' (Max 2)",
      width = "450px"
    )
  ),
  conditionalPanel(
    condition = "input.demoMode == true",
    selectizeInput(
      inputId = "keywordSelect",
      label = "Select demo keywords",
      choices = c("a", "aa", "b", "bb"),
      selected = NULL,
      multiple = TRUE,
      options = list(maxItems = 2)
    )
  ),
  actionButton("go", "Go"),
  textOutput("keywordState"),
  div(id = "outputDiv",
      navlistPanel(
        "Output",
        tabPanel("Google", div(
          tabsetPanel(
            tabPanel("Result", 
                     div(
                       plotlyOutput("gtrendTimeHit"), 
                     mapdeckOutput("gtrendMapdeck")
                     )
                     ), 
            tabPanel("Data", 
                     # dataTableOutput("gtrendDT"),
                     dataTableOutput("gtrendDTinterest_by_country"),
                     dataTableOutput("gtrendDTinterest_by_region"),
                     dataTableOutput("gtrendDTinterest_by_dma"),
                     dataTableOutput("gtrendDTinterest_by_city"),
                     dataTableOutput("gtrendDTrelated_topics"),
                     dataTableOutput("gtrendDTrelated_queries")
                     )
          )
          )),
        tabPanel("Twitter", div(
          tabsetPanel(
            tabPanel("Result", 
                     plotlyOutput("twitter")), 
            tabPanel("Data")
          )
        )),
        tabPanel("Reddit", div(
          tabsetPanel(
            tabPanel("Result", 
                     plotlyOutput("reddit")), 
            tabPanel("Data")
          )
        ))
      ))
)
