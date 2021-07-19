if(!require(RedditExtractoR)) {
  install.packages("RedditExtractoR")
}
if (!require(tidytext)) {
  install.packages("tidytext")
}
if (!require(textdata)) {
  install.packages("textdata")
}
if (!require(RTextTools)) {
  install.packages("RTextTools")
}
if (!require(ggridges)) {
  install.packages("ggridges")
}
if (!require(dplyr)) {
  install.packages("dplyr")
}
install.packages("plyr")           # Install & load plyr
library(plyr)
library(RedditExtractoR)
library(plotly)
library(tidyverse)
library(tm)
library(tidytext)
library(textdata)
library(RTextTools)
library(ggplot2)
library(ggridges)
library(ggjoy)
library(wordcloud2)
library(dplyr)

getRedditData <- function(keyword,
                          subreddit = NA,
                          sort_by = "comments") {
  if (length(keyword) > 1) {
    return(NULL)
  }
  
  page_threshold <- sort_by %>%
    switch ("new" = 3,
            "comments" = 1,
            "relevance" = 1)
  
  get_reddit(
    search_terms = keyword,
    regex_filter = "",
    subreddit = subreddit,
    cn_threshold = 0,
    page_threshold = page_threshold,
    sort_by = sort_by
  )
}

keyword <- "data science"

data <- getRedditData(keyword)

# get_sentiments(c("bing", "afinn", "loughran", "nrc"))
# get_sentiments("bing")
# get_sentiments("afinn")
# get_sentiments("loughran")
wordDict <- get_sentiments("nrc")

dictFactor <- wordDict %>% mutate(sentiment = as.factor(sentiment))

dictFactor %>% select(sentiment) %>% unique()

glimpse(data)

copyData <- data

copyData <- copyData %>%
  mutate(post_date = as.Date(post_date, "%d-%m-%y")) %>%
  mutate(comm_date = as.Date(comm_date, "%d-%m-%y")) %>%
  mutate(subreddit = as.factor(subreddit)) %>%
  mutate(uniqueID = row_number()) %>%
  as_tibble()

summary(copyData)
glimpse(copyData)

data("stop_words")
textData <- copyData %>%
  select(c(uniqueID, comment, title, post_text)) %>%
  unite(allText, -1) %>%
  mutate(allText = gsub(allText, pattern = "http\\S+\\s*", replacement = "")) %>%
  mutate(allText = gsub(allText, pattern = "<.*?>", replacement = "")) %>%
  mutate(allText = gsub(allText, pattern = "[0-9]+|[[:punct:]]|\\(.*\\)", replacement = ""))






### user network

copyData %>%
  select(title) %>%
  unique() -> uniqueThreads

userNetPlot <- copyData %>%
  filter(title == uniqueThreads[1,]) %>%
  user_network(agg = TRUE)

# userNetPlot$plot






### 3d scatter

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





### Text mining tf, idf


textData %>%
  unnest_tokens(input = allText, output = word) %>%
  anti_join(stop_words) -> cleanStemmedText

cleanStemmedText %>%
  count(word) %>%
  arrange(desc(n))

cleanStemmedText %>%
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







### sentiment
###

sentimentData <- copyData %>%
  select(c(uniqueID, post_date, comm_date)) %>%
  merge(cleanStemmedText, all = TRUE) %>%
  inner_join(get_sentiments("nrc"), by = "word") %>%
  as_tibble()

glimpse(sentimentData)

sentimentData %>%
  group_by(sentiment) %>%
  tally() %>%
  arrange(desc(n))

sentimentData %>% group_by(comm_date) %>% count()

p <- sentimentData %>%
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

violinP <- sentimentData %>%
  group_by(uniqueID, sentiment) %>%
  tally() %>%
  ungroup() %>%
  plot_ly(
    y = ~ n,
    x = ~ sentiment,
    split = ~ sentiment,
    type = 'violin',
    box = list(visible = T),
    meanline = list(visible = T)
  )
violinP

averageSentiment <- sentimentData %>%
  group_by(sentiment) %>%
  tally() %>%
  mutate(n = n / nrow(copyData))

allSent <- sentimentData %>% distinct(sentiment)

id <- 1000

sentimentData %>%
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





### word count
###

excludeWords <- c("just", "get")

v <- textData$allText %>%
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
glimpse(d)

d %>%
  wordcloud2()

