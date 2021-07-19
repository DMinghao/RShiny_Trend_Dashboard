googleLayout <- div(
  tabsetPanel(
    tabPanel("Result",
             plotlyOutput("gtrendTimeHit"),
             mapdeckOutput("gtrendMapdeck")),
    tabPanel(
      "Data",
      selectInput(
        "gtrendDataSelect",
        choices = c(
          "interest_over_time", 
          "interest_by_country",
          "interest_by_region",
          "interest_by_dma",
          "interest_by_city",
          "related_topics",
          "related_queries"
        ), 
        label = "Select a data frame"
      ), 
      dataTableOutput("gtrendDT")
    )
  ))

twitterLayout <- div(
  tabsetPanel(
    tabPanel("Result", 
             wordcloud2Output("twitterWC1"), 
             plotlyOutput("twitterHourPost"), 
             plotlyOutput("twitterWeekPost"), 
             plotlyOutput("twitterMonthPost"), 
             plotOutput("twitterSentiment")
    ),
    tabPanel("Data", 
             dataTableOutput("twitterDT"))
  ))

redditLayout <- div(
  tabsetPanel(
    tabPanel("Result",
             plotlyOutput("reddit3D1"),
             plotlyOutput("reddit3D2")
             ),
    tabPanel("Data")
  ))


dash_page <- div(
  h1("Dashboard page"),
  switchInput("demoMode", label = "DEMO", value = FALSE),
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
  actionButton("setKeyword", "Set Keyword"),
  # actionButton("resetKeyword", "Reset", show = FALSE),
  # textOutput("keywordState"),
  
  # conditionalPanel(condition = "global.keywordSet = TRUE", div())
  
  div(id = "outputDiv",
      navlistPanel(
        "Output",
        tabPanel("Google", googleLayout),
        tabPanel("Twitter", twitterLayout),
        tabPanel("Reddit", redditLayout)
      ))
)
