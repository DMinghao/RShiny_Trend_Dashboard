home_page <- div(class = "container",
  tags$div(class = "card text-center",
                          tags$div(class = "card-body",
                                  
                 body <- div(
                   fluidRow(
                   box(
                   title = "Introduction", solidHeader = TRUE,
                   class = "black", width = 12, collapsible = TRUE, 
                   column(12, 
                          tags$div(
                            tags$span(
                              "People use the Internet and their portal devices almost anywhere and anytime over the world nowadays. According to research, those searching for information on google.com spent 10:56 minutes on an average session. As we can learn so much useful information from those searching actions--",tags$strong("user behaviors"), 
                              ",we have created a comprehensive Internet ", tags$strong("trend"), " exploration dashboard in order to help researchers, decision makers and marketing experts explore, identify and evaluate popular keywords related to their interests.Basically we applied three main data sources including:", style = "font-size:16px"),
                            
                            br(),br(),          
                            tags$a(href = "https://trends.google.com/trends/?geo=US",
                                   class = "btn btn-primary",
                                   "Googletrends",style = "font-size:16px"),
                            
                            tags$a(href = "https://twitter.com/explore",
                                   class = "btn btn-primary",
                                   "Twitter",style = "font-size:16px"),
                            tags$a(href = "https://www.reddit.com/r/raddit/",
                                   class = "btn btn-primary",
                                   "Reddit",style = "font-size:16px"),style = "font-size:16px"),
                        
                            br(),
                            tags$span("In order to learn how people interacted with hot issues or breaking news. With our webpage, whoever is interested in user's searching pattern can easily get what he need by simply typing down the keywords, such as the keyword's trendiness throughout different times and locations, identifying the most popular keyword among a set of words as well as user's sentiment analysis towards the keywords, etc. 
"),
                          
     )))))),
  
  div(fluidPage(
    sidebarLayout(
      sidebarPanel(
        br(),
        tags$div(id = "carouselExampleIndicators",
                 class = "carousel slide",
                 "data-ride" = "carousel",
                 tags$ol(class = "carousel-indicators",
                         tags$li("data-target" = "#carouselExampleIndicators",
                                 "data-slide-to" = "0",
                                 class = "active"),
                         tags$li("data-target" = "#carouselExampleIndicators",
                                 "data-slide-to" = "1"),
                         tags$li("data-target" = "#carouselExampleIndicators",
                                 "data-slide-to" = "2")),
                 tags$div(class = "carousel-inner",
                          tags$div(class = "carousel-item active",
                                   tags$img(src = "./WechatIMG9946.png",
                                            height = 400, width = 400,
                                            class = "d-block w-100",
                                            alt = "...")),
                          tags$div(class = "carousel-item",
                                   tags$img(src = "./97.png",
                                            height = 400, width = 400,
                                            class = "d-block w-100",
                                            alt = "...")),
                          tags$div(class = "carousel-item",
                                   tags$img(src = "./3.png",
                                            height = 400, width = 400,
                                            class = "d-block w-100",
                                            alt = "..."))),
                 tags$a(class = "carousel-control-prev",
                        href = "#carouselExampleIndicators",
                        role = "button",
                        "data-slide" = "prev",
                        tags$span(class = "carousel-control-prev-icon",
                                  "aria-hidden" = "true"),
                        tags$span(class = "sr-only",
                                  "Previous")),
                 tags$a(class = "carousel-control-next",
                        href = "#carouselExampleIndicators",
                        role = "button",
                        "data-slide" = "next",
                        tags$span(class = "carousel-control-next-icon",
                                  "aria-hidden" = "true"),
                        tags$span(class = "sr-only",
                                  "Next")))
      ),
      mainPanel(
        tags$div(class = "card text-center",
                 style = "max-width: 100rem;",
                 tags$div(class = "card-header", 
                          "Methodology"),
                 tags$div(class = "card-body", 
                          tags$p(class = "card-title",
                                 "Worldcloud"),
                          tags$p(class = "card-text",
                                 "worldcloud methoud is used to visualize the most frequent words.In the wordcloud visualization, color and size of each word represents its frequency")),
                 tags$div(class = "card-body",
                          tags$p(class = "card-title",
                                 "Ggplot Plotly"),
                          tags$p(class = "card-text",
                                 "In Twitter, we use ggplot to display the number of tweets for a particular hour, day, week, and month to show the popularity of the search term. In gtends, it is also used to show entry heat, trendline. What's more, we also use ggplot to do a sentiment analysis, to figure out the respond of people to vocabulary.For using plotly, it provides more specific data in graph ")),
                 tags$div(class = "card-body",
                          tags$p(class = "card-title",
                                 "Text Mining"),
                          tags$p(class = "card-text",
                                 "In the dashboard page, using text mining methods, we extract the frequency of each word."))
        )
      )
    )
  )),
  tags$div(class = "card text-center",
           tags$div(class = "card-body",
                    
                    body <- div(
                      fluidRow(
                        box(
                          title = "Video Presentation", solidHeader = TRUE,
                          class = "black", width = 12, collapsible = TRUE, 
                          column(12, 
                                 tags$div(class = "embed-responsive embed-responsive-16by9",
                                          tags$iframe(width = "1353",
                                                      height = "627",
                                                      src = "https://www.youtube.com/embed/TsVq9gevHPc",
                                                      title = "YouTube video player",
                                                      frameborder = "0",
                                                      allow = "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture",
                                                      allowfullscreen = NA)
                                          )
                          )))))),

  
 
  )


