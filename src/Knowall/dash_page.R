dash_page <- div(h1("Dashboard page"), 
                   switchInput("demoMode", label = "DEMO", value = TRUE),
                 textOutput("keywordState"), 
                 )
