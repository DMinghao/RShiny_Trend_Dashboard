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
      tabsetPanel(
        tabPanel("Google Trends"), 
        tabPanel("Twitter"), 
        tabPanel("Reddit")
      )
      )
)
