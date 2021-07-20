

shinyServer(function(input, output, session) {
  router$server(input, output, session)
  
  global <-
    reactiveValues(
      keywordProvided = c(),
      displayKeyword = "",
      keywordSet = FALSE,
      GoogleData = NULL,
      TwitterData1 = NULL,
      RedditData1 = NULL,
      TwitterData2 = NULL,
      RedditData2 = NULL,
      loadFlag = FALSE
    )
  
  redditProcessed <- reactiveValues(
    textData = NULL,
    cleanStemmedText = NULL,
    sentimentData = NULL
  )
  
  observeEvent(input$setKeyword, {
    show_modal_spinner(
      spin = "breeding-rhombus",
      color = "firebrick",
      text = paste(
        "Please wait...",
        "We are collecting and processing data",
        sep = " | "
      )
    )
    global$displayKeyword <-  updateKeywordText()
    getGoogle()
    getTwitter()
    getReddit()
    
    preProcessData()
    
    global$keywordSet = TRUE
    remove_modal_spinner()
  })
  
  updateKeywordText <- function() {
    if (input$demoMode == TRUE) {
      global$keywordProvided = input$keywordSelect
      if (length(global$keywordProvided) == 1) {
        print(input$keywordSelect)
        # source(load)
        load(paste(
          "./demo_data/",
          global$keywordProvided[1],
          ".RData",
          sep = ""
        ))
        global$GoogleData <- google
        global$TwitterData1 <- twitter
        global$RedditData1 <- reddit
      }
    } else {
      temp = str_split(input$keywords, ',', n = 2)[[1]]
      # print(temp)
      global$keywordProvided = temp
    }
    rt <- "Not Provided"
    if (length(global$keywordProvided) > 0) {
      rt = paste(global$keywordProvided, ", ")
    }
    rt
  }
  
  preProcessData <- function() {
    copyData <- global$RedditData1
    # lexicon_nrc(dir = "./dataCache", manual_download = TRUE)
    data("stop_words")
    redditProcessed$textData <- copyData %>%
      select(c(uniqueID, comment, title, post_text)) %>%
      unite(allText, -1) %>%
      mutate(allText = gsub(allText, pattern = "http\\S+\\s*", replacement = "")) %>%
      mutate(allText = gsub(allText, pattern = "<.*?>", replacement = "")) %>%
      mutate(allText = gsub(allText, pattern = "[0-9]+|[[:punct:]]|\\(.*\\)", replacement = ""))
    
    redditProcessed$cleanStemmedText <- redditProcessed$textData %>%
      unnest_tokens(input = allText, output = word) %>%
      anti_join(stop_words)
    
    redditProcessed$sentimentData <- copyData %>%
      select(c(uniqueID, post_date, comm_date)) %>%
      merge(redditProcessed$cleanStemmedText, all = TRUE) %>%
      inner_join(get_sentiments("nrc"), by = "word") %>%
      as_tibble()
  }
  
  
  getGoogle <- function() {
    if (input$demoMode == TRUE) {
      if (length(global$keywordProvided) == 2) {
        
      }
      if (length(global$keywordProvided) == 1) {
        
      }
    } else {
      if (length(global$keywordProvided) == 2 &&
          !("" %in% global$keywordProvided)) {
        
      }
      if (length(global$keywordProvided) == 1 &&
          !("" %in% global$keywordProvided)) {
        kw <- global$keywordProvided[1]
        print("getting data")
        global$GoogleData <- getGoogleTrendData(kw)
      }
    }
  }
  
  getTwitter <- function() {
    if (input$demoMode == TRUE) {
      if (length(global$keywordProvided) == 2) {
        
      }
      if (length(global$keywordProvided) == 1) {
        
      }
    } else {
      if (length(global$keywordProvided) == 2 &&
          !("" %in% global$keywordProvided)) {
        
      }
      if (length(global$keywordProvided) == 1 &&
          !("" %in% global$keywordProvided)) {
        kw <- global$keywordProvided[1]
        print("getting data")
        global$TwitterData1 <- getTwitterData(kw)
      }
    }
  }
  
  getReddit <- function() {
    if (input$demoMode == TRUE) {
      if (length(global$keywordProvided) == 2) {
        
      }
      if (length(global$keywordProvided) == 1) {
        
      }
    } else {
      if (length(global$keywordProvided) == 2 &&
          !("" %in% global$keywordProvided)) {
        
      }
      if (length(global$keywordProvided) == 1 &&
          !("" %in% global$keywordProvided)) {
        kw <- global$keywordProvided[1]
        print("getting data")
        global$RedditData1 <- getRedditData(kw)
      }
    }
  }
  
  
  ### gtrend
  
  output$gtrendTimeHit <- renderPlotly({
    p <- ggplot(global$GoogleData$interest_over_time) +
      geom_line(aes(x = date, y = hits))
    
    p %>%
      ggplotly()
  })
  
  output$gtrendMapdeck <- renderMapdeck({
    m <- mapdeck(
      style = mapdeck_style('dark'),
      location = c(-76.590001, 39.290001),
      zoom = 0,
      pitch = 0,
      bearing = 0
    )
    # flag <- !l$loadFlag
    global$loadFlag = TRUE
    m
  })
  
  observeEvent(global$loadFlag, {
    req(global$loadFlag)
    
    sf <- geojson_sf("./www/us-states.json")
    
    new_sf <- sf %>%
      merge(
        global$GoogleData$interest_by_region %>% select(c(location, hits)),
        by.x = 'name',
        by.y = 'location',
        all = TRUE
      ) %>%
      select(-c(density)) %>%
      mutate(hits_scale = hits * 10) %>%
      mutate(info = paste("<b>", name, " - ", hits, "</b><br>")) %>%
      st_as_sf()
    
    mapdeck_update(map_id = "gtrendMapdeck") %>%
      mapdeck_view(
        location = c(-90.590001, 40.290001),
        zoom = 2.5,
        pitch = 40,
        # bearing = -45,
        duration = 5000,
        transition = "fly"
      ) %>%
      add_polygon(
        data = new_sf,
        fill_colour = "hits",
        elevation_scale = 1000,
        elevation = "hits_scale",
        tooltip = "info",
        legend = TRUE,
        legend_format = list(fill_colour = as.integer),
        update_view = FALSE
      )
  })
  
  output$gtrendDT <- renderDataTable({
    dfName <- input$gtrendDataSelect
    df <- switch (
      dfName,
      "interest_over_time" = global$GoogleData$interest_over_time,
      "interest_by_country" = global$GoogleData$interest_by_country,
      "interest_by_region" = global$GoogleData$interest_by_region,
      "interest_by_dma" = global$GoogleData$interest_by_dma,
      "interest_by_city" = global$GoogleData$interest_by_city,
      "related_topics" = global$GoogleData$related_topics,
      "related_queries" = global$GoogleData$related_queries
    )
    df
  })
  
  
  ### twitter
  
  output$twitterWC1 <- renderWordcloud2({
    colors = c('red', 'blue', 'green', 'yellow', 'purple')
    rankingtwitter <- global$TwitterData1 %>%
      select(c(1, 3))
    rkt <- rankingtwitter %>% arrange(desc(favoriteCount))
    rkt <- rkt %>% mutate(text = gsub('http\\S+\\s*', "", text))
    
    wordcloud2(
      rkt,
      size = 2,
      minRotation = -pi / 2,
      maxRotation = -pi / 2
    )
  })
  
  output$twitterHourPost <- renderPlotly({
    d <- global$TwitterData1
    
    d$created = ymd_hms(d$created, tz = 'Asia/Jakarta')
    d$date = date(d$created)
    d$week = week(d$created)
    d$hour = hour(d$created)
    d$month = month(d$created)
    
    # d.day.week1 = data.frame(table(d$date))
    # colnames(d.day.week1)[1] <- "Days"
    # colnames(d.day.week1)[2] <- "Total.Tweets"
    # d.week.month1 = data.frame(table(d$week))
    # colnames(d.week.month1)[1] <- "Weeks"
    # colnames(d.week.month1)[2] <- "Total.Tweets"
    d.hour.date1 = data.frame(table(d$hour))
    colnames(d.hour.date1) = c('Hour', 'Total.Tweets')
    
    p <- ggplot(d.hour.date1) +
      geom_bar(
        aes(
          x = Hour,
          y = Total.Tweets,
          fill = I('blue')
        ),
        stat = 'identity',
        alpha = 0.75,
        show.legend = FALSE
      ) +
      geom_hline(
        yintercept = mean(d.hour.date1$Total.Tweets),
        col = I('black'),
        size = 1
      ) +
      geom_text(
        aes(
          fontface = 'italic',
          label = paste('Average:',
                        ceiling(mean(
                          d.hour.date1$Total.Tweets
                        )),
                        'Tweets per hour'),
          x = 8,
          y = mean(d.hour.date1$Total.Tweets) + 20
        ),
        hjust = 'left',
        size = 4
      ) +
      labs(title = 'Total Tweets per Hours '
           ) +
           xlab('Time of Day') +
             ylab('Total Tweets') +
             scale_fill_brewer(palette = 'Dark2') +
             theme_bw()
           p %>% ggplotly()
  })
    
    output$twitterWeekPost <- renderPlotly({
      d <- global$TwitterData1
      
      d$created = ymd_hms(d$created, tz = 'Asia/Jakarta')
      d$date = date(d$created)
      d$week = week(d$created)
      d$hour = hour(d$created)
      d$month = month(d$created)
      
      d.day.week1 = data.frame(table(d$date))
      colnames(d.day.week1)[1] <- "Days"
      colnames(d.day.week1)[2] <- "Total.Tweets"
      # d.week.month1 = data.frame(table(d$week))
      # colnames(d.week.month1)[1] <- "Weeks"
      # colnames(d.week.month1)[2] <- "Total.Tweets"
      # d.hour.date1 = data.frame(table(d$hour))
      # colnames(d.hour.date1) = c('Hour', 'Total.Tweets')
      
      t <- ggplot(d.day.week1) +
        geom_bar(
          aes(
            x = Days,
            y = Total.Tweets,
            fill = I('blue')
          ),
          stat = 'identity',
          alpha = 0.75,
          show.legend = FALSE
        ) +
        geom_hline(
          yintercept = mean(d.day.week1$Total.Tweets),
          col = I('black'),
          size = 1
        ) +
        geom_text(
          aes(
            fontface = 'italic',
            label = paste('Average:',
                          ceiling(mean(
                            d.day.week1$Total.Tweets
                          )),
                          'Tweets per Day'),
            x = 8,
            y = mean(d.day.week1$Total.Tweets) + 20
          ),
          hjust = 'left',
          size = 4
        ) +
        labs(title = 'Total Tweets per Days ') +
             xlab('Day of Week') +
               ylab('Total Tweets') +
               scale_fill_brewer(palette = 'Dark2') +
               theme_bw()
             t %>% ggplotly()
    })
      
      output$twitterSentiment <- renderPlot({
        data <- global$TwitterData1
        
        data("stop_words")
        tidy_tweets <- tibble(
          screen_name = data$screenName,
          tweetid = data$id,
          created_timestamp = data$created,
          is_retweet = data$isRetweet,
          text = data$text
        ) %>%
          mutate(created_date = as.Date(created_timestamp)) %>%
          filter(is_retweet == FALSE,
                 substr(text, 1, 2) != "RT")
        
        tweet_words <- tidy_tweets %>%
          select(tweetid,
                 screen_name,
                 text,
                 created_date) %>%
          unnest_tokens(word, text)
        
        my_stop_words <- tibble(
          word = c("https",
                   "t.co",
                   "rt",
                   "amp",
                   "rstats",
                   "gt"),
          lexicon = "twitter"
        )
        all_stop_words <- stop_words %>%
          bind_rows(my_stop_words)
        
        suppressWarnings({
          no_numbers <- tweet_words %>%
            filter(is.na(as.numeric(word)))
        })
        
        no_stop_words <- no_numbers %>%
          anti_join(all_stop_words, by = "word")
        
        nrc_words <- no_stop_words %>%
          inner_join(get_sentiments("nrc"), by = "word")
        
        ggplot(nrc_words) +
          geom_joy(
            aes(x = created_date,
                y = sentiment,
                fill = sentiment),
            rel_min_height = 0.01,
            alpha = 0.7,
            scale = 3
          ) +
          theme_joy() +
          labs(title = "Twitter sentiment analysis",
               x = "Tweet Date",
               y = "Sentiment") +
          scale_fill_discrete(guide = FALSE)
        
      })
      
      output$twitterDT <- renderDataTable({
        global$TwitterData1
      })
      
      ### reddit
      
      # output$reddit3d1 <- renderPlotly({
      #   # plots$reddit3d1
      #   # get(global$RedditData1)
      #   copyData <- global$RedditData1
      #   # glimpse(copyData)
      #   fig <- copyData %>%
      #     # filter(controversiality > 0) %>%
      #     plot_ly(
      #       x = ~ post_score,
      #       y = ~ num_comments,
      #       z = ~ comment_score,
      #       color = ~ upvote_prop,
      #       hovertemplate = ~ paste(
      #         "<br>post_score: ",
      #         post_score,
      #         "<br>num_comments: ",
      #         num_comments,
      #         "<br>comment_score: ",
      #         comment_score,
      #         "<br>upvote_prop: ",
      #         upvote_prop,
      #         "<br>controversiality: ",
      #         controversiality,
      #         "<br>---Comment---<br>",
      #         comment,
      #         '<extra></extra>'
      #       )
      #     ) %>% add_markers() 
      #   # %>%
      #     # layout(scene = list(
      #     #   camera = list(eye = list(
      #     #     x = 3, y = 0.88, z = 0.64
      #     #   )),
      #     #   aspectratio = list(x = 1, y = 1, z = 1.75)
      #     # ))
      #   fig
      # })
      
      output$reddit3D2 <- renderPlotly({
        copyData <- global$RedditData1
        redditProcessed$cleanStemmedText %>%
          group_by(uniqueID) %>%
          count(word) %>%
          ungroup() -> countTbl
        
        tfidfTbl <- countTbl %>%
          bind_tf_idf(word, document = uniqueID , n)
        
        tfidfTbl <- tfidfTbl %>%
          merge(copyData %>% select(c(uniqueID, upvote_prop)), all = TRUE) %>%
          as_tibble()
        
        tfidfFig <- tfidfTbl %>%
          filter(n > 2) %>%
          plot_ly(
            x = ~ tf,
            y = ~ idf,
            z = ~ tf_idf,
            color = ~ upvote_prop,
            hovertemplate = ~ paste(
              "<br>uniqueID: ",
              uniqueID,
              "<br>tf: ",
              tf,
              "<br>idf: ",
              idf,
              "<br>tf_idf: ",
              tf_idf,
              "<br>n: ",
              n,
              "<br>upvote_prop: ",
              upvote_prop,
              "<br>word: ",
              word,
              '<extra></extra>'
            )
          ) %>%
          add_markers() %>%
          layout(scene = list(camera = list(eye = list(
            x = -2, y = 0.88, z = 1
          ))))
        tfidfFig
      })
      
      output$redditSentimentJoy <- renderPlot({
        p <- redditProcessed$sentimentData %>%
          ggplot() +
          geom_joy(
            aes(x = comm_date, y = sentiment, fill = sentiment),
            rel_min_height = 0.01,
            alpha = 0.7,
            scale = 3
          ) +
          theme_joy() +
          scale_fill_discrete(guide = FALSE)
        
        p
      })
      
      # output$redditSentimentViolin <- renderPlotly({
      #   # req(global$RedditData1)
      #   
      #   violinP <- redditProcessed$sentimentData %>%
      #     group_by(uniqueID, sentiment) %>%
      #     tally() %>%
      #     ungroup() %>%
      #     plot_ly(
      #       y = ~ n,
      #       x = ~ sentiment,
      #       split = ~ sentiment,
      #       type = 'violin',
      #       box = list(visible = T),
      #       meanline = list(visible = T)
      #     )
      #   violinP
      # })
      
      output$redditSentimentRadar <- renderPlotly({
        copyData <- global$RedditData1
        
        averageSentiment <- redditProcessed$sentimentData %>%
          group_by(sentiment) %>%
          tally() %>%
          mutate(n = n / nrow(copyData))
        
        allSent <-
          redditProcessed$sentimentData %>% distinct(sentiment)
        
        id <- 1000
        
        redditProcessed$sentimentData %>%
          group_by(uniqueID, sentiment) %>%
          tally() %>%
          filter(uniqueID == id) %>%
          right_join(allSent) %>%
          mutate(uniqueID = id) %>%
          mutate(n = coalesce(n, 0)) -> radarData
        
        radarData %>%
          plot_ly(type = 'scatterpolar',
                  mode = 'markers',
                  fill = 'toself') %>%
          add_trace(
            theta = ~ sentiment,
            r = ~ averageSentiment$n,
            name = 'Average Sentiment',
            hovertemplate = ~ paste(
              "Sentiment: ",
              sentiment,
              "<br>n: ",
              averageSentiment$n,
              '<extra></extra>'
            )
          ) %>%
          add_trace(
            theta = ~ sentiment,
            r = ~ n,
            name = ~ paste("Comment ID: ", uniqueID),
            hovertemplate = ~ paste("Sentiment: ", sentiment, "<br>n: ", n, '<extra></extra>')
          ) %>%
          layout(polar = list(radialaxis = list(visible = T)))
      })
      
      output$redditWordCloud <- renderWordcloud2({
        excludeWords <- c("just", "get")
        
        v <- redditProcessed$textData$allText %>%
          VectorSource %>%
          Corpus %>%
          tm_map(content_transformer(tolower)) %>%
          # Remove numbers
          tm_map(removeNumbers) %>%
          # Remove english common stopwords
          tm_map(removeWords, stopwords("english")) %>%
          # Remove your own stop word
          # specify your stopwords as a character vector
          tm_map(removeWords, excludeWords) %>%
          # Remove punctuations
          tm_map(removePunctuation) %>%
          # Eliminate extra white spaces
          tm_map(stripWhitespace) %>%
          # Text stemming
          tm_map(stemDocument) %>%
          TermDocumentMatrix %>%
          as.matrix %>%
          rowSums  %>%
          sort(decreasing = TRUE)
        d <- data.frame(word = names(v),
                        freq = v,
                        stringsAsFactors = FALSE)
        # glimpse(d)
        
        d %>%
          wordcloud2()
        
      })
      
      output$redditDT <- renderDataTable({
        global$RedditData1 %>% select(-c(post_text))
      })
})
    