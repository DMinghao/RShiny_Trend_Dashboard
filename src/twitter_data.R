if(!require(twitteR)){install.packages("twitteR")}
if(!require(tm)){install.packages("tm")}
if(!require(syuzhet)){install.packages("syuzhet")}
library(twitteR)
if(!require(openssl)){install.packages("openssl")}
if(!require(httpuv)){install.packages("httpuv")}
library(tidyverse)
if(!require(tm)){install.packages("tm")}
library(tm)

readRenviron("./.Renviron")
consumer_key <- Sys.getenv("twitter_consumer_key")
consumer_secret <- Sys.getenv("twitter_consumer_secret")
access_token <- Sys.getenv("twitter_access_token")
access_secret <- Sys.getenv("twitter_access_secret")
# Connect to twitter
setup_twitter_oauth(consumer_key,consumer_secret,access_token,access_secret)
# Keywords
data <- searchTwitter ('trump', n=500)
d <-data %>% strip_retweets %>% twListToDF()
# tdm/dtm
df <- data.frame(V1 = d, stringsAsFactors = FALSE)
names(df)[8] <- "doc_id"
names(df)[1] <- "text"
names(df)
mycorpus <- Corpus(DataframeSource(df))
tdm <- TermDocumentMatrix(mycorpus, control = list(removePunctuation = TRUE, stopwords = TRUE))
inspect(tdm)
dtm <-DocumentTermMatrix(mycorpus,control = list(weighting = function(x) weightTfIdf(x,normalize = FALSE),stopwords = TRUE))
inspect(dtm)
dtm$dimnames
as.matrix(dtm$dimnames)
# Function
getTwitterData <- function(keyword, fromDate = Sys.Date() - 365, toDate = Sys.Date()) {
  if (length(keyword) > 1 | fromDate >= toDate) {
    return(NULL)
  }
  searchTwitter(
    keyword,
    n = 500,
    lang = "en",
    since = NULL,
    until = NULL,
    locale = NULL,
    geocode = NULL,
    sinceID = NULL,
    maxID = NULL,
    resultType = NULL,
    retryOnRateLimit = 120
  )%>% strip_retweets %>% twListToDF()
}

data <- getTwitterData("trump")

glimpse(data)

