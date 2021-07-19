googleLayout <- div(tabsetPanel(
  tabPanel(
    "Result",
    plotlyOutput("gtrendTimeHit"),
    mapdeckOutput("gtrendMapdeck")
  ),
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

twitterLayout <- div(tabsetPanel(
  tabPanel(
    "Result",
    wordcloud2Output("twitterWC1"),
    plotlyOutput("twitterHourPost"),
    plotlyOutput("twitterWeekPost"),
    plotlyOutput("twitterMonthPost"),
    plotOutput("twitterSentiment")
  ),
  tabPanel("Data",
           dataTableOutput("twitterDT"))
))

redditLayout <- div(tabsetPanel(
  tabPanel(
    "Result",
    plotlyOutput("reddit3D1"),
    plotlyOutput("reddit3D2")
  ),
  tabPanel("Data",
           dataTableOutput("redditDT"))
))


dash_page <- div(
  
  # actionButton("resetKeyword", "Reset", show = FALSE),
  # textOutput("keywordState"),
  
  # conditionalPanel(condition = "global.keywordSet = TRUE", div())
  
  div(id = "outputDiv", 
      dashboardPage( skin = "black", 
      dashboardHeader(title = "Dashboard page"
                      
                      ),
      dashboardSidebar(
        sidebarMenu(
          switchInput("demoMode", label = "DEMO", value = TRUE), 
          conditionalPanel(
            condition = "input.demoMode == false",
            textInput(
              inputId = "keywords",
              label = "Enter your Keyword",
              placeholder = "Your keyword",
              # placeholder = "keywords seperated by ',' (Max 2)",
              width = "450px"
            )
          ),
          conditionalPanel(
            condition = "input.demoMode == true",
            selectizeInput(
              inputId = "keywordSelect",
              label = "Select a demo keyword",
              # label = "Select demo keywords",
              choices = c(
                "Data Visualization",
                "Data Science",
                "Computer Science",
                "Trump",
                "Biden"
              ),
              selected = NULL,
              multiple = TRUE,
              # options = list(maxItems = 2)
              options = list(maxItems = 1)
            )
          ),
          actionButton("setKeyword", "Set Keyword"), 
          menuItem("Google", tabName = "google"), 
          menuItem("Twitter", tabName = "twitter"), 
          menuItem("Reddit", tabName = "reddit")
        )
      ),
      dashboardBody(
        tabItems(
          tabItem(tabName = "google", googleLayout), 
          tabItem(tabName = "twitter", twitterLayout), 
          tabItem(tabName = "reddit", redditLayout)
        )
      ))
      # navlistPanel(
      #   "Output",
      #   tabPanel("Google", googleLayout),
      #   tabPanel("Twitter", twitterLayout),
      #   tabPanel("Reddit", redditLayout)
      # )
      )
)
