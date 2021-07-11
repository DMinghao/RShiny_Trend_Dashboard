if(!require(RedditExtractoR)) {
  install.packages("RedditExtractoR")
}
if(!require(tidytext)) {
  install.packages("tidytext")
}
if(!require(textdata)) {
  install.packages("textdata")
}
library(RedditExtractoR)
library(plotly)
library(tidyverse)
library(tm)
library(tidytext)
library(textdata)

getRedditData <- function(keyword, subreddit = NA, sort_by = "comments") {
  if (length(keyword) > 1) {
    return(NULL)
  }
  
  page_threshold <- 0
  cn_threshold <- 0
  
  sort_by %>% switch ("new" = {
    page_threshold <<- 10
    cn_threshold <<- 0
  },
  "comments" = {
    page_threshold <<- 1
    cn_threshold <<- 50
  },
  "relevance" = {
    page_threshold <<- 5
    cn_threshold <<- 10
  })
  
  get_reddit(
    search_terms = keyword,
    regex_filter = "",
    subreddit = subreddit,
    cn_threshold = cn_threshold,
    page_threshold = page_threshold,
    sort_by = sort_by
  )
}

keyword <- "covid"

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
as_tibble()

summary(copyData)
glimpse(copyData)

copyData %>%
  select(link) %>%
  unique() -> uniqueThreads

userNetPlot <- copyData %>%
  filter(link == uniqueThreads[1,]) %>%
  user_network(agg = TRUE)

userNetPlot$plot


fig <- copyData %>% plot_ly(
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
      x = 1.87, y = 0.88, z = 0.64
    )),
    aspectratio = list(x = 1, y = 1, z = 1.75)
  ))
fig




newData <- copyData %>%
  select(c(id, comment_score, controversiality, comment, title)) %>%
  arrange(comment_score)

newData %>% glimpse()

excludeWords <- c("just", "like", "get", "think")

v <- newData$comment %>%
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
