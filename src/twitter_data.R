if(!require(twitteR)){
  install.packages("twitteR")
}

if(!require(tm)){
  install.packages("tm")
}

if(!require(syuzhet)){
  install.packages("syuzhet")
}

library(twitteR)
library(tm)
library(syuzhet)


readRenviron("./.Renviron")
consumer_key <- Sys.getenv("twitter_consumer_key")
consumer_secret <- Sys.getenv("twitter_consumer_secret")
access_token <- Sys.getenv("twitter_access_token")
access_secret <- Sys.getenv("twitter_access_secret")

# Connect to twitter
setup_twitter_oauth(consumer_key,
                    consumer_secret,
                    access_token,
                    access_secret)

hashtag = "trump"
numwords = 500
# Save the query on a dataframe named rt_subset
rt_subset = searchTwitter(
  hashtag,
  n = numwords,
  lang = "en",
  since = NULL,
  until = NULL,
  locale = NULL,
  geocode = NULL,
  sinceID = NULL,
  maxID = NULL,
  resultType = NULL,
  retryOnRateLimit = 120
) %>% strip_retweets %>% twListToDF

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


###Visualize dataframe d with wordcloud package
minFreq = 10
maxWords = 70
frequency = d$freq
frequency = round(sqrt(d$freq), 0)

### Let's come back and edit the raw tweets
myWords = c()
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
