if (!require(shiny.router)) {
  install.packages("shiny.router")
}
if (!require(stringr)) {
  install.packages("stringr")
}
if (!require(DT)) {
  install.packages("DT")
}
library(shiny)
library(stringr)
library(DT)
library(ggjoy)
library(shinyjs)

source("getDataFunc.R")


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
      RedditData2 = NULL
    )
  
  resetGlobal <- function(){
    global$keywordProvided = c()
    global$displayKeyword = ""
    global$keywordSet = FALSE
    global$GoogleData = NULL
    global$TwitterData1 = NULL
    global$RedditData1 = NULL
    global$TwitterData2 = NULL
    global$RedditData2 = NULL
  }
  
  observeEvent(input$setKeyword, {
    hide("setKeyword")
    
    global$displayKeyword <-  updateKeywordText()
    getGoogle()
    getTwitter()
    getReddit()
    
    global$keywordSet = TRUE
    # show("resetKeyword") 
  })
  
  # observeEvent(input$resetKeyword, {
  #   hide("resetKeyword")
  #   resetGlobal()
  #   updateTextInput(session, "keywords", value = "")
  #   updateSelectInput(session, "keywordSelect", selected = NULL)
  #   
  #   global$keywordSet = FALSE
  #   show("setKeyword") 
  # })
  # 
  # observeEvent(input$getGoogle, {
  #   getGoogleData()
  # })
  
  updateKeywordText <- function() {
    if (input$demoMode == TRUE) {
      global$keywordProvided = input$keywordSelect
      # print(input$keywordSelect)
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
  
  
  
  getGoogle <- function() {
    if (input$demoMode == TRUE) {
      
    } else {
      if (length(global$keywordProvided) == 2 &&
          !("" %in% global$keywordProvided)) {
        
      }
      if (length(global$keywordProvided) == 1 &&
          !("" %in% global$keywordProvided)) {
        kw <- global$keywordProvided[1]
        print("getting data")
        global$GoogleData <- getGoogleTrendData(kw)
        # global$TwitterData1 <- getTwitterData(kw)
        # global$RedditData1 <- getRedditData(kw)
      }
    }
  }
  
  getTwitter <- function() {
    if (input$demoMode == TRUE) {
      
    } else {
      if (length(global$keywordProvided) == 2 &&
          !("" %in% global$keywordProvided)) {
        
      }
      if (length(global$keywordProvided) == 1 &&
          !("" %in% global$keywordProvided)) {
        kw <- global$keywordProvided[1]
        print("getting data")
        # global$GoogleData <- getGoogleTrendData(kw)
        global$TwitterData1 <- getTwitterData(kw)
        # global$RedditData1 <- getRedditData(kw)
      }
    }
  }
  
  getReddit <- function() {
    if (input$demoMode == TRUE) {
      
    } else {
      if (length(global$keywordProvided) == 2 &&
          !("" %in% global$keywordProvided)) {
        
      }
      if (length(global$keywordProvided) == 1 &&
          !("" %in% global$keywordProvided)) {
        kw <- global$keywordProvided[1]
        print("getting data")
        # global$GoogleData <- getGoogleTrendData(kw)
        # global$TwitterData1 <- getTwitterData(kw)
        global$RedditData1 <- getRedditData(kw, sort_by = "new")
      }
    }
  }
  
  # output$keywordState <- renderText({
  #   global$displayKeyword
  # })
  
  
  ### gtrend
  
  output$gtrendTimeHit <- renderPlotly({
    p <- ggplot(global$GoogleData$interest_over_time) +
      geom_line(aes(x = date, y = hits))
    
    p %>%
      ggplotly()
  })
  
  output$gtrendMapdeck <- renderMapdeck({
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
    
    mapdeck(style = mapdeck_style('dark'),
            pitch = 45) %>%
      add_polygon(
        data = new_sf,
        fill_colour = "hits",
        elevation_scale = 1000,
        elevation = "hits_scale",
        tooltip = "info",
        legend = TRUE,
        legend_format = list(fill_colour = as.integer)
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
    
    d.day.week1 = data.frame(table(d$date))
    colnames(d.day.week1)[1] <- "Days"
    colnames(d.day.week1)[2] <- "Total.Tweets"
    d.week.month1 = data.frame(table(d$week))
    colnames(d.week.month1)[1] <- "Weeks"
    colnames(d.week.month1)[2] <- "Total.Tweets"
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
      labs(title = 'Total Tweets per Hours ',
           subtitle = '11 July 2021',
           caption = 'Twitter Crawling 10 - 11 July 2021') +
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
    d.week.month1 = data.frame(table(d$week))
    colnames(d.week.month1)[1] <- "Weeks"
    colnames(d.week.month1)[2] <- "Total.Tweets"
    d.hour.date1 = data.frame(table(d$hour))
    colnames(d.hour.date1) = c('Hour', 'Total.Tweets')
    
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
      labs(title = 'Total Tweets per Days ',
           subtitle = 'weeks 2021',
           caption = 'Twitter Crawling 10 - 11 July 2021') +
      xlab('Day of Week') +
      ylab('Total Tweets') +
      scale_fill_brewer(palette = 'Dark2') +
      theme_bw()
    t %>% ggplotly()
  })
  
  output$twitterMonthPost <- renderPlotly({
    d <- global$TwitterData1
    
    d$created = ymd_hms(d$created, tz = 'Asia/Jakarta')
    d$date = date(d$created)
    d$week = week(d$created)
    d$hour = hour(d$created)
    d$month = month(d$created)
    
    d.day.week1 = data.frame(table(d$date))
    colnames(d.day.week1)[1] <- "Days"
    colnames(d.day.week1)[2] <- "Total.Tweets"
    d.week.month1 = data.frame(table(d$week))
    colnames(d.week.month1)[1] <- "Weeks"
    colnames(d.week.month1)[2] <- "Total.Tweets"
    d.hour.date1 = data.frame(table(d$hour))
    colnames(d.hour.date1) = c('Hour', 'Total.Tweets')
    
    o <-ggplot(d.week.month1)+
      geom_bar(aes(x = Weeks,
                   y = Total.Tweets,
                   fill = I('blue')),
               stat = 'identity',
               alpha = 0.75,
               show.legend = FALSE)+
      geom_hline(yintercept = mean(d.week.month1$Total.Tweets),
                 col = I('black'),
                 size = 1)+
      geom_text(aes(fontface = 'italic',
                    label = paste('Average:',
                                  ceiling(mean(d.week.month1$Total.Tweets)),
                                  'Tweets per Week'),
                    x = 8,
                    y = mean(d.week.month1$Total.Tweets)+20),
                hjust = 'left',
                size = 4)+
      labs(title = 'Total Tweets per Week ',
           subtitle = 'Month 2021',
           caption = 'Twitter Crawling 10 - 11 July 2021')+
      xlab('Week of Month')+
      ylab('Total Tweets')+
      scale_fill_brewer(palette = 'Dark2')+
      theme_bw()
    o%>%ggplotly()
  })
  
  output$twitterSentiment <- renderPlot({
    data <- global$TwitterData1
    
    tidy_tweets <- tibble(
      screen_name = data %>% map_chr(~.x$screenName),
      tweetid = data %>% map_chr(~.x$id),
      created_timestamp = seq_len(length(data)) %>% map_chr(~as.character(data[[.x]]$created)),
      is_retweet = data %>% map_chr(~.x$isRetweet),
      text = data %>% map_chr(~.x$text)
    ) %>%
      mutate(created_date = as.Date(created_timestamp)) %>%
      filter(is_retweet == FALSE,
             substr(text, 1,2) != "RT")
    
    tweet_words <- tidy_tweets %>%
      select(tweetid,
             screen_name,
             text,
             created_date) %>%
      unnest_tokens(word, text)
    # tweet_words
    # stop_words  
    my_stop_words <- tibble(
      word = c(
        "https",
        "t.co",
        "rt",
        "amp",
        "rstats",
        "gt"
      ),
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
    
    tibble(
      total_words = nrow(tweet_words),
      after_cleanup = nrow(no_stop_words)
    )
    
    top_words <- no_stop_words %>%
      group_by(word) %>%
      tally %>%
      arrange(desc(n)) %>%
      head(10)
    
    
    nrc_words <- no_stop_words %>%
      inner_join(get_sentiments("nrc"), by = "word")
    
    # nrc_words %>%
    #   group_by(sentiment) %>%
    #   tally %>%
    #   arrange(desc(n))
    # nrc_words %>%
    #   group_by(tweetid) %>%
    #   tally %>%
    #   ungroup %>%
    #   count %>%
    #   pull
    
    
    ggplot(nrc_words) +
      geom_joy(aes(
        x = created_date,
        y = sentiment, 
        fill = sentiment),
        rel_min_height = 0.01,
        alpha = 0.7,
        scale = 3) +
      theme_joy() +
      labs(title = "Twitter #rstats sentiment analysis",
           x = "Tweet Date",
           y = "Sentiment") + 
      scale_fill_discrete(guide=FALSE)
    
  })
  
  output$twitterDT <- renderDataTable({
    global$TwitterData1
  })
  
  ### reddit
  
  output$reddit3d1 <- renderPlotly({
    copyData <- global$RedditData1
    
    fig <- copyData %>%
      # filter(controversiality > 0) %>%
      plot_ly(
        x = ~ post_score,
        y = ~ num_comments,
        z = ~ comment_score,
        color = ~ upvote_prop,
        hovertemplate = ~ paste(
          "<br>post_score: ",
          post_score,
          "<br>num_comments: ",
          num_comments,
          "<br>comment_score: ",
          comment_score,
          "<br>upvote_prop: ",
          upvote_prop,
          "<br>controversiality: ",
          controversiality,
          "<br>---Comment---<br>",
          comment,
          '<extra></extra>'
        )
      ) %>% add_markers() %>%
      layout(scene = list(
        camera = list(eye = list(
          x = 3, y = 0.88, z = 0.64
        )),
        aspectratio = list(x = 1, y = 1, z = 1.75)
      ))
    fig
  })
  
})
