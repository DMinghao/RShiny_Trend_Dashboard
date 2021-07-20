about_page <- div(class = "container",
  tags$div(class = "card bg-dark text-white",
           tags$img(class = "card-img",
                    size = "50%",
                    # width = 800,
                    # height="50%", width="50%",
                    src = "./carey.logo.small.horizontal.blue.jpg",
                    alt = "Card image"),
           tags$div(class = "card-img-overlay",
                    tags$h5(class = "card-title",
                            " Data Visualization By Instructor Mohammad Ali Alamdar Yazdi",
                            style = "color:Black")

                   )),
          
  tags$div(class = "card text-center",
           tags$div(class = "card-header",
                    tags$ul(class = "nav nav-tabs card-header-tabs",
                            tags$li(class = "nav-item",
                                    tags$a(class = "nav-link active",
                                           "aria-current" = "true",
                                           href = "#",
                                           "Contributor")),
                            tags$li(class = "nav-item",
                                    tags$a(class = "nav-link ",
                                           href = "#",
                                           tabindex = "-1",
                                           # "aria-disabled" = "true",
                                           "Github")))),
           tags$div(class = "card-body",
                    tags$p(class = "card-text",
                           "Han Liu -- Master of Information System Management",
                           a(href = "lh971016@gmail.com","lh971016@gmail.com")
                           ),
                    tags$p(class = "card-text",
                           "Minghao Du -- Master of Information System Management",
                           a(href = "minghaodu96@gmail.com","minghaodu96@gmail.com")
                           ),
                    tags$p(class = "card-text",
                           "Mengying Zhao -- Master of Information System Management",
                           a(href = "mailto:zymm48@gmail.com","zymm48@gmail.com")
                    ),
                    tags$p(class = "card-text",
                           "Wenlu Chen -- Master of Information System Management",
                           a(href = "Wenlu3412@gmail.com","Wenlu3412@gmail.com")
                    ),
                    tags$p(class = "card-text",
                           "Yanlin Li -- Master of Information System Management",
                           a(href = "l3pphadct@gmail.com","l3pphadct@gmail.com")
                    )
                   ),
           tags$div(class = "card-body",
                    tags$p(class = "card-text",
                           "Github",
                           a(href = "https://github.com/DMinghao/RShiny_Trend_Dashboard"))
                   # tag$iframe(src="https://github.com/DMinghao/RShiny_Trend_Dashboard")
           )
           
           ),
  
  br(),
  tags$div(class = "card border-light mb-3",
           style = "max-width: 100rem;",
           tags$div(class = "card-header",
                    "Reference"),
           tags$div(class = "card-body",
                    tags$h5(class = "card-title",
                            "Twitter",
                    tags$i(class = "fab fa-twitter")),
                    
                    tags$p(class = "card-text",
                           "For Twitter, the number of tweets you search for, the user name, the time they were sent, and the number of thumb up recomments are all things the project need. Hereby, this project contains reference examples from Twitter, including Tweets, moments, and profiles.
",
                           br(),
                           a(href = "https://twitter.com/explore","https://twitter.com/explore"))), 
           tags$div(class = "card-body",
                    tags$h5(class = "card-title",
                            "Google Trends",
                            tags$i(class = "fab fa-google")),
                    tags$p(class = "card-text",
                           "Google Trends provides access to a largely unfiltered sample of actual search requests made to Google. It’s anonymized (no one is personally identified), 
                           categorized (determining the topic for a search query) and aggregated (grouped together). ",
                           br(),
                           a(href = "https://trends.google.com/trends/?geo=US","https://trends.google.com/trends/?geo=US"))),  
           tags$div(class = "card-body",
                    tags$h5(class = "card-title",
                            "Reddit",
                            tags$i(class = "fab fa-reddit")),
                    tags$p(class = "card-text",
                           "This project data visualization contains reference for posts and comments in online discussion forums on Reddit, such as Author of the Reddit post, Reddit screen name, 
                           Date of posting, Content of the caption and URL.",
                           br(),
                           a(href = "https://www.reddit.com/r/raddit/","https://www.reddit.com/r/raddit/")))
  ),
           )
          