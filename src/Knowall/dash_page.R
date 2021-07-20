setupLayout <-
  div(
    class = "container",
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
  )

googleLayout <- div(tabsetPanel(
  tabPanel(
    "Result", icon = icon("fas fa-poll-h"), 
    plotlyOutput("gtrendTimeHit") %>% withSpinner(size = 1.5),
    p(
      "The first plot is a line chart, which illustrates the popularity of keywords over a period. The x-axis represents the date, while the y-axis represents the popularity. The maximum value can be reached as 100, while the minimum value is always 0. By simply typing down any keyword, the line chart will show how the popularity of this keyword fluctuates within a year. If you type down two keywords, then it will generate a comparison of two keywords in the line chart."
    ),
    br(),
    p(
      "We also provide a table for detailed geometric information about that keyword and its related topics, including location, hits, geo and gprop, in order to help web users to take a deep dive."
    ),
    mapdeckOutput("gtrendMapdeck") %>% withSpinner(size = 1.5),
    p(
      "Another interesting and useful feature of our webpage is that web users are able to see how the popularity of a keyword varies over the States.In this 3-D visualization, taller columns represent higher popularity; at the same time, lighter color represents higher popularity. It helps web users to gain more insight of that keyword from various aspects. "
    )
  ),
  tabPanel(
    "Data", icon = icon("fas fa-database"), 
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
    "Result", icon = icon("fas fa-poll-h"), 
    wordcloud2Output("twitterWC1") %>% withSpinner(size = 1.5),
    plotlyOutput("twitterHourPost") %>% withSpinner(size = 1.5),
    plotlyOutput("twitterWeekPost") %>% withSpinner(size = 1.5),
    # plotlyOutput("twitterMonthPost") %>% withSpinner(size = 1.5),
    plotOutput("twitterSentiment") %>% withSpinner(size = 1.5)
  ),
  tabPanel("Data", icon = icon("fas fa-database"), 
           dataTableOutput("twitterDT"))
))

redditLayout <- div(tabsetPanel(
  tabPanel(
    "Result", icon = icon("fas fa-poll-h"), 
    plotlyOutput("reddit3D1") %>% withSpinner(size = 1.5),
    plotlyOutput("reddit3D2") %>% withSpinner(size = 1.5),
    plotOutput("redditSentimentJoy") %>% withSpinner(size = 1.5),
    plotlyOutput("redditSentimentViolin") %>% withSpinner(size = 1.5),
    plotlyOutput("redditSentimentRadar") %>% withSpinner(size = 1.5),
    wordcloud2Output("redditWordCloud") %>% withSpinner(size = 1.5)
  ),
  tabPanel("Data", icon = icon("fas fa-database"), 
           dataTableOutput("redditDT"))
))


dash_page <-
  div(# actionButton("resetKeyword", "Reset", show = FALSE),
    # textOutput("keywordState"),
    
    # conditionalPanel(condition = "global.keywordSet = TRUE", div())
    
    dashboardPage(
      skin = "black",
      dashboardHeader(title = "Dashboard page", disable = TRUE),
      dashboardSidebar(sidebarMenu(
        menuItem("Setup", tabName = "setup", icon = icon("fas fa-cogs")),
        menuItem("Google", tabName = "google", icon = icon("fab fa-google")),
        menuItem("Twitter", tabName = "twitter", icon = icon("fab fa-twitter")),
        menuItem("Reddit", tabName = "reddit", icon = icon("fab fa-reddit-alien"))
      )),
      dashboardBody(tabItems(
        tabItem(tabName = "setup",setupLayout),
        tabItem(tabName = "google", googleLayout),
        tabItem(tabName = "twitter", twitterLayout),
        tabItem(tabName = "reddit", redditLayout)
      ))
    )
    )
# navlistPanel(
#   "Output",
#   tabPanel("Google", googleLayout),
#   tabPanel("Twitter", twitterLayout),
#   tabPanel("Reddit", redditLayout)
# ))
