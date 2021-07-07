library(shiny)
library(tm)
library(wordcloud2)
library(tidyverse)
library(rvest)
library(SnowballC)
library(twitteR) #To get tweets from twitter
library(syuzhet)

n <- 1.5

ui <- bootstrapPage(
  titlePanel("Real Time Sentiment Analysis: Mail Marketing & Phone Marketing"),
  sidebarPanel(
    sliderInput(
      "num",
      "Number of Tweets to Capture",
      value = 300,
      min = 100,
      max = 1000
    ),
    selectInput(
      inputId = "background",
      label = "Background Color",
      choices = c("black", "white", "grey", "#EFF0B2"),
      selected = "white"
    ),
    
    numericInput('size', 'Size of wordcloud', n),
  ),
  mainPanel(
    wordcloud2Output('wordcloud2', height = "800px", width = "800px")
  )
)



server <- function(input, output) {
  ts <- function(bkg, sz, num) {
    #### Paste your functions below
    consumer_key <- "kM2ovH4HAywQNm0urZ3JhiSAN"
    consumer_secret <-
      "8y7yecosygXFJbIk6iKSel9IqrDNpycbZcrKTwLx90icnwdUeK"
    access_token <-
      "738365281773359109-kt0VjlZpGaau7XoZu7nkk7hRl32wf3F"
    access_secret <- "dhSDsmP9AGx8aEXO7bCrSAx08VUPQRux4WFrg9q0AFVSD"
    
    # Connect to twitter
    options(httr_oauth_cache = T)
    setup_twitter_oauth(consumer_key,
                        consumer_secret,
                        access_token,
                        access_secret)
    
    hashtag = c("junkmail", "crankcall")
    numwords = num
    # Save the query on a dataframe named rt_subset
    rt_subset = searchTwitter(hashtag, n = numwords, lang = "en") %>%
      strip_retweets %>% twListToDF
    
    # Find the frequency of each word and store it on dataframe d
    v <- rt_subset$text %>%
      VectorSource %>%
      Corpus %>%
      TermDocumentMatrix %>%
      as.matrix %>%
      rowSums  %>%
      sort(decreasing = TRUE)
    d <- data.frame(word = names(v),
                    freq = v,
                    stringsAsFactors = FALSE)
    
    head(d, 20)
    
    ###Visualize dataframe d with wordcloud package
    minFreq = 10
    maxWords = 70
    frequency = d$freq
    frequency = round(sqrt(d$freq), 0)
    
    ### Let's come back and edit the raw tweets
    myWords = c("can",
                "just",
                "one",
                "think",
                "like",
                "get",
                "see",
                "will",
                "'",
                "yes,",
                "trump")
    v <- rt_subset$text %>%
      VectorSource %>%
      Corpus %>%
      # Convert the text to lower case
      tm_map(content_transformer(tolower)) %>%
      # Remove numbers
      tm_map(removeNumbers) %>%
      # Remove english common stopwords
      tm_map(removeWords, stopwords("english")) %>%
      # Remove your own stop word
      # specify your stopwords as a character vector
      tm_map(removeWords, myWords) %>%
      # Remove punctuations
      tm_map(removePunctuation) %>%
      # Eliminate extra white spaces
      tm_map(stripWhitespace) %>%
      # Text stemming
      tm_map(stemDocument) %>%
      TermDocumentMatrix %>%
      as.matrix %>%
      rowSums %>%
      sort(decreasing = TRUE)
    
    d <- data.frame(word = names(v),
                    freq = v,
                    stringsAsFactors = FALSE)
    sentiments = get_sentiment(d$word)
    NNWords = d %>%
      mutate(sentRes = sentiments) %>%
      filter(sentRes != 0) %>%
      mutate(color = case_when(sentRes < 0 ~ "red", sentRes > 0 ~ "green"))
    ### We can also use transparency to show the level of sentiment
    head(NNWords, n = 2)
    for (i in 1:nrow(NNWords)) {
      curRate = NNWords$sentRes[i]
      if (curRate < 0) {
        NNWords$color[i] = rgb(
          red = 179 / 255,
          green = 5 / 255,
          blue = 9 / 255,
          alpha = -curRate
        )
      }
      else{
        NNWords$color[i] = rgb(
          red = 3 / 255,
          green = 89 / 255,
          blue = 12 / 255,
          alpha = curRate
        )
      }
    }
    wordcloud2(
      NNWords,
      size = sz,
      color = NNWords$color,
      backgroundColor = bkg,
      minRotation = -pi / 6,
      maxRotation = -pi / 6,
      rotateRatio = 1,
      fontWeight = "bold"
    )
  }
  
  ##### Paste your functions above
  output$wordcloud2 <- renderWordcloud2({
    ts(input$background, input$size, input$num)
  })
}



shinyApp(ui = ui, server = server)
