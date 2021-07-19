googleLayout <- div(tabsetPanel(
  tabPanel(
    "Result",
    plotlyOutput("gtrendTimeHit") %>% withSpinner(size = 1.5),
    mapdeckOutput("gtrendMapdeck") %>% withSpinner(size = 1.5)
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
    wordcloud2Output("twitterWC1") %>% withSpinner(size = 1.5),
    plotlyOutput("twitterHourPost") %>% withSpinner(size = 1.5),
    plotlyOutput("twitterWeekPost") %>% withSpinner(size = 1.5),
    plotlyOutput("twitterMonthPost") %>% withSpinner(size = 1.5),
    plotOutput("twitterSentiment") %>% withSpinner(size = 1.5)
  ),
  tabPanel("Data",
           dataTableOutput("twitterDT"))
))

redditLayout <- div(tabsetPanel(
  tabPanel(
    "Result",
    plotlyOutput("reddit3D1") %>% withSpinner(size = 1.5),
    plotlyOutput("reddit3D2") %>% withSpinner(size = 1.5), 
    plotOutput("redditSentimentJoy") %>% withSpinner(size = 1.5), 
    plotlyOutput("redditSentimentViolin") %>% withSpinner(size = 1.5), 
    plotlyOutput("redditSentimentRadar") %>% withSpinner(size = 1.5), 
    wordcloud2Output("redditWordCloud") %>% withSpinner(size = 1.5)
  ),
  tabPanel("Data",
           dataTableOutput("redditDT"))
))


dash_page <- div(# actionButton("resetKeyword", "Reset", show = FALSE),
  # textOutput("keywordState"),
  
  # conditionalPanel(condition = "global.keywordSet = TRUE", div())

    dashboardPage(
      skin = "black",
      dashboardHeader(title = "Dashboard page"),
      dashboardSidebar(sidebarMenu(
        menuItem(
          "Config",
          
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
              selected = "Data Visualization",
              multiple = TRUE,
              # options = list(maxItems = 2)
              options = list(maxItems = 1)
            )
          ),
          actionButton("setKeyword", "Set Keyword")
        ),
        menuItem("Google", tabName = "google"),
        menuItem("Twitter", tabName = "twitter"),
        menuItem("Reddit", tabName = "reddit")
      )),
      dashboardBody(tabItems(
        tabItem(tabName = "google", googleLayout),
        tabItem(tabName = "twitter", twitterLayout),
        tabItem(tabName = "reddit", redditLayout)
      ))
    )
    # navlistPanel(
    #   "Output",
    #   tabPanel("Google", googleLayout),
    #   tabPanel("Twitter", twitterLayout),
    #   tabPanel("Reddit", redditLayout)
    # )
  )
